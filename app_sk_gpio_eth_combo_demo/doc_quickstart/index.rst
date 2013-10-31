sliceKIT gpio and ethernet combo demo quickstart guide
======================================================

.. _sliceKIT_gpio_ethernet_demo_quickstart:

sw_gpio_examples gpio and ethernet demo : quickstart guide
----------------------------------------------------------

This example demonstrates the use of two sliceCARDs, XA-SK-gpio and XA-SK-E100 together with the xSOFTip components for ethernet, xtcp, i2c and webserver to provide access to the XA-SK-gpio sliceCARD features via a simple embedded webserver.

A webpage served from the sliceKIT and accessed using a browser on a host PC has the following demo functions:
   * Turn XA-SK-gpio sliceCARD LEDS on and off
   * Read the room temperature via the onboard ADC and display on the web page
   * Display XA-SK-GPIO sliceCARD button press status

Hardware setup
++++++++++++++

The XP-SKC-L2 sliceKIT has four slots with edge conectors: ``SQUARE``, ``CIRCLE``, ``TRIANGLE`` and ``STAR``. 

To setup up the system refer to the figure and instructions below 

   #. Connect the XA-SK-E100 sliceCARD to the XP-SKC-L16 sliceKIT using the connector marked with the ``CIRCLE``.
   #. Connect the XA-SK-GPIO sliceCARD to the XP-SKC-L16 sliceKIT using the connector marked with the ``SQUARE``.
   #. Connect the XTAG-2 sliceCARD to sliceKIT , and connect XTAG-2 to the adapter. 
   #. Connect the XTAG-2 to the host PC. Note that an ethernet cable is not provided with the sliceKIT starter kit.
   #. Connect one end of the ethernet cable to XA-SK-E100 sliceCARD and the other end to the RJ45 jack of your host PC.
   #. Switch on the power supply to the sliceKIT.
   #. Ensure the activity LEDs on the XA-SK-E100 sliceCARD and the host PC's ethernet jack are toggling.
   
.. figure:: images/hardware_setup.*
   :align: center

   Hardware setup for the gpio and ethernet application demo


Import and build the application
++++++++++++++++++++++++++++++++

   #. Open xTIMEcomposer Studio, then open the edit perspective (Window->Open Perspective->XMOS Edit).
   #. Locate the ``'sliceKIT gpio and ethernet combo demo'`` item in the xSOFTip broswer window and drag it into the Project Explorer window in the xTIMEcomposer Studio. This will also cause the modules on which this application depends (in this case, module_ethernet_board_support, module_i2c_master, module_webserver) to be imported as well. 
   #. Click on the ``sliceKIT gpio and ethernet combo demo`` item in the Explorer pane then click on the build icon (hammer) in xTIMEcomposer Studio. Check the console window to verify that the application has built successfully.

For help in using xTIMEcomposer Studio, try the xTIMEcomposer tutorials, which you can find by selecting Help->Tutorials from the xTIMEcomposer Studio menu.

Running the demo
++++++++++++++++

   #. Click on the ``Run`` icon (the white arrow in the green circle). A dialog will appear asking which device to connect to. Select ``XMOS XTAG-2``. 
   #. xTIMEcomposer Studio console displays the ip address obtained by the DHCP client (or local link if DHCP server is not accesible). Please note if the DHCP  server is not available on the host PC, it may take a while to obtain the ip address.
   #. Open a web browser on the host PC and type the ip address displayed on the xTIMEcomposer Studio console into the browser's address bar
   #. On hitting the return key, a web page is loaded and displayed in the browser as shown in the figure below.

.. figure:: images/gpio_web_page.*
   :align: center

   Screenshot of the gpio web page

Use the web page options to perform various actions such as
   #. Switch on all the LEDs by turning them all to 'ON' in the browser then clicking 'Submit'. The LEDS should light, the ADC temperature display should be updated, and the webpage will report no buttons have been pressed.
   #. Switch off two of the LEDS by turning two to 'OFF' in the browser then clicking 'Submit'. Two LEDS should go out and the ADC temperature is reported again. This time also webpage will report no buttons have been pressed.
   #. Press SW1 button on the XA-SK-gpio sliceCARD and then press submit. The web page should now report that 'Button 1 is pressed'.
   #. Press SW2 button on the XA-SK-gpio sliceCARD and then press submit. The web page should now report that 'Button 2 is pressed'.
   #. Just hitting 'Submit' now displays 'both the buttons are not pressed'. LEDs state remain unchanged unless they are explicitly changed on the web page.
    
Next steps
++++++++++

Building web pages for your applications
........................................

This application parses ethernet data to interpret web page commands. Refer to the Programming guide section within the ``sliceKIT gpio example applications`` documentation linked from the front page documentation for this demo for more information on how to utilize the ``Embedded Webserver Function Library`` component in building your own custom web server applications.

Look at the Code
................

The application handler runs on one core. It uses I/O pins to read or write data to the LEDs, buttons and the i2c ADC to read the temperature. The web page handler executes in another core, receiving the TCP requests and processing them. It calls the functions described in the webpage (webpage includes embedded function calls into the application code), processing the requests and sending commands over the c_gpio channel to the gpio core (application handler).

   #. Examine the application code. In xTIMEcomposer Studio navigate to the ``src`` directory under app_sk_gpio_eth_combo_demo and double click on the main.xc file within it. The file will open in the central editor window.
   #. The channel ``c_gpio`` is used between tcp handler and application handler to send web page requests to the application and to collect gpio status from the application.
   #. In the app_handler.xc file, the API function ``set_gpio_state`` is used by the web page in order to apply web page LED settings and similarly the API function ``get_gpio_state`` is used by the web page to collect the current gpio status containing LEDs, button presses and ADC temperature values.
   #. There is some gpio button scan logic which monitors for value changes on the configured 4-bit button port (XS1_PORT_4C) in the application handler routine as defined in the ``app_handler.xc`` file. Whenever this port value changes, the gpio button states are updated accordingly.
   #. Also verify that that the ADC value is read whenever there is a web page request. This value is interpolated to get a proper temerature value and is updated in the gpio state structure before sending it to the web page.
   #. As a part of this exercise, modify the IP address settings in main.xc file to a static ip address as in the commented part of ip config, build and run the application. Open a web browser to check whether you are able to open a web page using the new ip address and able to issue LED commands from the web page.
