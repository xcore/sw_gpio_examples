sw_gpio_examples simple demo : Quick Start Guide
--------------------------------------------------

We use the XA-SK-GPIO Slice Card together with the xSOFTip I2C to communicate with on board ADC, and display the temperature value on the console.
This application showcases some of the key software features and serves as an example on how to use ``module_i2c_master`` and push button switches and LEDs. 

Hardware Setup
++++++++++++++++++
The XP-SKC-L2 Slicekit Core board has four slots ``SLOT SQUARE``, ``SLOT CIRCLE``,``SLOT TRIANGLE`` and ``SLOT STAR``. 
The XA-SK-GPIO Slice Card have Four LED's, Thermistor, Two Push Button Switches and an ADC.
The XA-SK-GPIO Slice Card have to be plugged in to the ``SLOT SQUARE``.

   Details of slice kit modular system and slices are availaible in the following link,
   https://github.com/xmos/hw_slicekit_system.git.

   #. Connect XA-SK-GPIO Slice Card to the XP-SKC-L2 Slicekit Core board. 
   #. Connect the XTAG Adapter to Slicekit Core board, XA-SK-XTAG2 connector(xtag slice) and connect XTAG-2 to the adapter. 
   #. Connect the XTAG-2 to host PC.
   #. Switch on the power supply to the Slicekit Core board.

.. figure:: images/hardware_setup.png
   :align: center

   Hardware Setup for Simple GPIO Demo
   
Software Configuration
++++++++++++++++++++++
        
   #. Define AD7995_0 in module_i2c_master (#define AD7995_0)
	
Build the Application
+++++++++++++++++++++

The following components are required to build ``app_slicekit_simple_demo`` application:
    * sc_i2c:  https://github.com/xcore/sc_i2c.git

   #. Clone the above repositroes or download them as zipfile packages.
   #. Open the XDE (XMOS Development Tools - latest version as of this writing is 11.11.1) and Choose `File` |submenu| `Import`.
   #. Choose `General` |submenu| `Existing Projects into Workspace` and click **Next**.
   #. Click **Browse** next to `Select archive file` and select the first firmware ZIP file.
   #. Click **Finish**.
   #. To build, select `app_slicekit_com_demo` from `sw_gpio_examples` folder in the Project Explorer pane and click the **Build** icon.   

Use the Software
++++++++++++++++

   #. Open the XDE
   #. Choose *Run* |submenu| *Run Configurations*
   #. Double-click *XCore Application* to create a new configuration
   #. In the *Project* field, browse for `app_slicekit_com_demo`
   #. In the *C/C++ Application* field, browse for the compiled XE file
   #. Select the *XTAG-2* device in the `Target:` adapter list
   #. Click **Run**

Demo Application
++++++++++++++++

   #. Pressing Button 1 cycles on board LEDs and displays Button pressed on the console.
   #. Pressing Button 2 displays current temperature value on the console.
   

.. figure:: images/Console.png
   :align: center

   Screenshot of Console window
    
Next Steps
++++++++++

   #. Refer to the module_i2c_master documentation for implementation details of this application and information on further things to try.
   
