// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#ifndef __web_page_functions_h__
#define __web_page_functions_h__

void init_web_state(chanend c_gpio);
int process_web_page_data(char buf[], int app_state, int connection_state);
int get_web_user_selection(char buf[],
		int app_state,
		int connection_state,
		int selected_value,
		int ui_param);
int read_temperature(char buf[], int app_state, int connection_state);
int get_button_state(char buf[], int app_state, int connection_state);
int reset_button_state(char buf[], int app_state, int connection_state);

#endif // __web_page_functions_h__
