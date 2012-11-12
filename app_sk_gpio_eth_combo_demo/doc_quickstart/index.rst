GPIO Com Port Demo Quickstart Guide
===================================

.. _Slicekit_GPIO_Ethernet_Combo_Demo_Quickstart:

sw_gpio_examples GPIO Ethernet Combo demo : Quick Start Guide
-------------------------------------------------------------

This example demonstrates a combo application using two Slice Cards XA-SK-GPIO and XA-SK-E100 together with the xSOFTip components for XTCP, Ethernet, I2C and WebServer.
This application showcase GPIO features using a web page from a host PC to:
   * Turn GPIO Slice Card LEDS on and off
   * Read the room temperature via the onboard ADC and display on the web page
   * Display GPIO Slice Card button presses

Hardware Setup
++++++++++++++

The XP-SKC-L2 Slicekit Core board has four slots with edge conectors: ``SQUARE``, ``CIRCLE``,``TRIANGLE`` and ``STAR``. 

To setup up the system refer to the figure and instructions below 

   #. Connect XA-SK-E100 Slice Card to the XP-SKC-L2 Slicekit Core board using the connector marked with the ``CIRCLE``.
   #. Connect XA-SK-GPIO Slice Card to the XP-SKC-L2 Slicekit Core board using the connector marked with the ``SQUARE``.
   #. Connect the XTAG Adapter to Slicekit Core board, and connect XTAG-2 to the adapter. 
   #. Connect the XTAG-2 to host PC. Note that a USB cable is not provided with the Slicekit starter kit.
   #. Switch on the power supply to the Slicekit Core board.
   #. Open the serial device on the host console program
   
.. figure:: images/hardware_setup.png
   :align: center

   Hardware Setup for GPIO Ethernet Combo Application Demo 


Import and Build the Application
++++++++++++++++++++++++++++++++

   #. Open xTIMEcomposer, then open the edit perspective (Window->Open Perspective->XMOS Edit).
   #. Locate the ``'Slicekit GPIO Ethernet Combo Demo'`` item in the xSOFTip Broswer window and drag it into the Project Explorer window in the xTIMEcomposer. This will also cause the modules on which this application depends (in this case, module_ethernet_board_support, module_i2c_master, module_webserver) to be imported as well. 
   #. Click on the Slicekit GPIO Ethernet Combo Demo item in the Explorer pane then click on the build icon (hammer) in xTIMEcomposer. Check the console window to verify that the application has built successfully.

For help in using xTIMEcomposer, try the xTIMEcomposer tutorials, which you can find by selecting Help->Tutorials from the xTIMEcomposer menu.

Note that the Developer Column in the xTIMEcomposer on the right hand side of your screen provides information on the xSOFTip components you are using. Select the ``generic UART Receiver``  component in the xSOFTip Browser, and you will see its description together with links to more documentation for this component. Once you have briefly explored this component, you can return to this quickstart guide by re-selecting  ``'Slicekit GPIO Ethernet Combo Demo'`` in the xSOFTip Browser and clicking once more on the Quickstart  link for the ``Slicekit GPIO Ethernet Combo Demo Quickstart``.
    

Running the Demo
++++++++++++++++

   #. Click on the ``Run`` icon (the white arrow in the green circle). A dialog will appear asking which device to connect to. Select ``XMOS XTAG2``. 
   #. xTIMEcomposer console contain ip address obtained by the DHCP client used by the application
   #. Copy the ip address and open a web client on the host PC; say Google Chrome and paste or type in the acquired ip address
   #. On hitting the return key in the browser address bar, a web page should get loaded and displayed in the browser as shown in the figure below.

.. figure:: images/gpio_web_page.png
   :align: center

   Screenshot of GPIO web page

   #. Select LEDs to switch ON or switch OFF the LEDs.
   #. Select Button 1 and/or Button 2 to display button press status.
   #. Select Submit button to send the web page request to XMOS GPIO web server
   #. Application sets the selected LEDs ON or OFF on the GPIO Slice Card based on the web page request
   #. If any button selected, application displays whether the corresponding button on the GPIO Slice Card is pressed since its last request
   #. Button press status is reset after a button is checked for its button press status
   #. For every web page request, it displays temperature recorded from GPIO onboard ADC
   #. Open multiple browsers sessions on different browsers and repeat the experiment for different GPIO settings
    
Next Steps
++++++++++

Look at the Code
................

   #. Examine the application code. In xTIMEcomposer navigate to the ``src`` directory under app_sk_gpio_eth_combo_demo and double click on the main.xc file within it. The file will open in the central editor window.
   #. Find the part of the code which is processing command from the web page. Check how WebServer (sc_website) component simplifies the task of integrating web pages into device web server. Refer to Programming Guide section available at sw_gpio_examples\doc to utilize WebServer component. As part of this exercise, locate the application that uses OTP librabry to read Ethernet MAC address (``OTP Reading Library Example``) in the xSOFTip explorer pane of xTIMEcomposer.

More complex Bridging Applications
..................................

This application parses ethernet data to interprest web page commandsTake a look at the Multi-Uart Component in the xSOFTip Explorer. This fits 8 Uarts into two logical cores. Have a look at the documentation for that component and usage of its API for more complex bridging application. 

XMOS has also implemented a reference solution for an Ethernet to Serial bridge offering many features including dynamic reconfiguration, an embedded webserver and 8 uarts running up to 115KBaud. To get access to this solution, buy the XA-SK-UART-8 Multi Uart Slice Card from digikey and contact your sales representative to get the reference code.
