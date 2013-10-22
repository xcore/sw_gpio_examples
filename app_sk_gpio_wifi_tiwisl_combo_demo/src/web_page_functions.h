#ifndef __web_page_functions_h__
#define __web_page_functions_h__

/** =========================================================================
 * Initialize the web state
 *
 * \param c_gpio chanend connected to the GPIO handler
 * \return None
 **/
void init_web_state(chanend c_gpio);

/** =========================================================================
 * (i) Parses web page data for selected user actions using web server component
 * calls
 * (ii) Identifies GPIO requested commands and sends it to GPIO handler
 * (iii) Reads the current application state from GPIO handler and updates
 * application state pertaining to current web client connection
 *
 * \param buf buffer to contain application data
 * \param app_state application state containing GPIO state, button values and channel
 * \param connection_state TCP connection state
 * \return length of buf
 **/
int process_web_page_data(char buf[], int app_state, int connection_state);

/** =========================================================================
 * This function identifies value of the html select parameter list based on
 * the current application state and returns 'selected' string
 *
 * \param buf buffer to contain application data
 * \param app_state application state containing GPIO state, button values and channel
 * \param connection_state TCP connection state
 * \param selected_value value for the html select parameter
 * \param ui_param parameter identifier to parse
 * \return length of buf
 **/
int get_web_user_selection(char buf[],
		                       int app_state,
		                       int connection_state,
		                       int selected_value,
		                       int ui_param);

/** =========================================================================
 * Reads the temperature from on-board ADC
 *
 * \param buf buffer to contain application data
 * \param app_state application state containing GPIO state, button values and channel
 * \param connection_state TCP connection state
 * \return length of buf
 **/
int read_temperature(char buf[], int app_state, int connection_state);

/** =========================================================================
 * Reads the button state
 *
 * \param buf buffer to contain application data
 * \param app_state application state containing GPIO state, button values and channel
 * \param connection_state TCP connection state
 * \return length of buf
 **/
int get_button_state(char buf[], int app_state, int connection_state);

/** =========================================================================
 * Resets the button state
 *
 * \param buf buffer to contain application data
 * \param app_state application state containing GPIO state, button values and channel
 * \param connection_state TCP connection state
 * \return length of buf
 **/
int reset_button_state(char buf[], int app_state, int connection_state);

#endif // __web_page_functions_h__
