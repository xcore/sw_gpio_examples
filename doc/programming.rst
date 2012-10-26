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


