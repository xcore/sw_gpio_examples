// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/*===========================================================================
 Filename: main.xc
 Project : app_slicekit_simple_demo
 Author : XMOS Ltd
 Version : 1v0
 Purpose : This file implements demostration of comport, LED's
  	  	   and ADC using GPIO slice
 -----------------------------------------------------------------------------

 ===========================================================================*/

/*---------------------------------------------------------------------------
 include files
 ---------------------------------------------------------------------------*/

#include<xs1.h>
#include<print.h>
#include "i2c.h"
#include<platform.h>
#include<string.h>

//#define AD7995_0 //define this in module_i2c_master
#define CORE_NUM 1
#define BUTTON_PRESS_VALUE 14

/*---------------------------------------------------------------------------
 ports and clocks
 ---------------------------------------------------------------------------*/
on stdcore[CORE_NUM]: out port p_led=PORT_ETH_RXD_2;
on stdcore[CORE_NUM]: in port p_PORT_BUT_1=PORT_ETH_MDIOC_2;
struct r_i2c i2cOne = {
		PORT_ETH_TXEN_2,
		PORT_ETH_RXCLK_2,
		1000
 };
/*---------------------------------------------------------------------------
 typedefs
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 global variables
 ---------------------------------------------------------------------------*/
int TEMPERATURE_LUT[][2]= //Temperature Look up table
{
		{-10,845},{-5,808},{0,765},{5,718},{10,668},{15,614},{20,559},{25,504},{30,450},{35,399},
		{40,352},{45,308},{50,269},{55,233},{60,202}
};

/*---------------------------------------------------------------------------
 static variables
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 implementation
 ---------------------------------------------------------------------------*/
 
/** =========================================================================
 * linear interpolation
 *
 * calculates temperatue basedd on linear interpolation
 *
 * \param int adc value
 *
 * \return int temperature
 *
 **/
int linear_interpolation(int adc_value)
{
	int i=0,x1,y1,x2,y2,temper;
	while(adc_value<TEMPERATURE_LUT[i][1])
	{
		i++;
	}
	//Calculating Linear interpolation using the formula y=y1+(x-x1)*(y2-y1)/(x2-x1)
	x1=TEMPERATURE_LUT[i-1][1];
	y1=TEMPERATURE_LUT[i-1][0];
	x2=TEMPERATURE_LUT[i][1];
	y2=TEMPERATURE_LUT[i][0];
	temper=y1+(((adc_value-x1)*(y2-y1))/(x2-x1));
	return temper;//Return Temperature value
}

/** =========================================================================
 * App Manager
 *
 * Reads button values and Cycle LEDs on button press and Read temperature value from ADC
 *
 * \param None
 *
 * \return None
 *
 **/
void app_manager()
{
	unsigned button1,button2,time,time1;
	int button =1,index=0,toggle=0;
	timer t;
	unsigned char data[1]={0x13};
	unsigned char data1[2];
	int adc_value;
	unsigned led_value=0x01;
	p_PORT_BUT_1:> button1;
	i2c_master_write_reg(0x28, 0x00, data, 1, i2cOne);
	t:>time;

	while(1)
	{

		select
		{
			case button => p_PORT_BUT_1 when pinsneq(button1):> button1:
				button=0;
				break;

			case !button => t when timerafter(time+20000000):>time:
				p_PORT_BUT_1:> button1;
				if(button1 == BUTTON_PRESS_VALUE)
				{
					printstrln("Button 1 Pressed");
					p_led<:(led_value);
					led_value=led_value<<1;
					if(led_value == 16)
					{
						led_value=0x01;
					}
				}
				if(button1 == BUTTON_PRESS_VALUE-1)
				{
					data1[0]=0;data1[1]=0;
					i2c_master_rx(0x28, data1, 2, i2cOne);
					printstrln("Reading Temperature value....");
					data1[0]=data1[0]&0x0F;
					adc_value=(data1[0]<<6)|(data1[1]>>2);
					printstr("Temperature is :");
					printintln(linear_interpolation(adc_value));
				}

				button=1;
				break;
		}
	}
}

/** =========================================================================
 * Dummy
 *
 * Use all Threads on a core
 *
 * \param None
 *
 * \return None
 *
 **/
void dummy()
{
	while (1);
}


/**
 * Top level main for multi-UART demonstration
 */
int main(void)
{
	par
	{
		on stdcore[CORE_NUM]: app_manager();
		on stdcore[CORE_NUM]: dummy();
		on stdcore[CORE_NUM]: dummy();
		on stdcore[CORE_NUM]: dummy();
		on stdcore[CORE_NUM]: dummy();
		on stdcore[CORE_NUM]: dummy();
		on stdcore[CORE_NUM]: dummy();
		on stdcore[CORE_NUM]: dummy();
	}
	return 0;
}


