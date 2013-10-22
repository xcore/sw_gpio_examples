sliceKIT GPIO and Wi-Fi Combo Demo Quickstart Guide
===================================================
This example uses the XA-SK-GPIO and XA-SK-WIFI slicaCARDs together with the xSOFTip components for TiWi-SL Wi-Fi, SPI, I2C and web server to provide access to the GPIO sliceCARD features via a simple embedded web server.

A web page served from the sliceKIT and accessed in a browser on a host computer has the following demo functions:

* Turn GPIO Slice Card LEDS on and off
* Read the room temperature via the on-board ADC and display on the web page
* Display GPIO Slice Card button press status

Host computer / Other setup
---------------------------
Required a computer:

* connected to a network
* Internet browser (Internet Explorer, Chrome, Firefox, etc...)
* Download and install the xTIMEcomposer Studio from XMOS xTIMEcomposer downloads web page.

Access point (wireless router) setup:

* Switch on the wireless router.
* Make sure you know its advertised name (SSID), password (if any) and the security type (Unsecured, WEP, WPA or WPA2)
* Make sure the host computer is on the above network.
 
Hardware setup
--------------
Required sliceKIT units:

* XP-SKC-L16 sliceKIT L16 core board
* XA-SK-WIFI Wi-Fi sliceCARD
* XA-SK-GPIO GPIO sliceCARD
* xTAG-2 and XA-SK-XTAG2 adapter

Setup:

* Connect the ``XA-SK-XTAG2`` adapter to the core board.
* Connect ``XTAG2`` to ``XSYS`` side (``J1``) of the ``XA-SK-XTAG2`` adapter.
* Connect the ``XTAG2`` to your computer using a USB cable.
* Set the ``XMOS LINK`` to ON on the ``XA-SK-XTAG2`` adapter.
* Connect the ``XA-SK-WIFI`` sliceCARD to the ``TRIANGLE`` slot of the sliceKIT Core board. The ``TRIANGLE`` slot is indicated by a white color triangle (or) ``J3``.
* Connect the ``XA-SK-GPIO`` sliceCARD to the ``SQUARE`` slot of the sliceKIT Core board. The ``SQUARE`` slot is indicated by a white color square (or) ``J7``.
* Connect the 12V power supply to the core board and switch it ON.

.. figure:: images/hardware_setup.*

   Hardware setup

Import and build the application
--------------------------------
Importing the GPIO and Wi-Fi combo demo application:

* Open the xTIMEcomposer Studio and ensure that it is operating in online mode. 
* Open the *Edit* perspective (Window -> Open Perspective -> XMOS Edit).
* Open the *xSOFTip* view from (Window -> Show View -> xSOFTip). An *xSOFTip* window appears on the bottom-left.
* Search for *sliceKIT GPIO and Wi-Fi Combo Demo*.
* Click and drag it into the *Project Explorer* window. Doing this will open a *Import xTIMEcomposer Software* window. Click on *Finish* to download and complete the import.
* This will also automatically import dependencies for this application.
* The application is called as *app_sk_gpio_wifi_tiwisl_combo_demo* in the *Project Explorer* window.

Building the GPIO and Wi-Fi combo demo application:

* Open the file (app_sk_gpio_wifi_tiwisl_combo_demo\src\wifi_tiwisl_config.h).
* Change the SSID, password and security type according to your wireless router configuration.
* Currently supported security types are: TIWISL_SEC_TYPE_UNSEC, TIWISL_SEC_TYPE_WEP, TIWISL_SEC_TYPE_WPA and TIWISL_SEC_TYPE_WPA2

   For example, if your wireless router is known as 'testwifirouter' with no password, then change the configuration as::

      #define WIFI_SSID           "testwifirouter"
      #define WIFI_PASSWORD       ""
      #define WIFI_SECURITY_TYPE  TIWISL_SEC_TYPE_UNSEC
       
   Another example: If your wireless router is known as 'testwifirouter' with password as 'testpwd' and the security type as 'WEP', then change the configuration as::

      #define WIFI_SSID           "testwifirouter"
      #define WIFI_PASSWORD       "testpwd"
      #define WIFI_SECURITY_TYPE  TIWISL_SEC_TYPE_WEP
       
* Click on the *app_sk_gpio_wifi_tiwisl_combo_demo* item in the *Project Explorer* window.
* Click on the *Build* (indicated by a 'Hammer' picture) icon.
* Check the *Console* window to verify that the application has built successfully.

Run the application
-------------------
To run the application using xTIMEcomposer Studio:

* In the *Project Explorer* window, locate the *app_sk_gpio_wifi_tiwisl_combo_demo.xe* in the (app_tiwisl_simple_webserver -> Binaries).
* Right click on *app_sk_gpio_wifi_tiwisl_combo_demo.xe* and click on (Run As -> xCORE Application).
* A *Select Device* window appears.
* Select *XMOS XTAG-2 connected to L1* and click OK.

Demo:

* The following message appears in the *Console* window of the xTIMEcomposer Studio::
        
   Switching on Wi-Fi module....

* At this point, the application is trying to switch ON the Wi-Fi module. After few seconds, the *Console* window is updated as::

   Switching on Wi-Fi module.... ok!
   Scanning available networks....
   
* The Wi-Fi module is now scanning for available wireless networks and will list its results as::

   Switching on Wi-Fi module.... ok!
   Scanning available networks....
   testap1
   testap2
   testap3
   testwifirouter
   ----end----

* The Wi-Fi module is now finishing off scanning and will begin to connect to your network. Note that the IP address acquired may be different based on your network::   

   Switching on Wi-Fi module.... ok!
   Scanning available networks....
   testap1
   testap2
   testap3
   testwifirouter
   ----end----
   Connecting to testwifirouter
   IP Address: 192.168.1.100

* Open a web browser (Firefox, etc...) in your host computer and enter the above IP address in the address bar of the browser. It opens a web page as hosted by the simple webserver running on the XMOS device.

.. figure:: images/webpage.*

   Page hosted by webserver running on XMOS device

* Use the web page options to perform various actions such as:

   #. Switch on all the LEDS by turning them all to 'ON' in the browser then clicking Submit. The LEDS should light, the ADC temperature display should be updated, and the web page will report no buttons have been pressed.
   #. Switch off two of the LEDS by turning two to 'OFF' in the browser then clicking Submit. Two LEDS should go out and the ADC temperature is reported again. This time also web page will report no buttons have been pressed.
   #. Press SW1 button on the GPIO slice card and then press submit. The web page should now report that Button 1 is pressed.
   #. Press SW2 button on the GPIO slice card and then press submit. The web page should now report that Button 2 is pressed.
   #. Just hitting Submit now displays both the buttons are not pressed. LEDs states remain unchanged unless they are explicitly changed on the web page.
    
Next Steps
----------

**Look at the Code**

* Examine the application code. In the xTIMEcomposer Studio, navigate to the ``src`` directory under ``app_sk_gpio_wifi_tiwisl_combo_demo`` and double click on the main.xc file within it. The file will open in the central editor window.
* The channel ``c_gpio`` is used between web page handler and application handler to send web page requests to the application and to collect GPIO status from the application.
* In the app_handler.xc file, API ``set_gpio_state`` is used by the web page in order to apply web page LED settings and similarly API ``get_gpio_state`` is used by web page to collect the current GPIO status containing LEDs, button presses and ADC temperature values.
* GPIO button scan logic monitors for value changes on the configured 4-bit button port (XS1_PORT_4C) in the application handler routine as defined in the app_handler.xc file. Whenever this port value changes, GPIO button states are updated accordingly.
* You can also observe that the ADC value is read whenever there is a web page request. This value is interpolated to get a proper temperature value and is updated in the GPIO state structure before sending it to the web page.
