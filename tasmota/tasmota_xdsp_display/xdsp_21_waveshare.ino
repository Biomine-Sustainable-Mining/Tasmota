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

#define XDSP_21 21

#define COLORED42 1
#define UNCOLORED42 0

// using font 8 is opional (num=3)
// very badly readable, but may be useful for graphs
#define USE_TINY_FONT

#define GxEPD2_DISPLAY_CLASS GxEPD2_BW

#define GxEPD2_DRIVER_CLASS GxEPD2_750_T7

#include <GxEPD2_BW.h>
#include <Fonts/FreeMonoBold9pt7b.h>
#include <GxEPD2_display_selection_new_style.h>

// display from <GxEPD2_display_selection_new_style.h>

/*********************************************************************************************\
 * Interface
\*********************************************************************************************/

bool Xdsp21(uint32_t function)
{

  bool result = false;
  switch(function) {
  case FUNC_DISPLAY_INIT_DRIVER:
  

    AddLog(LOG_LEVEL_INFO, PSTR("DSP: Waveshare Driver"));
    if (PinUsed(GPIO_WAVESHARE_CS) && ((TasmotaGlobal.soft_spi_enabled & SPI_MOSI) || (TasmotaGlobal.spi_enabled & SPI_MOSI)))
    {
      Serial.println("CS Selected");

      if (TasmotaGlobal.soft_spi_enabled)
      {
        Serial.println("SoftSPI");
        Serial.print("CS: ");
        Serial.println(Pin(GPIO_WAVESHARE_CS));
        Serial.print("MOSI: ");
        Serial.println(Pin(GPIO_SSPI_MOSI));
        Serial.print("SCLK: ");
        Serial.println(Pin(GPIO_SSPI_SCLK));
        Serial.print("DC: ");
        Serial.println(Pin(GPIO_SSPI_DC));
        Serial.print("BUSY/MISO: ");
        Serial.println(Pin(GPIO_SSPI_MISO));
        Serial.print("Rst: ");
        Serial.println(Pin(GPIO_OLED_RESET));
      }
      else if (TasmotaGlobal.spi_enabled)
      {
        Serial.println("HardSPI");
        Serial.print("CS: ");
        Serial.println(Pin(GPIO_WAVESHARE_CS));
        Serial.print("MOSI: ");
        Serial.println(Pin(GPIO_SPI_MOSI));
        Serial.print("CLK: ");
        Serial.println(Pin(GPIO_SPI_CLK));
        Serial.print("DC: ");
        Serial.println(Pin(GPIO_SPI_DC));
        Serial.print("BUSY/MISO: ");
        Serial.println(Pin(GPIO_SPI_MISO));
        Serial.print("Rst: ");
        Serial.println(Pin(GPIO_OLED_RESET));
        const char HelloWorld[] = "Biomine S.r.l.";
        // renderer = &display;

        display.init(9600, true, 2, false); // USE THIS for Waveshare boards with "clever" reset circuit, 2ms reset pulse
        display.setRotation(0);
        display.setFont(&FreeMonoBold9pt7b);

        display.setTextColor(GxEPD_BLACK);
        int16_t tbx, tby;
        uint16_t tbw, tbh;
        display.getTextBounds(HelloWorld, 0, 0, &tbx, &tby, &tbw, &tbh);
        // center the bounding box by transposition of the origin:
        uint16_t x = ((display.width() - tbw) / 2) - tbx;
        uint16_t y = ((display.height() - tbh) / 2) - tby;
        display.setFullWindow();

        display.firstPage(); // FILL WHITE
        do
        {
          // display.drawRect(x-10,y+10, 200, -50, GxEPD_BLACK);
          display.setCursor(x, y);
          display.print(HelloWorld);
        } while (display.nextPage());
        display.hibernate();
      }
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
  break;
  case FUNC_DISPLAY_CLEAR:
  break;
  case FUNC_DISPLAY_DRAW_STRING:
  break;
  }
  return result;
}

#endif // USE_DISPLAY_EPAPER42
#endif // USE_DISPLAY
#endif // USE_SPI
