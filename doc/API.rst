.. _sec_api:

Programming Guide
=================

The application can be to demonstrate basic functionality like LEDs, UART, Buttons and Flexibility of IO pins

Structure
---------

All of the files required for operation are located in the ``app_slicekit_com_demo/src`` directory. The files that are need to be included for use of this component in an application are:

.. list-table::
    :header-rows: 1
    
    * - File
      - Description
    * - ``common.h``
      - Header file for API interfaces and Look up tables for thermistor.
    * - ``main.xc``
      - Main file which has API definitions


API
---

.. doxygenfunction:: app_manager

.. doxygenfunction:: process_data

.. doxygenfunction:: uart_tx_string

.. doxygenfunction:: linear_interpolation

.. doxygenfunction:: read_adc_value

