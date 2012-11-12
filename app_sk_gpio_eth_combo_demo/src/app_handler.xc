// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#include "app_handler.h"
#include <xccompat.h>

#define I2C_NO_REGISTER_ADDRESS	1
#define DEBOUNCE_INTERVAL	XS1_TIMER_HZ/50
#define BUTTON_1_PRESS_VALUE	0x2

typedef enum gpio_cmd_t {
  APP_HANDLER_SET_GPIO_STATE,
  APP_HANDLER_GET_GPIO_STATE,
  APP_HANDLER_RESET_BUTTON_STATE,
} gpio_cmd_t;

//Temperature to ADC look up table
int TEMPERATURE_LUT[][2]=
{
		{-10,850},{-5,800},{0,750},{5,700},{10,650},{15,600},{20,550},{25,500},{30,450},{35,400},
		{40,350},{45,300},{50,250},{55,230},{60,210}
};
gpio_state_t gpio_state;

void set_gpio_state(chanend c_gpio, gpio_state_t &data)
{
  c_gpio <: APP_HANDLER_SET_GPIO_STATE;
  c_gpio <: data;
}

void get_gpio_state(chanend c_gpio, gpio_state_t &data)
{
  c_gpio <: APP_HANDLER_GET_GPIO_STATE;
  c_gpio :> data;
}

void reset_gpio_button_state(chanend c_gpio, int button_id)
{
  c_gpio <: APP_HANDLER_RESET_BUTTON_STATE;
  c_gpio <: button_id;
}

static int linear_interpolation(int adc_value)
{
  int i=0,x1,y1,x2,y2,temperature;

  while(adc_value<TEMPERATURE_LUT[i][1]) {
	  i++;
  }
  //Calculating Linear interpolation using the formula y=y1+(x-x1)*(y2-y1)/(x2-x1)
  x1=TEMPERATURE_LUT[i-1][1];
  y1=TEMPERATURE_LUT[i-1][0];
  x2=TEMPERATURE_LUT[i][1];
  y2=TEMPERATURE_LUT[i][0];
  temperature=y1+(((adc_value-x1)*(y2-y1))/(x2-x1));
  return temperature;
}

// Read ADC value using I2C
static int read_adc_value(r_i2c &p_i2c)
{
  int adc_value;
  unsigned char i2c_data[2];

  i2c_master_rx(0x28, i2c_data, sizeof(i2c_data), p_i2c);

  i2c_data[0]=i2c_data[0]&0x0F;
  adc_value=(i2c_data[0]<<6)|(i2c_data[1]>>2);
  return adc_value;
}

void app_handler(chanend c_gpio, r_i2c &p_i2c, port p_led, port p_button) {
  unsigned char i2c_register[1] = {0x13};
  int scan_button_flag = 1;
  unsigned button_state_1 = 0;
  unsigned button_state_2 = 0;
  timer t_scan_button_flag;
  unsigned time;

//::ADC Config Start
  i2c_master_write_reg(0x28, 0x00, i2c_register, 1, p_i2c);
//::ADC Config End

  set_port_drive_low(p_button);
  t_scan_button_flag :> time;
  p_button :> button_state_1;

  while (1) {
    select {
//::Button Scan Start
      case scan_button_flag => p_button when pinsneq(button_state_1) :> button_state_1 :
    	t_scan_button_flag :> time;
    	scan_button_flag = 0;
      break;
      case !scan_button_flag => t_scan_button_flag when timerafter(time + DEBOUNCE_INTERVAL) :> void:
		p_button :> button_state_2;
		if(button_state_1 == button_state_2) {
		  if(button_state_1 == BUTTON_1_PRESS_VALUE)
			gpio_state.button_1 = 1;
		  if(button_state_2 == BUTTON_1_PRESS_VALUE-1)
			gpio_state.button_2 = 1;
		}
		scan_button_flag = 1;
      break;
//::Button Scan End
      case c_gpio :> int cmd:
        switch (cmd) {
          case APP_HANDLER_SET_GPIO_STATE: {
        	gpio_state_t gpio_new_state;
        	unsigned char led_state = 0x0F; //All LEDs in clear state

        	p_led:>led_state;
        	c_gpio :> gpio_new_state;

        	if (gpio_new_state.led_0) //Set LED 0
              led_state = led_state & 0xE;
        	else
              led_state = led_state | 0x1;

        	if (gpio_new_state.led_1)
        	  led_state = led_state & 0xD;
        	else
        	  led_state = led_state | 0x2;

        	if (gpio_new_state.led_2)
        	  led_state = led_state & 0xB;
        	else
        	  led_state = led_state | 0x4;

        	if (gpio_new_state.led_3)
        	  led_state = led_state & 0x7;
        	else
        	  led_state = led_state | 0x8;

        	gpio_state.led_0 = gpio_new_state.led_0;
        	gpio_state.led_1 = gpio_new_state.led_1;
        	gpio_state.led_2 = gpio_new_state.led_2;
        	gpio_state.led_3 = gpio_new_state.led_3;
        	p_led <: led_state;
          }
          break;
          case APP_HANDLER_GET_GPIO_STATE: {
        	int adc_value=read_adc_value(p_i2c);
        	gpio_state.temperature = linear_interpolation(adc_value);
        	c_gpio <: gpio_state;
          }
          break;
//::Button Reset Start
          case APP_HANDLER_RESET_BUTTON_STATE: {
        	int button_value = 0;
        	c_gpio :> button_value;
        	if (0b01 == button_value)
        	  gpio_state.button_1 = 0;
        	else if (0b10 == button_value)
        	  gpio_state.button_2 = 0;
        	else if (0b11 == button_value) {
        	  gpio_state.button_1 = 0;
        	  gpio_state.button_2 = 0;
        	}
          }
          break;
//::Button Reset End
        } //switch (cmd)
      break; //case c_gpio :> int cmd:
    } //select
  } //while (1)
}
