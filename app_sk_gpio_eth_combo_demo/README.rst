Slicekit GPIO and Ethernet Combo Demo
=====================================

:scope: Example
:description: An example application to demonstrate usage of multiple Slice Cards. This application showcase GPIO features using a web page utilizing the Ethernet component
:keywords: Ethernet, I2C, LED, buttons
:boards: XP-SKC-l2, XA-SK-GPIO, XA-SK-E100

Features
--------

With this general learning application running on the XA-SK-GPIo Slice Card you can issue commands from a PC serial terminal operating via the Slice Card Uart to:

   * Turn LEDS on and off
   * Read the room temperature via the ADC and display on the web page
   * Display button presses on the web page

A PC with a Ethernet (RJ45) port will be required (not supplied with XA-Sk-GPIO).


Required software (dependencies)
================================

  * sc_i2c (git@github.com:xcore/sc_i2c.git)
  * sc_webiste (git@github.com:xcore/sc_webiste.git)
  * sc_ethernet (git@github.com:xcore/sc_ethernet.git)
  * sc_xtcp (git@github.com:xcore/sc_xtcp.git)
  * sc_otp (git@github.com:xcore/sc_otp.git)
  * sc_util (git@github.com:xcore/sc_util.git)

