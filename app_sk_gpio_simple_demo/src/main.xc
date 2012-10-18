// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/*===========================================================================
 Filename: main.xc
 Project : app_slicekit_simple_demo
 Author : XMOS Ltd
 Version : 1v0
 Purpose : This file implements demostration of LED's, Push button switches
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
#include"common.h"

#define I2C_NO_REGISTER_ADDRESS 1
#define debounce_time XS1_TIMER_HZ/50
#define CORE_NUM 1
#define BUTTON_PRESS_VALUE 2

/*---------------------------------------------------------------------------
 ports and clocks
 ---------------------------------------------------------------------------*/
 //::Port configuration
on stdcore[CORE_NUM]: out port p_led=XS1_PORT_4A;
on stdcore[CORE_NUM]: port p_PORT_BUT_1=XS1_PORT_4C;
on stdcore[CORE_NUM]: struct r_i2c i2cOne = {
		XS1_PORT_1F,
		XS1_PORT_1B,
		1000
 };
 //::Ports
/*---------------------------------------------------------------------------
 typedefs
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 global variables
 ---------------------------------------------------------------------------*/
//::LUT start
int TEMPERATURE_LUT[][2]= //Temperature Look up table
{
		{-10,845},{-5,808},{0,765},{5,718},{10,668},{15,614},{20,559},{25,504},{30,450},{35,399},
		{40,352},{45,308},{50,269},{55,233},{60,202}
};
//::LUT
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
//::Linear Interpolation
int linear_interpolation(int adc_value)
{
	int i=0,x1,y1,x2,y2,temper;
	while(adc_value<TEMPERATURE_LUT[i][1])
	{
		i++;
	}
//::Formula start
	//Calculating Linear interpolation using the formula y=y1+(x-x1)*(y2-y1)/(x2-x1)
//::Formula
	x1=TEMPERATURE_LUT[i-1][1];
	y1=TEMPERATURE_LUT[i-1][0];
	x2=TEMPERATURE_LUT[i][1];
	y2=TEMPERATURE_LUT[i][0];
	temper=y1+(((adc_value-x1)*(y2-y1))/(x2-x1));
	return temper;//Return Temperature value
}
//::Linear
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
	unsigned button_press_1,button_press_2,time,time1;
	int button =1,index=0,toggle=0;
	timer t;
	unsigned char data[1]={0x13};
	unsigned char data1[2];
	int adc_value;
	unsigned led_value=0x0E;
	p_PORT_BUT_1:> button_press_1;
	set_port_drive_low(p_PORT_BUT_1);
//::Write config
	i2c_master_write_reg(0x28, 0x00, data, 1, i2cOne); //Write configuration information to ADC
//::Config
	t:>time;
	printstrln("** WELCOME TO SIMPLE GPIO DEMO **");
	while(1)
	{
//::Select start
		select
		{
			case button => p_PORT_BUT_1 when pinsneq(button_press_1):> button_press_1: //checks if any button is pressed
				button=0;
				t:>time;
				break;

			case !button => t when timerafter(time+debounce_time):>void: //waits for 20ms and checks if the same button is pressed or not
				p_PORT_BUT_1:> button_press_2;
				if(button_press_1==button_press_2)
				if(button_press_1 == BUTTON_PRESS_VALUE) //Button 1 is pressed
				{
					printstrln("Button 1 Pressed");
					p_led<:(led_value);
					led_value=led_value<<1;
					led_value|=0x01;
					led_value=led_value & 0x0F;
					if(led_value == 15)
					{
						led_value=0x0E;
					}
				}
				if(button_press_1 == BUTTON_PRESS_VALUE-1) //Button 2 is pressed
				{
					data1[0]=0;data1[1]=0;
					i2c_master_rx(0x28, data1, 2, i2cOne); //Read ADC value using I2C read 
					printstrln("Reading Temperature value....");
					data1[0]=data1[0]&0x0F;
					adc_value=(data1[0]<<6)|(data1[1]>>2);
					printstr("Temperature is :");
					printintln(linear_interpolation(adc_value));
				}

				button=1;
				break;
		}
//::Select
	}
}

/**
 * Top level main for multi-UART demonstration
 */
 //::Main start
int main(void)
{
	par
	{
		on stdcore[CORE_NUM]: app_manager();
	}
	return 0;
}

//::Main
