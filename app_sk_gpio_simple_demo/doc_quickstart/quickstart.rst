sw_gpio_examples simple demo : Quick Start Guide
------------------------------------------------

This simple demonstration of basic XCore processor and xTimeComposer Studio functionality uses the XA-SK-GPIO Slice Card together with the xSOFTip I2C Master component to:

   * communicate with the ADC (and external temperature sensing circuit) on the Slice Card
   * display the temperature value on the xTimeComposer debug console when a button is pressed
   * Cycle through the 4 LEDs on the Slice Card when another button is pressed

Hardware Setup
++++++++++++++

The XP-SKC-L2 Slicekit Core board has four slots with edge conectors: ``SQUARE``, ``CIRCLE``,``TRIANGLE`` and ``STAR``. 

To setup up the system:

   #. Connect XA-SK-GPIO Slice Card to the XP-SKC-L2 Slicekit Core board using the connector marked with the ``SQUARE``.
   #. Connect the XTAG Adapter to Slicekit Core board, and connect XTAG-2 to the adapter. 
   #. Connect the XTAG-2 to host PC via the provided USB cable.
   #. Switch on the power supply to the Slicekit Core board.

.. figure:: images/hardware_setup.png
   :align: center

   Hardware Setup for Simple GPIO Demo
   
	
Import and Build the Application
+++++++++++++++++++++

   #. Open xTimeComposer and check that it is operating in online mode
   #. Locate the app_sk_gpio_simple_demo item in the xSOFTip pane on the bottom left of the window and drag it into the Project Explorer window in the xTimeComposer. This should also cause the modules on which this application depends (in this case, module_i2c_master) to be imported as well. 
   #. Click on the app_sk_gpio_simple_demo item in the Explorer pane then click on the build icon (hammer) in the foo window. Check the console window to verify that the application has built successfully.

Use the Software
++++++++++++++++

   #. Open the XDE
   #. Choose *Run* |submenu| *Run Configurations*
   #. Double-click *XCore Application* to create a new configuration
   #. In the *Project* field, browse for `app_slicekit_com_demo`
   #. In the *C/C++ Application* field, click on 'Search Project' to find the compiled XE file. Select the compiled Debug binary and double click OK.
   #. Select the *XTAG-2* device in the `Target:` adapter list if not already selected.
   #. Click **Run**

Demo Application
++++++++++++++++

   #. Press Button 1 on the Slice Card. Each time the button is pressed, the application lights the next LEDs on the Slice Card and displays "Button 1 pressed" in the debug console within xTime Composer Studio. Press the button 5 or 6 times to verify the functionality.
   #. Press Button 2 on the Slice Card. This causes the current temperature value to be read from the ADC over the I2C bus and then reported on the debug console. Press the button a few times. 
   #. Do something to alter the temperature of the sensor (use freezer spray, or place your finger on it for a while). Press Button 2 again to verify that the changed temperature is reported.

.. figure:: images/Console.png
   :align: center

   Screenshot of Console window
    
Next Steps
++++++++++

   #. Examine the application code. In xTimeComposer navigate to the ``src`` directory under app_sk_gpio_simple_demo and double click on the main.xc file within it. The file should open in the central editor window.
      #. Find the main function and note that it runs the app_manager() function on a single thread. Confirm that there are no other threads running (e.g. only one function call within the par{}.
      #. Find the app_manager function within the same file and look at the ``select`` statement within it. What do you think this select statement is doing?  
   #. If you have a PC with a physical COM port, or a USB to Serial Uart cable you can run the extended version of this application which adds a UART to the application and allows the SliceCard and its buttons, LEDs and ADC to be controlled and interrogated from a serial terminal console on a host PC. See the quickstart guide for this application fort further information on running this extended demo.
   
