GPIO Com Port Demo Quickstart Guide
===================================

.. _Slicekit_GPIO_COM_port_Demo_Quickstart:

sw_gpio_examples COM Port demo : Quick Start Guide
--------------------------------------------------

In this example, we use the XA-SK-GPIO Slice Card together with the xSOFTip UART to create a UART , and send data to and from a PC COM port. 
We also use xSOFTip I2C software component to communicate with on board ADC. 
This application showcases some of the key software features and serves as an example of how to use APIs of UART and I2C components. 
This demo features UART data loop back, receives commands from a comport, and performs according to the command input.

Install Demonstration Tools on the Host PC
++++++++++++++++++++++++++++++++++++++++++

The following tools should be installed on the host system in order to run this application

    * For Win 7: Hercules Setup Utility by HW-Group
      http://www.hw-group.com/products/hercules/index_en.html
    * For MAC users: SecureCRT7.0 
      http://www.vandyke.com/download/securecrt/
    * For Linux Users: Try cutecom (http://cutecom.sourceforge.net/) or try `sudo apt-get install cutecom`

Hardware Setup
++++++++++++++

The XP-SKC-L2 Slicekit Core board has four slots with edge conectors: ``SQUARE``, ``CIRCLE``, ``TRIANGLE`` and ``STAR``. 

To setup up the system refer to the figure and instructions below 

   #. Connect XA-SK-GPIO Slice Card to the XP-SKC-L2 Slicekit Core board using the connector marked with the ``SQUARE``.
   #. Connect the XTAG Adapter to Slicekit Core board, and connect XTAG-2 to the adapter. 
   #. Connect the XTAG-2 to host PC. Note that a USB cable is not provided with the Slicekit starter kit.
   #. Switch on the power supply to the Slicekit Core board.
   #. Connect a null serial cable to DB-9 connector on XA-SK-GPIO Slice Card. The cable will need a cross over between the UART RX and TX pins at each end.
   #. Connect the other end of the cable to the Host DB-9 connector slot. If the Host does not have an DB-9 Connector slot then use the USB-UART cable for the demo. We used the BF-810 USB to Uart adapter (See http://www.bafo.com/products_bf-810_S.asp (Part number : BF-810), any other usb to uart bridge should do just as well.
   #. Identify the serial (COM) port number provided by the Host or the USB to UART adapter and open suitable terminal software for the selected serial port (refer to the Hercules or SecureCRT documentation above).
   #. Configure the host terminal console program as follows: 115200 baud, 8 bit character length, even parity, 1 stop bit, no hardware flow control. The Transmit End-of-Line character should be set to `CR` (other options presented will probably be `LF` and `CR\LF`).
   #. Connect XA-SK-GPIO Slice Card to the XP-SKC-L2 Slicekit Core board. 
   #. Connect the XTAG Adapter to Slicekit Core board, XA-SK-XTAG2 connector(xtag slice) and connect XTAG-2 to the adapter. 
   #. Connect the XTAG-2 to the computer running xTIMEcomposer.
   #. Switch on the power supply to the Slicekit Core board.
   #. Open the serial device on the host console program
   
.. figure:: images/hardware_setup.png
   :align: center

   Hardware Setup for GPIO COM Port Demo 


Import and Build the Application
++++++++++++++++++++++++++++++++

   #. Open xTIMEcomposer, then open the edit perspective (Window->Open Perspective->XMOS Edit).
   #. Locate the ``'Slicekit COM Port GPIO Demo'`` item in the xSOFTip Broswer window and drag it into the Project Explorer window in the xTIMEcomposer. This will also cause the modules on which this application depends (in this case, module_i2c_master, module_uart_rx and module_uart_tx) to be imported as well. 
   #. Click on the Slicekit COM Port GPIO Demo item in the Explorer pane then click on the build icon (hammer) in xTIMEcomposer. Check the console window to verify that the application has built successfully.

For help in using xTIMEcomposer, try the xTIMEcomposer tutorials, which you can find by selecting Help->Tutorials from the xTIMEcomposer menu.

Note that the Developer Column in the xTIMEcomposer on the right hand side of your screen provides information on the xSOFTip components you are using. Select the ``generic UART Receiver``  component in the xSOFTip Browser, and you will see its description together with links to more documentation for this component. Once you have briefly explored this component, you can return to this quickstart guide by re-selecting  ``'Slicekit COM Port GPIO Demo'`` in the xSOFTip Browser and clicking once more on the Quickstart  link for the ``Slicekit Com Port GPIO Demo Quickstart``.
    

Running the Demo
++++++++++++++++

   #. Click on the ``Run`` icon (the white arrow in the green circle). A dialog will appear asking which device to connect to. Select ``XMOS XTAG2``. 
   #. Look at the configured terminal client application console on the Host.
   #. If the terminal is configured correctly, it should display the following message: ``WELCOME TO GPIO DEMO (**ECHO DATA MODE ACTIVATED**)``. In this mode any character typed in from the key board is echoed back. Verify this by typing characters in the terminal console on the host. The typed characters should be echoed back.
   #. When ready, enter command mode by typing ``>cmd`` (note, be sure to also type the '>' character). The Console will then show  **COMMAND MODE ACTIVATED**.
   #. Type ``help`` in the console window. The help menu will be displayed as sown in the figure below.

.. figure:: images/help_menu.png
   :align: center

   Screenshot of Hyperterminal window

   #. Type ``setall` in the console to switch ON all the LEDs.
   #. Type ``clearall`` to switch OFF all the LEDs.
   #. Type ``setled N`` for switching ON a particular LED. 'N' ranges from 1 to 4.
   #. Type ``clearled N`` for switching OFF a particular LED. 'N' ranges from 1 to 4.
   #. Type in ``chkbuttons`` to return the status of buttons since last 'chkbuttons' command. The console should display ``COMMAND EXECUTED NO BUTTONS ARE PRESSED``.
   #. Press a button on the Slice Card. The console should display ``COMMAND EXECUTED BUTTON 1 PRESSED`` or ``COMMAND EXECUTED BUTTON 2 PRESSED``
   #. Type in ``chkbuttons`` again. The console should display ``COMMAND EXECUTED BUTTON 1 PRESSED``.
   #. Type in ``readadc`` for readig ADC value and displaying current temperature. The console should display ``CURRENT TEMPERATURE VALUE IS : <temperature> C``.
   #. Type in ``exit`` to leave command mode and go back to ECHO DATA MODE. Verify that once again, typed characters are simply echoed back.
    
Next Steps
++++++++++

Look at the Code
................

   #. Examine the application code. In xTIMEcomposer navigate to the ``src`` directory under app_sk_gpio_com_demo and double click on the main.xc file within it. The file will open in the central editor window.
   #. This code is quite a bit more complex than the GPIO Simple Demo, since more complex user input must be obtained from the UART and processed. 
   #. Find the part of the code which is processing command input from the host console. Check how the Generic UART RX and TX APIs from the General Uart Component library are being applied. As part of this exercise, locate the documentation for these components (``Generic UART Receiver`` and ``Generic UART Transmitter``) in the xSOFTip explorer pane of xTIMEcomposer and review their API documentation. 

More complex Serial Bridging Applications
.........................................

This application uses just one UART which takes up two logical cores. Take a look at the Multi-Uart Component in the xSOFTip Explorer. This fits 8 Uarts into two logical cores. Have a look at the documentation for that component and how its API differs from the stand alone General Uart. 

XMOS has also implemented a reference solution for an Ethernet to Serial bridge offering many features including dynamic reconfiguration, an embedded webserver and 8 uarts running up to 115KBaud. To get access to this solution, buy the XA-SK-UART-8 Multi Uart Slice Card from digikey and contact your sales representative to get the reference code.
