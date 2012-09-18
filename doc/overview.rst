Overview
========

The repository explains about the compatability of slice kit core board and demostration of GPIO slice card. Demonstrates about the basic functionality like LEDs, ADC and UART.

Features
--------

This application provides the following functionality. All options are dynamically reconfigurable via the APIs for app_slicekit_com_demo application.

.. list-table::
    :header-rows: 1
    
    * - Function
      - Operational Range
      - Notes
    * - Baud Rate
      - 150 to 115200 bps
      - 
    * - Parity
      - None, Mark, Space, Odd, Even
      - 
    * - Stop Bits
      - 1,2
      -
    * - Data Length
      - 1 to 30 bits
      - Max 30 bits assumes 1 stop bit and no parity.

    #. Switches ON LEDs up on button press and Cycles the LEDs on each button Press.
    #. Displays temperature value on the Console.
    

Slicekit Compatibility (XA-SK-UART8) 
------------------------------------

.. image:: images/Compatable_to_all.png
    :align: left


This application is demonstrated to work with the XA-SK-GPIO Slice Card which has the slot compatitbility shown above.


