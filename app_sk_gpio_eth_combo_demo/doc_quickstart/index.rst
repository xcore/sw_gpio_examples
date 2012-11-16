GPIO Com Port Demo Quickstart Guide
===================================

.. _Slicekit_GPIO_Ethernet_Combo_Demo_Quickstart:

sw_gpio_examples GPIO and Ethernet demo : Quick Start Guide
-----------------------------------------------------------

This example demonstrates the use of two Slice Cards, XA-SK-GPIO and XA-SK-E100 together with the xSOFTip components for Ethernet, XTCP, I2C and WebServer to provide access to the GPIo slice features via a simple embedded webserver.

A webpage served from the sliceKIT and accessed in a browser on a host PC has the following demo functions:
   * Turn GPIO Slice Card LEDS on and off
   * Read the room temperature via the onboard ADC and display on the web page
   * Display GPIO Slice Card button press status

Hardware Setup
++++++++++++++

The XP-SKC-L2 Slicekit Core board has four slots with edge conectors: ``SQUARE``, ``CIRCLE``, ``TRIANGLE`` and ``STAR``. 

To setup up the system refer to the figure and instructions below 

   #. Connect XA-SK-E100 Slice Card to the XP-SKC-L2 Slicekit Core board using the connector marked with the ``CIRCLE``.
   #. Connect XA-SK-GPIO Slice Card to the XP-SKC-L2 Slicekit Core board using the connector marked with the ``SQUARE``.
   #. Connect the XTAG Adapter to Slicekit Core board, and connect XTAG-2 to the adapter. 
   #. Connect the XTAG-2 to host PC. Note that a USB cable is not provided with the Slicekit starter kit.
   #. Connect one end of Ethernet cable to XA-SK-E100 Slice Card and the other end to the RJ45 jack of your host PC.
   #. Switch on the power supply to the Slicekit Core board.
   #. Ensure the LEDs on XA-SK-E100 Slice Card and LEDs on host PC's Ethernet Jack are active and toggling
   
.. figure:: images/hardware_setup.png
   :align: center

   Hardware Setup for the GPIO and Ethernet Application Demo 


Import and Build the Application
++++++++++++++++++++++++++++++++

   #. Open xTIMEcomposer, then open the edit perspective (Window->Open Perspective->XMOS Edit).
   #. Locate the ``'Slicekit GPIO Ethernet Combo Demo'`` item in the xSOFTip Broswer window and drag it into the Project Explorer window in the xTIMEcomposer. This will also cause the modules on which this application depends (in this case, module_ethernet_board_support, module_i2c_master, module_webserver) to be imported as well. 
   #. Click on the ``Slicekit GPIO Ethernet Combo Demo`` item in the Explorer pane then click on the build icon (hammer) in xTIMEcomposer. Check the console window to verify that the application has built successfully.

For help in using xTIMEcomposer, try the xTIMEcomposer tutorials, which you can find by selecting Help->Tutorials from the xTIMEcomposer menu.

Running the Demo
++++++++++++++++

   #. Click on the ``Run`` icon (the white arrow in the green circle). A dialog will appear asking which device to connect to. Select ``XMOS XTAG2``. 
   #. xTIMEcomposer console displays the ip address obtained by the DHCP client (or local link if DHCP server is not accesible)
   #. Open a web browser on the host PC and type the ip address displayed in the console into the browser's address bar
   #. On hitting the return key, a web page should get loaded and displayed in the browser as shown in the figure below.

.. figure:: images/gpio_web_page.png
   :align: center

   Screenshot of GPIO web page

Use the web page options to perform various actions such as
   #. Switch on all the LEDS by turning them all to 'ON' in the browser then clicking Submit. The LEDS should light, the ADC temperature display should be updated, and the webpage will report no buttons have been pressed.
   #. Switch off two of the LEDS by turning two to 'OFF' in the browser then clicking Submit. Two LEDS should go out and the ADC temperature is reported again.
   #. Press one of the buttons then press submit. The button status display should now report the button press.
   #. To continue your experimenation, open multiple web clients using different browsers and repeat the above steps for different GPIO settings
    
Next Steps
++++++++++

Look at the Code
................

   #. Examine the application code. In xTIMEcomposer navigate to the ``src`` directory under app_sk_gpio_eth_combo_demo and double click on the main.xc file within it. The file will open in the central editor window.
   #. Find the part of the code which is processing command from the web page. Check how WebServer (sc_website) component simplifies the task of integrating web pages into XMOS applications. Refer to Programming Guide section available at sw_gpio_examples/doc to utilize WebServer component. As part of this exercise, locate the application that uses OTP librabry to read Ethernet MAC address (``OTP Reading Library Example``) in the xSOFTip explorer pane of xTIMEcomposer.

More complex Bridging Applications
..................................

This application parses ethernet data to interpret web page commands. Take a look at the Multi-Uart Component in the xSOFTip Explorer. This fits 8 Uarts into two logical cores. Have a look at the documentation for that component and usage of its API for more complex bridging application. 

XMOS has also implemented a reference solution for an Ethernet to Serial bridge offering many features including dynamic reconfiguration, an embedded webserver and 8 uarts running up to 115KBaud. To get access to this solution, buy the XA-SK-UART-8 Multi Uart Slice Card from digikey and contact your sales representative to get the reference code.
