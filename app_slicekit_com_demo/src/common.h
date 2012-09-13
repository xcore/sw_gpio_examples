// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/*===========================================================================
Filename: common.h
Project : app_slicekit_com_demo
Author : XMOS Ltd
Version : 1v0
Purpose : This file delcares interfaces required for app manager
thread to communicate with process data thread
-----------------------------------------------------------------------------

===========================================================================*/

/*---------------------------------------------------------------------------
include files
---------------------------------------------------------------------------*/
#ifndef _common_h_
#define _common_h_

/*---------------------------------------------------------------------------
constants
---------------------------------------------------------------------------*/
#define BAUD_RATE 115200

/*---------------------------------------------------------------------------
typedefs
---------------------------------------------------------------------------*/
typedef enum{
SET_LED_1,
SET_LED_2,
SET_LED_3,
SET_LED_4,
CLEAR_LED_1,
CLEAR_LED_2,
CLEAR_LED_3,
CLEAR_LED_4,
SET_ALL,
CLEAR_ALL,
CHK_BUTTONS,
EXIT,
HELP,
READ_ADC,
BUTTON_PRESSED,
BUTTON_1,
BUTTON_2,
INVALID
};

/*---------------------------------------------------------------------------
extern variables
---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
global variables
---------------------------------------------------------------------------*/
int TEMPERATURE_LUT[][2]={
		{-10,845},{-5,808},{0,765},{5,718},{10,668},{15,614},{20,559},{25,504},
		{30,450},{35,399},{40,352},{45,308},{50,269},{55,233},{60,202}
};

/*---------------------------------------------------------------------------
prototypes
---------------------------------------------------------------------------*/
int linear_interpolation(int adc_value);
int read_adc_value();

void receive(chanend c_receive, chanend c_uartRX);
void app_manager(chanend c_uartTX,chanend c_chanRX,chanend c_process, chanend c_end);
void process_data(chanend c_process, chanend c_end);
void uart_tx_string(chanend c_uartTX,unsigned char message[100]);

#endif// _common_h_
