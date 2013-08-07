// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#ifndef __web_page_functions_h__
#define __web_page_functions_h__

void init_web_state(chanend c_gpio);
/** =========================================================================
 * process_web_page_data
 *
 * (i) Parses web page data for selected user actions using webserver component
 * calls
 * (ii) Identifies GPIO requested commands and sends it to GPIO handler
 * (iii) Reads the current application state from GPIO handler and updates
 * application state pertaining to current web client connection
 *
 * \param buf buffer to contain application data
 * \param app_state application state containing gpio state, button values
 * and channel
 * \param connection_state tcp connection state
 *
 * \return length of buf
 *
 **/
int process_web_page_data(char buf[], int app_state, int connection_state);

/** =========================================================================
 * process_web_page_data
 *
 * This function identifies value of the html select paramter list based on
 * the current application state and returns 'selected' string
 *
 * \param buf buffer to contain application data
 * \param app_state application state containing gpio state, button values
 * and channel
 * \param connection_state tcp connection state
 * \param selected_value value for the html select parameter
 * \param ui_param parameter identifier to parse
 *
 * \return length of buf
 *
 **/
int get_web_user_selection(char buf[],
		int app_state,
		int connection_state,
		int selected_value,
		int ui_param);
int read_temperature(char buf[], int app_state, int connection_state);
int get_button_state(char buf[], int app_state, int connection_state);
int reset_button_state(char buf[], int app_state, int connection_state);

#endif // __web_page_functions_h__
