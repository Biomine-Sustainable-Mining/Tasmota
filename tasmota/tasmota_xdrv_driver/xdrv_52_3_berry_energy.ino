/*
  xdrv_52_3_berry_energy.ino - Berry scripting language, native fucnctions

  Copyright (C) 2021 Stephan Hadinger, Berry language by Guan Wenliang https://github.com/Skiars/berry

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

// Mappgin from internal light and a generic `light_state` Berry class

#ifdef USE_BERRY
#ifdef USE_ENERGY_SENSOR

#include "berry.h"
#include "be_func.h"
#include "be_ctypes.h"

/*********************************************************************************************\
 * Mapping for tEnergy
 *
\*********************************************************************************************/
extern "C" {

  int32_t module_energy_update_total(struct bvm *vm);
  int32_t module_energy_update_total(struct bvm *vm) {
    EnergyUpdateTotal();
    be_return_nil(vm);
  }



#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Winvalid-offsetof"   // avoid warnings since we're using offsetof() in a risky way

  static const char * be_ctypes_instance_mappings[] = {
    NULL
  };
  extern "C" const be_ctypes_structure_t be_energy_struct = {
    sizeof(tEnergy),  /* size in bytes */
    188,  /* number of elements */
    be_ctypes_instance_mappings,
    (const be_ctypes_structure_item_t[188]) {
      { "active_power", offsetof(tEnergy, active_power[0]), 0, 0, ctypes_float, 0 },
      { "active_power_2", offsetof(tEnergy, active_power[1]), 0, 0, ctypes_float, 0 },
      { "active_power_3", offsetof(tEnergy, active_power[2]), 0, 0, ctypes_float, 0 },
      { "active_power_4", offsetof(tEnergy, active_power[3]), 0, 0, ctypes_float, 0 },
      { "active_power_5", offsetof(tEnergy, active_power[4]), 0, 0, ctypes_float, 0 },
      { "active_power_6", offsetof(tEnergy, active_power[5]), 0, 0, ctypes_float, 0 },
      { "active_power_7", offsetof(tEnergy, active_power[6]), 0, 0, ctypes_float, 0 },
      { "active_power_8", offsetof(tEnergy, active_power[7]), 0, 0, ctypes_float, 0 },
      { "apparent_power", offsetof(tEnergy, apparent_power[0]), 0, 0, ctypes_float, 0 },
      { "apparent_power_2", offsetof(tEnergy, apparent_power[1]), 0, 0, ctypes_float, 0 },
      { "apparent_power_3", offsetof(tEnergy, apparent_power[2]), 0, 0, ctypes_float, 0 },
      { "apparent_power_4", offsetof(tEnergy, apparent_power[3]), 0, 0, ctypes_float, 0 },
      { "apparent_power_5", offsetof(tEnergy, apparent_power[4]), 0, 0, ctypes_float, 0 },
      { "apparent_power_6", offsetof(tEnergy, apparent_power[5]), 0, 0, ctypes_float, 0 },
      { "apparent_power_7", offsetof(tEnergy, apparent_power[6]), 0, 0, ctypes_float, 0 },
      { "apparent_power_8", offsetof(tEnergy, apparent_power[7]), 0, 0, ctypes_float, 0 },
      { "command_code", offsetof(tEnergy, command_code), 0, 0, ctypes_u8, 0 },
      { "current", offsetof(tEnergy, current[0]), 0, 0, ctypes_float, 0 },
      { "current_2", offsetof(tEnergy, current[1]), 0, 0, ctypes_float, 0 },
      { "current_3", offsetof(tEnergy, current[2]), 0, 0, ctypes_float, 0 },
      { "current_4", offsetof(tEnergy, current[3]), 0, 0, ctypes_float, 0 },
      { "current_5", offsetof(tEnergy, current[4]), 0, 0, ctypes_float, 0 },
      { "current_6", offsetof(tEnergy, current[5]), 0, 0, ctypes_float, 0 },
      { "current_7", offsetof(tEnergy, current[6]), 0, 0, ctypes_float, 0 },
      { "current_8", offsetof(tEnergy, current[7]), 0, 0, ctypes_float, 0 },
      { "current_available", offsetof(tEnergy, current_available), 0, 0, ctypes_u8, 0 },
      { "daily", offsetof(tEnergy, daily_kWh[0]), 0, 0, ctypes_float, 0 },
      { "daily_2", offsetof(tEnergy, daily_kWh[1]), 0, 0, ctypes_float, 0 },
      { "daily_3", offsetof(tEnergy, daily_kWh[2]), 0, 0, ctypes_float, 0 },
      { "daily_4", offsetof(tEnergy, daily_kWh[3]), 0, 0, ctypes_float, 0 },
      { "daily_5", offsetof(tEnergy, daily_kWh[4]), 0, 0, ctypes_float, 0 },
      { "daily_6", offsetof(tEnergy, daily_kWh[5]), 0, 0, ctypes_float, 0 },
      { "daily_7", offsetof(tEnergy, daily_kWh[6]), 0, 0, ctypes_float, 0 },
      { "daily_8", offsetof(tEnergy, daily_kWh[7]), 0, 0, ctypes_float, 0 },
      { "daily_sum", offsetof(tEnergy, daily_sum), 0, 0, ctypes_float, 0 },
      { "daily_sum_export_balanced", offsetof(tEnergy, daily_sum_export_balanced), 0, 0, ctypes_float, 0 },
      { "daily_sum_import_balanced", offsetof(tEnergy, daily_sum_import_balanced), 0, 0, ctypes_float, 0 },
      { "data_valid", offsetof(tEnergy, data_valid[0]), 0, 0, ctypes_u8, 0 },
      { "data_valid_2", offsetof(tEnergy, data_valid[1]), 0, 0, ctypes_u8, 0 },
      { "data_valid_3", offsetof(tEnergy, data_valid[2]), 0, 0, ctypes_u8, 0 },
      { "data_valid_4", offsetof(tEnergy, data_valid[3]), 0, 0, ctypes_u8, 0 },
      { "data_valid_5", offsetof(tEnergy, data_valid[4]), 0, 0, ctypes_u8, 0 },
      { "data_valid_6", offsetof(tEnergy, data_valid[5]), 0, 0, ctypes_u8, 0 },
      { "data_valid_7", offsetof(tEnergy, data_valid[6]), 0, 0, ctypes_u8, 0 },
      { "data_valid_8", offsetof(tEnergy, data_valid[7]), 0, 0, ctypes_u8, 0 },
      { "energy_active_export", offsetof(tEnergy, local_energy_active_export), 0, 0, ctypes_u8, 0 },
      { "export_active", offsetof(tEnergy, export_active[0]), 0, 0, ctypes_float, 0 },
      { "export_active_2", offsetof(tEnergy, export_active[1]), 0, 0, ctypes_float, 0 },
      { "export_active_3", offsetof(tEnergy, export_active[2]), 0, 0, ctypes_float, 0 },
      { "export_active_4", offsetof(tEnergy, export_active[3]), 0, 0, ctypes_float, 0 },
      { "export_active_5", offsetof(tEnergy, export_active[4]), 0, 0, ctypes_float, 0 },
      { "export_active_6", offsetof(tEnergy, export_active[5]), 0, 0, ctypes_float, 0 },
      { "export_active_7", offsetof(tEnergy, export_active[6]), 0, 0, ctypes_float, 0 },
      { "export_active_8", offsetof(tEnergy, export_active[7]), 0, 0, ctypes_float, 0 },
      { "fifth_second", offsetof(tEnergy, fifth_second), 0, 0, ctypes_u8, 0 },
      { "frequency", offsetof(tEnergy, frequency[0]), 0, 0, ctypes_float, 0 },
      { "frequency_2", offsetof(tEnergy, frequency[1]), 0, 0, ctypes_float, 0 },
      { "frequency_3", offsetof(tEnergy, frequency[2]), 0, 0, ctypes_float, 0 },
      { "frequency_4", offsetof(tEnergy, frequency[3]), 0, 0, ctypes_float, 0 },
      { "frequency_5", offsetof(tEnergy, frequency[4]), 0, 0, ctypes_float, 0 },
      { "frequency_6", offsetof(tEnergy, frequency[5]), 0, 0, ctypes_float, 0 },
      { "frequency_7", offsetof(tEnergy, frequency[6]), 0, 0, ctypes_float, 0 },
      { "frequency_8", offsetof(tEnergy, frequency[7]), 0, 0, ctypes_float, 0 },
      { "frequency_common", offsetof(tEnergy, frequency_common), 0, 0, ctypes_u8, 0 },
      { "import_active", offsetof(tEnergy, import_active[0]), 0, 0, ctypes_float, 0 },
      { "import_active_2", offsetof(tEnergy, import_active[1]), 0, 0, ctypes_float, 0 },
      { "import_active_3", offsetof(tEnergy, import_active[2]), 0, 0, ctypes_float, 0 },
      { "import_active_4", offsetof(tEnergy, import_active[3]), 0, 0, ctypes_float, 0 },
      { "import_active_5", offsetof(tEnergy, import_active[4]), 0, 0, ctypes_float, 0 },
      { "import_active_6", offsetof(tEnergy, import_active[5]), 0, 0, ctypes_float, 0 },
      { "import_active_7", offsetof(tEnergy, import_active[6]), 0, 0, ctypes_float, 0 },
      { "import_active_8", offsetof(tEnergy, import_active[7]), 0, 0, ctypes_float, 0 },
      { "max_current_flag", offsetof(tEnergy, max_current_flag[0]), 0, 0, ctypes_u8, 0 },
      { "max_energy_state", offsetof(tEnergy, max_energy_state[0]), 0, 0, ctypes_u8, 0 },
      { "max_power_flag", offsetof(tEnergy, max_power_flag[0]), 0, 0, ctypes_u8, 0 },
      { "max_voltage_flag", offsetof(tEnergy, max_voltage_flag[0]), 0, 0, ctypes_u8, 0 },
      { "min_current_flag", offsetof(tEnergy, min_current_flag[0]), 0, 0, ctypes_u8, 0 },
      { "min_power_flag", offsetof(tEnergy, min_power_flag[0]), 0, 0, ctypes_u8, 0 },
      { "min_voltage_flag", offsetof(tEnergy, min_voltage_flag[0]), 0, 0, ctypes_u8, 0 },
      { "mpl_hold_counter", offsetof(tEnergy, mpl_hold_counter[0]), 0, 0, ctypes_u16, 0 },
      { "mpl_retry_counter", offsetof(tEnergy, mpl_retry_counter[0]), 0, 0, ctypes_u8, 0 },
      { "mpl_window_counter", offsetof(tEnergy, mpl_window_counter[0]), 0, 0, ctypes_u16, 0 },
      { "period", offsetof(tEnergy, period_kWh[0]), 0, 0, ctypes_float, 0 },
      { "period_2", offsetof(tEnergy, period_kWh[1]), 0, 0, ctypes_float, 0 },
      { "period_3", offsetof(tEnergy, period_kWh[2]), 0, 0, ctypes_float, 0 },
      { "period_4", offsetof(tEnergy, period_kWh[3]), 0, 0, ctypes_float, 0 },
      { "period_5", offsetof(tEnergy, period_kWh[4]), 0, 0, ctypes_float, 0 },
      { "period_6", offsetof(tEnergy, period_kWh[5]), 0, 0, ctypes_float, 0 },
      { "period_7", offsetof(tEnergy, period_kWh[6]), 0, 0, ctypes_float, 0 },
      { "period_8", offsetof(tEnergy, period_kWh[7]), 0, 0, ctypes_float, 0 },
      { "phase_count", offsetof(tEnergy, phase_count), 0, 0, ctypes_u8, 0 },
      { "power_factor", offsetof(tEnergy, power_factor[0]), 0, 0, ctypes_float, 0 },
      { "power_factor_2", offsetof(tEnergy, power_factor[1]), 0, 0, ctypes_float, 0 },
      { "power_factor_3", offsetof(tEnergy, power_factor[2]), 0, 0, ctypes_float, 0 },
      { "power_factor_4", offsetof(tEnergy, power_factor[3]), 0, 0, ctypes_float, 0 },
      { "power_factor_5", offsetof(tEnergy, power_factor[4]), 0, 0, ctypes_float, 0 },
      { "power_factor_6", offsetof(tEnergy, power_factor[5]), 0, 0, ctypes_float, 0 },
      { "power_factor_7", offsetof(tEnergy, power_factor[6]), 0, 0, ctypes_float, 0 },
      { "power_factor_8", offsetof(tEnergy, power_factor[7]), 0, 0, ctypes_float, 0 },
      { "power_history_0", offsetof(tEnergy, power_history[0][0]), 0, 0, ctypes_u16, 0 },
      { "power_history_0_2", offsetof(tEnergy, power_history[0][1]), 0, 0, ctypes_u16, 0 },
      { "power_history_0_3", offsetof(tEnergy, power_history[0][2]), 0, 0, ctypes_u16, 0 },
      { "power_history_0_4", offsetof(tEnergy, power_history[0][3]), 0, 0, ctypes_u16, 0 },
      { "power_history_0_5", offsetof(tEnergy, power_history[0][4]), 0, 0, ctypes_u16, 0 },
      { "power_history_0_6", offsetof(tEnergy, power_history[0][5]), 0, 0, ctypes_u16, 0 },
      { "power_history_0_7", offsetof(tEnergy, power_history[0][6]), 0, 0, ctypes_u16, 0 },
      { "power_history_0_8", offsetof(tEnergy, power_history[0][7]), 0, 0, ctypes_u16, 0 },
      { "power_history_1", offsetof(tEnergy, power_history[1][0]), 0, 0, ctypes_u16, 0 },
      { "power_history_1_2", offsetof(tEnergy, power_history[1][1]), 0, 0, ctypes_u16, 0 },
      { "power_history_1_3", offsetof(tEnergy, power_history[1][2]), 0, 0, ctypes_u16, 0 },
      { "power_history_1_4", offsetof(tEnergy, power_history[1][3]), 0, 0, ctypes_u16, 0 },
      { "power_history_1_5", offsetof(tEnergy, power_history[1][4]), 0, 0, ctypes_u16, 0 },
      { "power_history_1_6", offsetof(tEnergy, power_history[1][5]), 0, 0, ctypes_u16, 0 },
      { "power_history_1_7", offsetof(tEnergy, power_history[1][6]), 0, 0, ctypes_u16, 0 },
      { "power_history_1_8", offsetof(tEnergy, power_history[1][7]), 0, 0, ctypes_u16, 0 },
      { "power_history_2", offsetof(tEnergy, power_history[2][0]), 0, 0, ctypes_u16, 0 },
      { "power_history_2_2", offsetof(tEnergy, power_history[2][1]), 0, 0, ctypes_u16, 0 },
      { "power_history_2_3", offsetof(tEnergy, power_history[2][2]), 0, 0, ctypes_u16, 0 },
      { "power_history_2_4", offsetof(tEnergy, power_history[2][3]), 0, 0, ctypes_u16, 0 },
      { "power_history_2_5", offsetof(tEnergy, power_history[2][4]), 0, 0, ctypes_u16, 0 },
      { "power_history_2_6", offsetof(tEnergy, power_history[2][5]), 0, 0, ctypes_u16, 0 },
      { "power_history_2_7", offsetof(tEnergy, power_history[2][6]), 0, 0, ctypes_u16, 0 },
      { "power_history_2_8", offsetof(tEnergy, power_history[2][7]), 0, 0, ctypes_u16, 0 },
      { "power_on", offsetof(tEnergy, power_on), 0, 0, ctypes_u8, 0 },
      { "power_steady_counter", offsetof(tEnergy, power_steady_counter), 0, 0, ctypes_u8, 0 },
      { "reactive_power", offsetof(tEnergy, reactive_power[0]), 0, 0, ctypes_float, 0 },
      { "reactive_power_2", offsetof(tEnergy, reactive_power[1]), 0, 0, ctypes_float, 0 },
      { "reactive_power_3", offsetof(tEnergy, reactive_power[2]), 0, 0, ctypes_float, 0 },
      { "reactive_power_4", offsetof(tEnergy, reactive_power[3]), 0, 0, ctypes_float, 0 },
      { "reactive_power_5", offsetof(tEnergy, reactive_power[4]), 0, 0, ctypes_float, 0 },
      { "reactive_power_6", offsetof(tEnergy, reactive_power[5]), 0, 0, ctypes_float, 0 },
      { "reactive_power_7", offsetof(tEnergy, reactive_power[6]), 0, 0, ctypes_float, 0 },
      { "reactive_power_8", offsetof(tEnergy, reactive_power[7]), 0, 0, ctypes_float, 0 },
      { "start_energy", offsetof(tEnergy, start_energy[0]), 0, 0, ctypes_float, 0 },
      { "start_energy_2", offsetof(tEnergy, start_energy[1]), 0, 0, ctypes_float, 0 },
      { "start_energy_3", offsetof(tEnergy, start_energy[2]), 0, 0, ctypes_float, 0 },
      { "start_energy_4", offsetof(tEnergy, start_energy[3]), 0, 0, ctypes_float, 0 },
      { "start_energy_5", offsetof(tEnergy, start_energy[4]), 0, 0, ctypes_float, 0 },
      { "start_energy_6", offsetof(tEnergy, start_energy[5]), 0, 0, ctypes_float, 0 },
      { "start_energy_7", offsetof(tEnergy, start_energy[6]), 0, 0, ctypes_float, 0 },
      { "start_energy_8", offsetof(tEnergy, start_energy[7]), 0, 0, ctypes_float, 0 },
      { "today_delta_kwh", offsetof(tEnergy, kWhtoday_delta[0]), 0, 0, ctypes_u32, 0 },
      { "today_delta_kwh_2", offsetof(tEnergy, kWhtoday_delta[1]), 0, 0, ctypes_u32, 0 },
      { "today_delta_kwh_3", offsetof(tEnergy, kWhtoday_delta[2]), 0, 0, ctypes_u32, 0 },
      { "today_delta_kwh_4", offsetof(tEnergy, kWhtoday_delta[3]), 0, 0, ctypes_u32, 0 },
      { "today_delta_kwh_5", offsetof(tEnergy, kWhtoday_delta[4]), 0, 0, ctypes_u32, 0 },
      { "today_delta_kwh_6", offsetof(tEnergy, kWhtoday_delta[5]), 0, 0, ctypes_u32, 0 },
      { "today_delta_kwh_7", offsetof(tEnergy, kWhtoday_delta[6]), 0, 0, ctypes_u32, 0 },
      { "today_delta_kwh_8", offsetof(tEnergy, kWhtoday_delta[7]), 0, 0, ctypes_u32, 0 },
      { "today_kwh", offsetof(tEnergy, kWhtoday[0]), 0, 0, ctypes_u32, 0 },
      { "today_kwh_2", offsetof(tEnergy, kWhtoday[1]), 0, 0, ctypes_u32, 0 },
      { "today_kwh_3", offsetof(tEnergy, kWhtoday[2]), 0, 0, ctypes_u32, 0 },
      { "today_kwh_4", offsetof(tEnergy, kWhtoday[3]), 0, 0, ctypes_u32, 0 },
      { "today_kwh_5", offsetof(tEnergy, kWhtoday[4]), 0, 0, ctypes_u32, 0 },
      { "today_kwh_6", offsetof(tEnergy, kWhtoday[5]), 0, 0, ctypes_u32, 0 },
      { "today_kwh_7", offsetof(tEnergy, kWhtoday[6]), 0, 0, ctypes_u32, 0 },
      { "today_kwh_8", offsetof(tEnergy, kWhtoday[7]), 0, 0, ctypes_u32, 0 },
      { "today_offset_init_kwh", offsetof(tEnergy, kWhtoday_offset_init), 0, 0, ctypes_u8, 0 },
      { "today_offset_kwh", offsetof(tEnergy, energy_today_offset_kWh[0]), 0, 0, ctypes_float, 0 },
      { "today_offset_kwh_2", offsetof(tEnergy, energy_today_offset_kWh[1]), 0, 0, ctypes_float, 0 },
      { "today_offset_kwh_3", offsetof(tEnergy, energy_today_offset_kWh[2]), 0, 0, ctypes_float, 0 },
      { "today_offset_kwh_4", offsetof(tEnergy, energy_today_offset_kWh[3]), 0, 0, ctypes_float, 0 },
      { "today_offset_kwh_5", offsetof(tEnergy, energy_today_offset_kWh[4]), 0, 0, ctypes_float, 0 },
      { "today_offset_kwh_6", offsetof(tEnergy, energy_today_offset_kWh[5]), 0, 0, ctypes_float, 0 },
      { "today_offset_kwh_7", offsetof(tEnergy, energy_today_offset_kWh[6]), 0, 0, ctypes_float, 0 },
      { "today_offset_kwh_8", offsetof(tEnergy, energy_today_offset_kWh[7]), 0, 0, ctypes_float, 0 },
      { "total", offsetof(tEnergy, total[0]), 0, 0, ctypes_float, 0 },
      { "total_2", offsetof(tEnergy, total[1]), 0, 0, ctypes_float, 0 },
      { "total_3", offsetof(tEnergy, total[2]), 0, 0, ctypes_float, 0 },
      { "total_4", offsetof(tEnergy, total[3]), 0, 0, ctypes_float, 0 },
      { "total_5", offsetof(tEnergy, total[4]), 0, 0, ctypes_float, 0 },
      { "total_6", offsetof(tEnergy, total[5]), 0, 0, ctypes_float, 0 },
      { "total_7", offsetof(tEnergy, total[6]), 0, 0, ctypes_float, 0 },
      { "total_8", offsetof(tEnergy, total[7]), 0, 0, ctypes_float, 0 },
      { "total_sum", offsetof(tEnergy, total_sum), 0, 0, ctypes_float, 0 },
      { "type_dc", offsetof(tEnergy, type_dc), 0, 0, ctypes_u8, 0 },
      { "use_overtemp", offsetof(tEnergy, use_overtemp), 0, 0, ctypes_u8, 0 },
      { "voltage", offsetof(tEnergy, voltage[0]), 0, 0, ctypes_float, 0 },
      { "voltage_2", offsetof(tEnergy, voltage[1]), 0, 0, ctypes_float, 0 },
      { "voltage_3", offsetof(tEnergy, voltage[2]), 0, 0, ctypes_float, 0 },
      { "voltage_4", offsetof(tEnergy, voltage[3]), 0, 0, ctypes_float, 0 },
      { "voltage_5", offsetof(tEnergy, voltage[4]), 0, 0, ctypes_float, 0 },
      { "voltage_6", offsetof(tEnergy, voltage[5]), 0, 0, ctypes_float, 0 },
      { "voltage_7", offsetof(tEnergy, voltage[6]), 0, 0, ctypes_float, 0 },
      { "voltage_8", offsetof(tEnergy, voltage[7]), 0, 0, ctypes_float, 0 },
      { "voltage_available", offsetof(tEnergy, voltage_available), 0, 0, ctypes_u8, 0 },
      { "voltage_common", offsetof(tEnergy, voltage_common), 0, 0, ctypes_u8, 0 },
      { "yesterday_sum", offsetof(tEnergy, yesterday_sum), 0, 0, ctypes_float, 0 },
  }};
  // be_define_ctypes_class(energy_struct, &be_energy_struct, &be_class_ctypes_bytes, "energy_struct");

#pragma GCC diagnostic pop
}


#endif // USE_ZIGBEE
#endif  // USE_BERRY
