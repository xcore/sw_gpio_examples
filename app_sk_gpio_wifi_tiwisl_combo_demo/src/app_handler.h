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

/** =========================================================================
 * app_handler
 *
 * Implements GPIO button press checks, reads on-board ADC temperature value,
 * handles GPIO web commands to set/reset LEDs, read temperature and button
 * statuses
 *
 * \param c_gpio channel to communicate GPIO data between app handler and tcp handler
 * \param p_i2c i2c to read ADC value from i2c master
 * \param p_led GPIO LED ports
 * \param p_button GPIO button ports
 * \return None
 *
 **/
void app_handler(chanend c_gpio, REFERENCE_PARAM(r_i2c, p_i2c), port p_led, port p_button);
void set_gpio_state(chanend c_gpio, REFERENCE_PARAM(gpio_state_t, gpio_new_state));
void get_gpio_state(chanend c_gpio, REFERENCE_PARAM(gpio_state_t, gpio_state));

#endif /* APP_HANDLER_H_ */
