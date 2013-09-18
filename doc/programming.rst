.. _sec_api:

Programming Guide
=================

Simple Demo
-----------

Structure
+++++++++

All of the files required for operation are located in the ``app_sk_gpio_simple_demo/src`` directory. The files that are need to be included for use of this component in an application are:

.. list-table::
    :header-rows: 2
    
    * - File
      - Description
    * - ``common.h``
      - Header file for API interfaces and Look up tables for thermistor.
    * - ``main.xc``
      - Main file which implements the demo functionality

API
+++

.. doxygenfunction:: app_manager
.. doxygenfunction:: linear_interpolation
.. doxygenfunction:: read_adc_value

Usage and Implementation
++++++++++++++++++++++++

The port declaration for the LEDs, Buttons and I2C are declared as below. LEDs and Buttons use 4 bit ports and I2C uses 1 bit port for SCL(I2c Clock) and SDA (I2C data).

.. literalinclude:: app_sk_gpio_simple_demo/src/main.xc
   :start-after: //::Port configuration
   :end-before: //::Ports

The app_manager API writes the configuration settings information to the ADC as shows below.

.. literalinclude:: app_sk_gpio_simple_demo/src/main.xc
   :start-after: //::Write config
   :end-before: //::Config

The select statement in the app_manager API selects one of the two cases in it, checks if there is IO event or timer event. This statement monitors both the events and executes which ever event is occurred first.  
The select statement in the application is listed below. The statement checks if there is button press or not. If there is button press then it looks if the button state is same even after 20msec. If the buton state is same then it recognises as an valid push.

.. literalinclude:: app_sk_gpio_simple_demo/src/main.xc
   :start-after: //::Select start
   :end-before: //::Select

After recognising the valid push then it checks if Button 1 is pressed or Button 2 is pressed. IF Button 1 is pressed then, the application reads the status of LEDs and shift the position of the LEDs to left by 1.
If Button 2 is pressed, then the applciation reads the contents of ADC register using I2C read instruction and input the ADC value to linear interpolation function as shown below.

.. literalinclude:: app_sk_gpio_simple_demo/src/main.xc
   :start-after: //::Linear Interpolation
   :end-before: //::Linear

The linear intepolation function calculates the linear interpolation value using the following formula and returns the temperature value from temperature look up table.

.. literalinclude:: app_sk_gpio_simple_demo/src/main.xc
   :start-after: //::Formula start
   :end-before: //::Formula
 
.. literalinclude:: app_sk_gpio_simple_demo/src/main.xc
   :start-after: //::LUT start
   :end-before: //::LUT




COM Port Demo
-------------

Structure
+++++++++

All of the files required for operation are located in the ``app_slicekit_simple_demo/src`` directory. The files that are need to be included for use of this component in an application are:

.. list-table::
    :header-rows: 2
    
    * - File
      - Description
    * - ``temp_sensor.xc``
	  - File contains information about reading the ADC values from the temperature sensor using the I2C interface and calculating the accurate values using Linear Interpolation. 
    * - ``main.xc``
      - Main file which implements the demo functionality

API
+++

.. doxygenfunction:: temp_sensor


Usage and Implementation
++++++++++++++++++++++++

The port declaration for the LEDs, Buttons, I2C and UART are declared as below. LEDs and Buttons uses 4 bit ports, UART uses 1 bit ports both for Transmit and Receive and I2C uses 1 bit port for SCL(I2c Clock) and SDA (I2C data).

.. literalinclude:: app_sk_gpio_com_demo/src/main.xc
   :start-after: //::Ports Start
   :end-before: //::Ports

The led_server is a distributable task which does not run on a specific core. The led_server task changes the state of the LEDs based on the user input from the UART console.

.. literalinclude:: app_sk_gpio_com_demo/src/main.xc
   :start-after: //::LED Server
   :end-before: //::LED Server end

The button_counter is a distributable task which does not run on a specific core. The button_counter task counts the number of times each button 'Button 1' and 'Button 2' are pressed.

.. literalinclude:: app_sk_gpio_com_demo/src/main.xc
   :start-after: //::Button Start
   :end-before: //::Button

The button_handler is a distributable task which does not run on a specific core. The button_handler task cycles the LEDs on the slice when 'Button 1' is pressed and Displays the Temperature value when 'Button 2' is pressed.

.. literalinclude:: app_sk_gpio_com_demo/src/main.xc
   :start-after: //::Button Handler
   :end-before: //::Button Handler end
   
The command_handler function does action based on the command input from the terminal window. It receives an input from the terminal and checks if it is valid command or not. If the received command is valid command it executes the command.

.. literalinclude:: app_sk_gpio_com_demo/src/main.xc
   :start-after: //::Command Handler   
   :end-before: //::Command Handler end

   
The uart_handler is a combinable task which runs on a specific core. The uart_handler receives all the information from the terminal and based on the ode it echoes data back to the terminal to send a command to the command_handler function.
   
.. literalinclude:: app_sk_gpio_com_demo/src/main.xc
   :start-after: //::UART Handler
   :end-before: //::UART Handler end

The temp_sensor task gets the ADC value using I2C interface and calculates the temperature value from the temperature look up table using Linear Interpolation method.

 .. literalinclude:: app_sk_gpio_com_demo/src/temp_sensor.xc
    :start-after: //::TEMP sensor
    :end-before: //::TEMP sensor end

	
GPIO Ethernet Combo Demo
------------------------

Structure
+++++++++

All the files required for operation are located in the app_sk_gpio_eth_combo_demo/src directory. The files to be included for use of the dependent components are:

.. list-table::
    :header-rows: 1
    
    * - File
      - Description
    * - ``ethernet_board_support.h``
      - Defines OTP and ethernet pins required for Ethernet component
    * - ``xtcp.h``
      - Header file for xtcp API interface
    * - ``web_server.h``
      - Header file for web server API interface in order to use web pages
    * - ``i2c.h``
      - Defines i2c pins and API interface to use i2c master component for GPIO adc interfacing
    * - ``app_handler.h``
      - Application specific defines and API interface to implement demo functionality

API
+++

.. doxygenfunction:: app_handler
.. doxygenfunction:: process_web_page_data
.. doxygenfunction:: get_web_user_selection


Usage and Implementation
++++++++++++++++++++++++

The port declaration for Ethernet, LEDs, Buttons and I2C are declared as below:
   * Ethernet uses ethernet_board_support.h configuration
   * I2C uses 1 bit port for SCL(I2C Clock) and SDA (I2C data)
   * LEDs and Buttons uses 4 bit ports

.. literalinclude:: app_sk_gpio_eth_combo_demo/src/main.xc
   :start-after: //::Ports Start
   :end-before: //::Ports End

The app_manager API writes the configuration settings to the ADC as shows below

.. literalinclude:: app_sk_gpio_eth_combo_demo/src/app_handler.xc
   :start-after: //::ADC Config Start
   :end-before: //::ADC Config End

The select statement in the app_handler API selects either I/O events to check for any valid button presses or uses channel events to detect any commands from web page requests. Valid web page commands are either to set or reset LEDs and check button press state since last check request. 

Whenever there is a change in values of the button ports, a flag is used to kick start a timer for debounce interval, and port value is sampled to identify which button is pressed. The code is as shown below

.. literalinclude:: app_sk_gpio_eth_combo_demo/src/app_handler.xc
   :start-after: //::Button Scan Start
   :end-before: //::Button Scan End

Every time a web page request is received, app_handler records current ADC value and button press status and sends it to web page. 
Button check statuses are reset immediately after the web page request.


Using sc_website to build web page for this demo application
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

Makefile in app_sk_gpio_eth_combo_demo folder should include the following line:

WEBFS_TYPE = internal

This value indicates sc_website component to use program memory instead of FLASH memory to store the web pages.

As a next step, create ``web`` folder in app_sk_gpio_eth_combo_demo

In order to include any images to be displayed on the web page, create images folder as follows
app_sk_gpio_eth_combo_demo/web/images

For this application, we have created index.html web page using html script. This page uses XMOS logo from images folder. We have defined desired GPIO controls for LEDs in this web page. 

APIs that are required to be executed by the demo application should be enclosed between the tags ``{%`` and  ``%}``. These are to be defined in ``web_page_functions.c`` file.
For example, index.html contains
<p>{% read_temperature(buf, app_state, connection_state) %}</p>

This indicates ``read_temperature`` is a function executed by the program and result is returned to the web page. After execution, sc_website component replaces this function as 
<p>"Temperature recorded from onboard ADC: <b>NA </b><sup>o</sup>C"</p>



GPIO Wi-Fi Combo Demo
---------------------

Structure
+++++++++

All the files required for operation are located in the app_sk_gpio_wifi_tiwisl_combo_demo/src directory. The files to be included for use of the dependent components are:

.. list-table::
    :header-rows: 1
    
    * - File
      - Description
    * - ``wifi_tiwisl_server.h``
      - Header file for Wi-Fi API interface
    * - ``web_server.h``
      - Header file for web server API interface in order to use web pages
    * - ``i2c.h``
      - Defines i2c pins and API interface to use i2c master component for GPIO adc interfacing
    * - ``app_handler.h``
      - Application specific defines and API interface to implement demo functionality

API
+++

.. doxygenfunction:: app_handler
.. doxygenfunction:: process_web_page_data
.. doxygenfunction:: get_web_user_selection


Usage and Implementation
++++++++++++++++++++++++

The port declaration for Wi-Fi (SPI), LEDs, Buttons and I2C are declared as below:
   * Wi-Fi control uses 
        * 1 four-bit port for nCS(Chip Select) and Power enable
        * 1 one-bit port for nIRQ(interrupt) 
   * SPI uses 3 one-bit ports for MOSI, CLK and MISO
   * I2C uses 1 bit port for SCL(I2C Clock) and SDA (I2C data)
   * LEDs and Buttons use 4 bit ports

.. literalinclude:: app_sk_gpio_wifi_tiwisl_combo_demo/src/main.xc
   :start-after: //::Ports Start
   :end-before: //::Ports End

The app_manager API writes the configuration settings to the ADC as shows below

.. literalinclude:: app_sk_gpio_wifi_tiwisl_combo_demo/src/app_handler.xc
   :start-after: //::ADC Config Start
   :end-before: //::ADC Config End

The select statement in the app_handler API selects either I/O events to check for any valid button presses or uses channel events to detect any commands from web page requests. Valid web page commands are either to set or reset LEDs and check button press state since last check request. 

Whenever there is a change in values of the button ports, a flag is used to kick start a timer for debounce interval, and port value is sampled to identify which button is pressed. The code is as shown below

.. literalinclude:: app_sk_gpio_wifi_tiwisl_combo_demo/src/app_handler.xc
   :start-after: //::Button Scan Start
   :end-before: //::Button Scan End

Every time a web page request is received, app_handler records current ADC value and button press status and sends it to web page. 
Button check statuses are reset immediately after the web page request.


Using sc_website to build web page for this demo application
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

Makefile in app_sk_gpio_wifi_tiwisl_combo_demo folder should include the following line:

WEBFS_TYPE = internal

This value indicates sc_website component to use program memory instead of FLASH memory to store the web pages.

As a next step, create ``web`` folder in app_sk_gpio_wifi_tiwisl_combo_demo

In order to include any images to be displayed on the web page, create images folder as follows
app_sk_gpio_wifi_tiwisl_combo_demo/web/images

For this application, we have created index.html web page using html script. We have defined desired GPIO controls for LEDs in this web page. 

APIs that are required to be executed by the demo application should be enclosed between the tags ``{%`` and  ``%}``. These are to be defined in ``web_page_functions.c`` file.
For example, index.html contains
<p>{% read_temperature(buf, app_state, connection_state) %}</p>

This indicates ``read_temperature`` is a function executed by the program and result is returned to the web page. After execution, sc_website component replaces this function as 
<p>"Temperature recorded from on-board ADC: <b>NA </b><sup>o</sup>C"</p>


