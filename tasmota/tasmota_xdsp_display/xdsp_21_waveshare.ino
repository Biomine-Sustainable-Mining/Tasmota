/*
  xdsp_21_waveshare.ino - Display waveshare support for Tasmota

  TODO: Copyright

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


#ifdef USE_SPI
#ifdef USE_DISPLAY
#ifdef USE_DISPLAY_WAVESHARE

#define XDSP_21                21

#define COLORED42              1
#define UNCOLORED42            0

// using font 8 is opional (num=3)
// very badly readable, but may be useful for graphs
#define USE_TINY_FONT

#include <GxEPD2_BW.h>

/*********************************************************************************************\
 * Interface
\*********************************************************************************************/

bool Xdsp21(uint32_t function)
{
  Serial.println("IT IS LOADED");
  bool result = false;

  if (FUNC_DISPLAY_INIT_DRIVER == function) {
  }
  /*
  else if (epd42_init_done && (XDSP_21 == Settings->display_model)) {
    switch (function) {
      case FUNC_DISPLAY_MODEL:
        result = true;
        break;
    }
  }
  */
  return result;
}

#endif  // USE_DISPLAY_EPAPER42
#endif  // USE_DISPLAY
#endif  // USE_SPI
