.. _sec_api:

Programming guide
=================

Simple demo
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

Usage and implementation
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
    * - ``common.h``
      - Header file for API interfaces and Look up tables for thermistor. FIXME - what about the uart
    * - ``main.xc``
      - Main file which implements the demo functionality

API
+++

.. doxygenfunction:: app_manager
.. doxygenfunction:: process_data
.. doxygenfunction:: uart_tx_string
.. doxygenfunction:: linear_interpolation
.. doxygenfunction:: read_adc_value


Usage and Implementation
++++++++++++++++++++++++

The port declaration for the LEDs, Buttons, I2C and UART are declared as below. LEDs and Buttons uses 4 bit ports, UART uses 1 bit ports both for Transmit and Receive and I2C uses 1 bit port for SCL(I2c Clock) and SDA (I2C data).

.. literalinclude:: app_sk_gpio_com_demo/src/main.xc
   :start-after: //::Ports start
   :end-before: //::Ports

The app_manager API writes the configuration settings information to the ADC as shows below.

.. literalinclude:: app_sk_gpio_com_demo/src/main.xc
   :start-after: //::Config start
   :end-before: //::Config

The select statement in the app_manager API selects one of the three cases in it, checks if there is IO event or timer event or any event on the Uart Receive pin. This statement monitors all the events and executes which ever event is occurred first.  
The select statement in the applciation is listed below. The statement checks if there is button press or availability of data on the Uart Receive pin. If there is button press then it looks if the button state is same as even after 200msec. If the buton state is same then it recognises as a valid push.
If there is data on the Uart Receive pin the it echoes the data back to the uart Transmit pin until ``>`` character is received in the input data.

.. literalinclude:: app_sk_gpio_com_demo/src/main.xc
   :start-after: //::Select start
   :end-before: //::Select

If the received data is ``>`` character the it waits to see if the next received successive bytes are ``c``, ``m`` and ``d``. If the successive received data is ``>cmd`` then the application activates comman mode otherwise the data is echoed back to the Uart Transmit pin. The part of code which explains about the command mode is as blow.

.. literalinclude:: app_sk_gpio_com_demo/src/main.xc
   :start-after: //::Command start
   :end-before: //::Command

After the command mode is active the applicaion receives all the input commands and send to the process_data API using a channel.The part of the code is shown below.

.. literalinclude:: app_sk_gpio_com_demo/src/main.xc
   :start-after: //::Send to process start
   :end-before: //::Send

The process_data thread checks if any button is pressed or checks if there is any command from app_manager thread. If there is button press then the thread sends instructions to the app_manager thread about the button or if command is received, then  it send instructions about teh command received. 
The details in the process_data thread is as shown below.

.. literalinclude:: app_sk_gpio_com_demo/src/main.xc
   :start-after: //::Select in process start
   :end-before: //::Select
   
Process_data thread send instructions to the app_manager thread about the command received. The app_manager thread then implementys the state machine according to the instructions received from the process_data thread. The state machine of app_manager thread is as below.

.. literalinclude:: app_sk_gpio_com_demo/src/main.xc
   :start-after: //::State machine start
   :end-before: //::State
 
 The state machine has states as described below. The state details are available in the quick starter guide of the applications.
 
 .. literalinclude:: app_sk_gpio_com_demo/src/common.h
    :start-after: //::States start
    :end-before: //::States




Gpio ethernet combo demo
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


Usage and implementation
++++++++++++++++++++++++

The port declaration for ethernet, LEDs, buttons and i2c are declared as below:
   * Ethernet uses ethernet_board_support.h configuration
   * i2c uses 1 bit port for SCL(i2c clock) and SDA (i2c data)
   * LEDs and buttons uses 4 bit ports

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

For this application, we have created index.html web page using html script. This page uses XMOS logo from images folder. We have defined desired gpio controls for LEDs in this web page. 

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


