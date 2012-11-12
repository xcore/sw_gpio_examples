Slicekit GPIO and Ethernet Combo Demo
=====================================

:scope: Example
:description: An example application to demonstrate usage of multiple Slice Cards. This application showcase GPIO features which can be accessed and controlled using a web page
:keywords: Ethernet, I2C, LED, buttons
:boards: XP-SKC-L2, XA-SK-GPIO, XA-SK-E100

Features
--------

With this application running on XP-SKC-L2 using XA-SK-GPIO and XA-SK-E100 Slice Cards, you can issue commands from a web page from a host PC to:

   * Turn GPIO Slice Card LEDS on and off
   * Read the room temperature via the onboard ADC and display on the web page
   * Display GPIO Slice Card button presses


Required software (dependencies)
================================

  * sc_i2c (git@github.com:xcore/sc_i2c.git)
  * sc_webiste (git@github.com:xcore/sc_webiste.git)
  * sc_ethernet (git@github.com:xcore/sc_ethernet.git)
  * sc_xtcp (git@github.com:xcore/sc_xtcp.git)
  * sc_otp (git@github.com:xcore/sc_otp.git)
  * sc_util (git@github.com:xcore/sc_util.git)

