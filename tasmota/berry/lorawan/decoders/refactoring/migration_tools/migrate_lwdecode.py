#!/usr/bin/env python3
"""
LoRaWAN Decoder Migration Script
Automatically migrates LwDecode.be from monolithic to modular architecture

Usage:
    python migrate_lwdecode.py --repo-path /path/to/tasmota --dry-run
    python migrate_lwdecode.py --repo-path /path/to/tasmota --execute
"""

import os
import sys
import shutil
import subprocess
import argparse
import json
import hashlib
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Optional, Tuple

class Colors:
    """ANSI color codes for console output"""
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKCYAN = '\033[96m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

class MigrationLogger:
    """Enhanced logging for migration process"""
    
    def __init__(self, log_file: Optional[str] = None):
        self.log_file = log_file
        self.start_time = datetime.now()
        
    def log(self, level: str, message: str, color: str = Colors.ENDC):
        timestamp = datetime.now().strftime("%H:%M:%S")
        formatted_msg = f"[{timestamp}] {level.upper()}: {message}"
        
        # Console output with colors
        print(f"{color}{formatted_msg}{Colors.ENDC}")
        
        # File output without colors
        if self.log_file:
            with open(self.log_file, 'a', encoding='utf-8') as f:
                f.write(f"{formatted_msg}\n")
    
    def info(self, message: str):
        self.log("INFO", message, Colors.OKBLUE)
    
    def success(self, message: str):
        self.log("SUCCESS", message, Colors.OKGREEN)
    
    def warning(self, message: str):
        self.log("WARNING", message, Colors.WARNING)
    
    def error(self, message: str):
        self.log("ERROR", message, Colors.FAIL)
    
    def header(self, message: str):
        border = "=" * 60
        self.log("", f"\n{border}", Colors.HEADER)
        self.log("", f" {message}", Colors.HEADER + Colors.BOLD)
        self.log("", f"{border}", Colors.HEADER)

class LwDecodeMigrator:
    """Main migration orchestrator"""
    
    def __init__(self, repo_path: str, dry_run: bool = True):
        self.repo_path = Path(repo_path).resolve()
        self.dry_run = dry_run
        self.logger = MigrationLogger(self.repo_path / "migration.log")
        
        # Path definitions
        self.lorawan_base = self.repo_path / "tasmota" / "berry" / "lorawan"
        self.original_file = self.lorawan_base / "decoders" / "LwDecode.be"
        self.refactoring_dir = self.lorawan_base / "decoders" / "refactoring"
        
    def run_migration(self) -> bool:
        """Execute complete migration process"""
        self.logger.header(f"LORAWAN DECODER MIGRATION {'(DRY RUN)' if self.dry_run else ''}")
        
        # Check if refactoring files exist
        if not self.refactoring_dir.exists():
            self.logger.error(f"Refactoring directory not found: {self.refactoring_dir}")
            self.logger.info("Please ensure you have the refactoring files available.")
            return False
        
        # Backup original file
        if not self.dry_run:
            backup_dir = self.lorawan_base / "legacy"
            backup_dir.mkdir(exist_ok=True)
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            backup_file = backup_dir / f"LwDecode_backup_{timestamp}.be"
            
            if self.original_file.exists():
                shutil.copy2(self.original_file, backup_file)
                self.logger.success(f"Original file backed up to: {backup_file}")
        
        # Copy modular architecture
        target_paths = [
            ("config", self.lorawan_base / "config"),
            ("formatters", self.lorawan_base / "formatters"),
            ("decoders", self.lorawan_base / "decoders"),
            ("webui", self.lorawan_base / "webui"),
        ]
        
        for src_name, target_path in target_paths:
            src_path = self.refactoring_dir / src_name
            if src_path.exists():
                if self.dry_run:
                    self.logger.info(f"[DRY RUN] Would copy {src_name} to {target_path}")
                else:
                    target_path.mkdir(parents=True, exist_ok=True)
                    for file in src_path.glob("*.be"):
                        target_file = target_path / file.name
                        shutil.copy2(file, target_file)
                        self.logger.success(f"Copied: {file.name}")
        
        # Copy main LwDecode.be
        main_src = self.refactoring_dir / "LwDecode.be"
        if main_src.exists():
            if self.dry_run:
                self.logger.info(f"[DRY RUN] Would update main LwDecode.be")
            else:
                shutil.copy2(main_src, self.original_file)
                self.logger.success("Updated main LwDecode.be")
        
        if self.dry_run:
            self.logger.info("DRY RUN completed. Run with --execute to apply changes.")
        else:
            self.logger.success("Migration completed successfully!")
            
        return True

def main():
    parser = argparse.ArgumentParser(description="Migrate LoRaWAN Decoder to modular architecture")
    parser.add_argument('--repo-path', required=True, help='Path to Tasmota repository root')
    
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument('--dry-run', action='store_true', help='Show what would be done')
    group.add_argument('--execute', action='store_true', help='Execute the migration')
    
    args = parser.parse_args()
    
    migrator = LwDecodeMigrator(repo_path=args.repo_path, dry_run=args.dry_run)
    
    try:
        success = migrator.run_migration()
        sys.exit(0 if success else 1)
    except KeyboardInterrupt:
        migrator.logger.warning("Migration interrupted by user")
        sys.exit(130)
    except Exception as e:
        migrator.logger.error(f"Unexpected error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
