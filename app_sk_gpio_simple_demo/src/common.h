// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/*===========================================================================
Filename: common.h
Project : app_slicekit_simple_demo
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

/*---------------------------------------------------------------------------
typedefs
---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
extern variables
---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
global variables
---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
prototypes
---------------------------------------------------------------------------*/
/**
* Polling push button switches and check which switch is pressed
* @return	None
*/
void app_manager();

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
