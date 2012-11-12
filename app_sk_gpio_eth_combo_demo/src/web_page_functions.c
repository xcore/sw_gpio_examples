// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#include "simplefs.h"
#include "app_handler.h"
#include "web_server.h"
#include <stdlib.h>
#include <string.h>
#include "xccompat.h"

typedef struct app_state_t {
  chanend c_gpio;
  gpio_state_t gpio_data;
  int button_id;
} app_state_t;

static app_state_t app_state;

void init_web_state(chanend c_gpio) {
  app_state.c_gpio = c_gpio;
  web_server_set_app_state((int) &app_state);
}

int process_web_page_data(char buf[], int app_state, int connection_state)
{
  char * user_choice;
  chanend c_gpio = (chanend) ((app_state_t *) app_state)->c_gpio;

  if (!web_server_is_post(connection_state))
    return 0;

  user_choice = web_server_get_param("l0", connection_state);
  if (!user_choice || !(*user_choice)) {
    char selstr[] = "Error in parsing web page variables";
    strcpy(buf, selstr);
    return strlen(selstr);
  } else
	((app_state_t *) app_state)->gpio_data.led_0 = atoi(user_choice);

  user_choice = web_server_get_param("l1", connection_state);
  if (!user_choice || !(*user_choice)) {
    char selstr[] = "Error in parsing web page variables";
    strcpy(buf, selstr);
    return strlen(selstr);
  } else
	((app_state_t *) app_state)->gpio_data.led_1 = atoi(user_choice);

  user_choice = web_server_get_param("l2", connection_state);
  if (!user_choice || !(*user_choice)) {
    char selstr[] = "Error in parsing web page variables";
    strcpy(buf, selstr);
    return strlen(selstr);
  } else
	((app_state_t *) app_state)->gpio_data.led_2 = atoi(user_choice);

  user_choice = web_server_get_param("l3", connection_state);
  if (!user_choice || !(*user_choice)) {
    char selstr[] = "Error in parsing web page variables";
    strcpy(buf, selstr);
    return strlen(selstr);
  } else
	((app_state_t *) app_state)->gpio_data.led_3 = atoi(user_choice);

  user_choice = web_server_get_param("b1", connection_state);
  if (!user_choice || !(*user_choice)) {
    char selstr[] = "Error in parsing web page variables";
    strcpy(buf, selstr);
    return strlen(selstr);
  } else
	((app_state_t *) app_state)->gpio_data.button_1 = atoi(user_choice);

  user_choice = web_server_get_param("b2", connection_state);
  if (!user_choice || !(*user_choice)) {
    char selstr[] = "Error in parsing web page variables";
    strcpy(buf, selstr);
    return strlen(selstr);
  } else
	((app_state_t *) app_state)->gpio_data.button_2 = atoi(user_choice);

  if ((((app_state_t *) app_state)->gpio_data.button_1) &&
    (((app_state_t *) app_state)->gpio_data.button_2))
	((app_state_t *) app_state)->button_id = 3;
  else if (((app_state_t *) app_state)->gpio_data.button_1)
	((app_state_t *) app_state)->button_id = 1;
  else if (((app_state_t *) app_state)->gpio_data.button_2)
	((app_state_t *) app_state)->button_id = 2;
  else
	((app_state_t *) app_state)->button_id = 0;

  ((app_state_t *) app_state)->gpio_data.temperature = 0;
  /* Send web page request to app_handler to apply LED and button status enquiry */
  set_gpio_state(c_gpio, &((app_state_t *) app_state)->gpio_data);
  /* Fetch button press states and new temperature value */
  get_gpio_state(c_gpio, &((app_state_t *) app_state)->gpio_data);
  return 0;
}

int get_web_user_selection(char buf[],
		int app_state,
		int connection_state,
		int selected_value,
		int ui_param)
{
  int select_flag = 0;
  switch (ui_param) {
  case 1:
	if (((app_state_t *) app_state)->gpio_data.led_0 == selected_value)
	  select_flag = 1;
  break;
  case 2:
	if (((app_state_t *) app_state)->gpio_data.led_1 == selected_value)
	  select_flag = 1;
  break;
  case 3:
	if (((app_state_t *) app_state)->gpio_data.led_2 == selected_value)
	  select_flag = 1;
  break;
  case 4:
	if (((app_state_t *) app_state)->gpio_data.led_3 == selected_value)
	  select_flag = 1;
  break;
  case 5:
  case 6:
	/* Reset button check user selection to 'No' */
	if (0 == selected_value)
	  select_flag = 1;
  break;
  default:
  break;
  }
  if (select_flag) {
	char selstr[] = "selected";
	strcpy(buf, selstr);
	return strlen(selstr);
  } else
	return 0;
}

int read_temperature(char buf[], int app_state, int connection_state)
{
  if (!web_server_is_post(connection_state))
	return 0;
  else {
    char selstr[] = "Temperature recorded from onboard ADC: <b>NA </b><sup>o</sup>C";
    selstr[42] = (((app_state_t *) app_state)->gpio_data.temperature/10)+'0';
    selstr[43] = (((app_state_t *) app_state)->gpio_data.temperature%10)+'0';
    strcpy(buf, selstr);
    return strlen(selstr);
  }
}

int get_button_state(char buf[], int app_state, int connection_state)
{
  if (!web_server_is_post(connection_state))
    return 0;

  if ((((app_state_t *) app_state)->gpio_data.button_1) &&
	(((app_state_t *) app_state)->gpio_data.button_2) &&
	(0x3 == ((app_state_t *) app_state)->button_id)) {
    char selstr[] = "<b>Both</b> Button 1 and Button 2 are pressed ";
    strcpy(buf, selstr);
    return strlen(selstr);
  }
  else if ((((app_state_t *) app_state)->gpio_data.button_1) &&
    (0x1 & ((app_state_t *) app_state)->button_id)) {
    char selstr[] = "<b>Button 1</b> is pressed";
    strcpy(buf, selstr);
    return strlen(selstr);
  }
  else if ((((app_state_t *) app_state)->gpio_data.button_2) &&
    (0x2 & ((app_state_t *) app_state)->button_id)) {
    char selstr[] = "<b>Button 2</b> is pressed";
    strcpy(buf, selstr);
    return strlen(selstr);
  }
  else if (((app_state_t *) app_state)->button_id) {
    char selstr[] = "Selected button(s) is <b>not</b> pressed";
    strcpy(buf, selstr);
    return strlen(selstr);
  }
  return 0;
}

int reset_button_state(char buf[], int app_state, int connection_state)
{
  chanend c_gpio = (chanend) ((app_state_t *) app_state)->c_gpio;
  reset_gpio_button_state(c_gpio, ((app_state_t *) app_state)->button_id);
  return 0;
}
