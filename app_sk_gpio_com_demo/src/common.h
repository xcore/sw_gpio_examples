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
//::States start
enum {
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
//::States
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

unsigned char CONSOLE_MESSAGES[16][110]=
	{
	 "\r\nCOMMAND MODE ACTIVATED",
	 "\r\nEXIT COMMAND MODE\r\n",
	 "\r\nINVALID COMMAND - Use 'help' for details",
	 "\r\nCOMMAND EXECUTED",
	 "\r\nBUTTON x PRESSED",
	 "\r\nNO BUTTONS ARE PRESSED",
	 "\r\nWELCOME TO GPIO DEMO",
	 "\r\n setall \t- Sets all LEDs ON\r\n clearall \t- Clear all LEDs",
	 "\r\n setled 'N' \t- Switch ON LED N",
	 "\r\n help \t\t- Display all supported commands",
	 "\r\n chkbuttons \t- Returns if any buttons pressed since last 'chkbuttons' command",
	 "\r\n readadc \t- Read ADC vaue and Displays temperature\r\n\r\n 'N' is in range 1 to 4",
	 "\r\nCURRENT TEMPERATURE VALUE IS : ",
	 "\r\n(**ECHO DATA MODE ACTIVATED**)\r\nPress '>cmd' for command mode\r\n",
	 "\r\n\r\n-------------------------HELP--------------------------------",
	 "\r\n clearled 'N' \t- Switch OFF LED 'N'\r\n exit \t\t- Exit from Command mode"
	};
/*---------------------------------------------------------------------------
prototypes
---------------------------------------------------------------------------*/
/**
* Polling uart RX and push button switches and send received commands to
* process_data thread
* @param	c_uartTX 	Channel to Uart TX Thread
* @param	c_chanRX 	Channel to Uart RX Thread
* @param	c_process 	Channel to process data Thread
* @param	c_end 		Channel to read data from process thread
*/
void app_manager(chanend c_uartTX,chanend c_chanRX,chanend c_process, chanend c_end);

/**
* process received data to see if received data is valid command or not
* Polling switches to see for button press
* @param	c_process 	Channel to receive data from app manager Thread
* @param	c_end 		Channel to communicate to app manager thread
*/
void process_data(chanend c_process, chanend c_end);

/**
* Transmits byte by byte to the UART TX thread for an input string
* @param	c_uartTX 	Channel to receive data from app Uart TX Thread
* @param	message 	Buffer to store array of characters
*/
void uart_tx_string(chanend c_uartTX,unsigned char message[100]);

/**
* Calculates temperatue based on linear interpolation
* @param	adc_value 	int value read from ADC
* @return	Returns linear interpolated Temperature value
*/
int linear_interpolation(int adc_value);

/**
* Read ADC value using I2C
* @return	Returns ADC value
*/
int read_adc_value();

#endif// _common_h_
