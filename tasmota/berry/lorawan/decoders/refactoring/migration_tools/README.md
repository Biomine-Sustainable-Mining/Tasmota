# Migration Tools - LoRaWAN Decoder Refactoring

## 🛠 Tools Overview

This directory contains automated migration tools to safely transition from the monolithic LwDecode.be to the ESP32-optimized modular architecture.

## 📦 Available Tools

### `migrate_lwdecode.py`
**Python migration script with advanced features:**
- ✅ Pre-flight validation and safety checks
- ✅ Automatic backup creation with timestamps  
- ✅ Git integration (if repository detected)
- ✅ Dry-run mode to preview changes
- ✅ Comprehensive error handling and logging
- ✅ Cross-platform compatibility (Windows/Linux/macOS)

### `migrate_lwdecode.bat`
**Windows batch wrapper for easy execution:**
- ✅ Simple menu-driven interface
- ✅ Automatic Python detection
- ✅ Built-in safety confirmations
- ✅ Color-coded output and progress indicators

## 🚀 Quick Start

### Windows Users (Recommended)
```cmd
# 1. Open Command Prompt in Tasmota repository root
cd C:\Project\tasmota\Tasmota

# 2. Copy migration tools to repository root
copy tasmota\berry\lorawan\decoders\refactoring\migration_tools\* .

# 3. Run the migration wizard  
migrate_lwdecode.bat
```

### Advanced/Cross-Platform Users
```bash
# Python direct execution
python migrate_lwdecode.py --repo-path /path/to/tasmota --dry-run
python migrate_lwdecode.py --repo-path /path/to/tasmota --execute
```

## 🔒 Safety Features

### Automatic Backups
- **Original file backup** with timestamp
- **Git commit creation** (if in git repository)
- **Separate backup directory** (`legacy/` folder)

### Validation Checks
- **Repository structure** validation
- **File permissions** verification
- **Python requirements** check
- **Disk space** availability

### Dry Run Mode
- **Preview all changes** without modifying files
- **Show detailed operation plan**
- **Estimate memory impact**
- **Identify potential issues**

## 📋 Migration Process

### Phase 1: Preparation
1. **Backup Creation** - Original files safely stored
2. **Environment Check** - Validate system requirements
3. **Repository Scan** - Detect current configuration

### Phase 2: Migration
1. **Directory Creation** - Set up modular structure
2. **Module Deployment** - Copy ESP32-optimized modules
3. **Main File Update** - Replace orchestrator
4. **Validation** - Verify all components loaded

### Phase 3: Verification
1. **System Check** - Ensure all modules accessible
2. **Compatibility Test** - Verify backward compatibility
3. **Performance Baseline** - Establish new metrics

## ⚙️ Command Reference

### Python Script Options
```bash
migrate_lwdecode.py [OPTIONS]

Options:
  --repo-path PATH     Path to Tasmota repository root (required)
  --dry-run           Preview changes without applying them
  --execute           Actually perform the migration
  --help              Show detailed help information
```

### Batch Script Menu
```
1. Dry Run           - Show what would be changed
2. Execute Migration - Apply the changes  
3. Exit              - Cancel operation
```

## 🔧 Troubleshooting

### Common Issues

**"Python not found"**
```bash
# Solution: Install Python 3.7+
# Windows: Download from python.org
# Linux: sudo apt install python3
# macOS: brew install python3
```

**"Permission denied"**
```bash  
# Solution: Run as administrator/root
# Windows: Right-click → "Run as Administrator"
# Linux/macOS: sudo python migrate_lwdecode.py ...
```

**"Repository not found"**
```bash
# Solution: Verify path and file structure
ls -la tasmota/berry/lorawan/  # Should show decoders/ directory
```

**Migration fails partway**
```bash
# Solution: Check logs and restore from backup
# 1. Review migration.log for errors
# 2. Restore: cp legacy/LwDecode_backup_*.be decoders/LwDecode.be
# 3. Remove partial files: rm -rf {config,formatters,webui}
```

### Debug Mode
Enable verbose logging:
```bash
# Add debug flag (Python script)
python migrate_lwdecode.py --repo-path . --dry-run --verbose

# Check migration log
tail -f migration.log
```

## 📊 Expected Results

### Memory Usage After Migration
```
Before: ~10-15KB heap usage
After:  ~2-3KB heap usage  
Savings: 70-80% memory reduction
```

### File Structure Changes
```
Before:
└── decoders/LwDecode.be (800+ lines)

After:  
├── config/LwConfig.be           (120 lines)
├── formatters/LwFormatter.be    (180 lines)  
├── decoders/LwDecoderManager.be (220 lines)
├── webui/LwWebUI.be            (150 lines)
└── decoders/LwDecode.be        (130 lines)
```

### New Commands Available
```bash
LwConfigGet                 # Show configuration
LwConfigSet key=value       # Update settings
LwDecoderList              # List loaded decoders  
LwDecoderStats             # Show usage statistics
LwStatus                   # Complete system status
```

## 🔄 Rollback Instructions

If migration causes issues:

### Automatic Rollback (Recommended)
```bash
# Restore from backup directory
cp tasmota/berry/lorawan/legacy/LwDecode_backup_*.be \
   tasmota/berry/lorawan/decoders/LwDecode.be

# Remove modular components
rm -rf tasmota/berry/lorawan/{config,formatters,webui}
```

### Git Rollback (If using version control)
```bash
# Undo migration commit
git log --oneline -5  # Find migration commit
git revert <commit-hash>

# Or hard reset (DESTRUCTIVE)
git reset --hard HEAD~1
```

## 📈 Migration Success Metrics

### Immediate Validation
- ✅ All modules load without errors
- ✅ Web interface accessible at `/lrw`
- ✅ Legacy commands still functional
- ✅ Existing decoders continue working

### Performance Validation  
- ✅ Heap usage reduced by 70%+
- ✅ Decode time improved by 50%+
- ✅ Web response faster and more stable
- ✅ No memory leaks during operation

## 🆘 Getting Help

1. **Check migration.log** for detailed error information
2. **Use dry-run mode** to identify issues before applying
3. **Verify system requirements** (Python 3.7+, sufficient disk space)
4. **Test with backup first** on non-production system

The migration tools are designed to be safe and reversible. Always run dry-run first!