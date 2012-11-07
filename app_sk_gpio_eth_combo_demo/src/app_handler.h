// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#ifndef APP_HANDLER_H_
#define APP_HANDLER_H_
#include "i2c.h"

typedef struct gpio_state {
  int led_0;
  int led_1;
  int led_2;
  int led_3;
  int button_1;
  int button_2;
  int temperature;
} gpio_state_t;

void app_handler(chanend c_gpio, REFERENCE_PARAM(r_i2c, p_i2c), port p_led, port p_button);
void set_gpio_state(chanend c_gpio, REFERENCE_PARAM(gpio_state_t, gpio_new_state));
void get_gpio_state(chanend c_gpio, REFERENCE_PARAM(gpio_state_t, gpio_state));
void reset_gpio_button_state(chanend c_gpio, int button_id);

#endif /* APP_HANDLER_H_ */
