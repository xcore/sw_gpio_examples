Slicekit GPIO and Wi-Fi Combo Demo
==================================

:scope: Example
:description: An example application to demonstrate the Wifi Slice controlling the LEDS and monitoring thebuttons and temperature sensor on the GPIO Slice.
:keywords: wifi, I2C, LED, buttons
:boards: XP-SKC-L2, XA-SK-GPIO, Wi-Fi Slice

Features
--------

With this application running on XP-SKC-L2 using XA-SK-GPIO and Wi-Fi Slice Cards, you can issue commands using a web page from a host PC to:

   * Turn GPIO Slice Card LEDS on and off
   * Read the room temperature via the on-board ADC and display on the web page
   * Display GPIO Slice Card button presses


Required software (dependencies)
================================

  * sc_i2c (git@github.com:xcore/sc_i2c.git)
  * sc_website (git@github.com:xcore/sc_webiste.git)
  * sc_wifi (git@github.com:xcore/sc_wifi.git)
  * sc_spi (git@github.com:xcore/sc_spi.git)
  * sc_otp (git@github.com:xcore/sc_otp.git)
  * sc_util (git@github.com:xcore/sc_util.git)

