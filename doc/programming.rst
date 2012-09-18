.. _sec_api:

Programming Guide
=================

Simple Demo
-----------

Structure
+++++++++

All of the files required for operation are located in the ``app_slicekit_simple_demo/src`` directory. The files that are need to be included for use of this component in an application are:

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

FIXME: Add a section to cover:

- how the app initialises the i2c master (e.g. ports struct)
- how the app is structured to handle the button press events (select statements)


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

FIXME: Add a section to cover:

- once the large body of initialisation stuff between lines 108 and 150 of main.xc have been split up and commented, you can cover the basic sequence here
- how the app select is extended to handle rx events from uart (e.g. we test for presence of data in the rx channel). A few words explaining about how channels can be used in select statements is appropriate here.
- a bit about the program control flow - no need to go overboard, just a few words about program flow.

