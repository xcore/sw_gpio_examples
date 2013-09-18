// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/*===========================================================================
  This file implements demonstration of serial communication,
  LED's and ADC using GPIO slice
  ---------------------------------------------------------------------------*/
#include <xs1.h>
#include <platform.h>
#include <print.h>
#include <string.h>
#include <ctype.h>
#include <xscope.h>

#include "uart_rx.h"
#include "uart_tx.h"
#include "i2c.h"
#include "temp_sensor.h"

#define BAUD_RATE 115200
#define CMD_BUFFER_SIZE 20

//::Ports Start
on tile[1] : buffered in port:1 p_rx = XS1_PORT_1G;
on tile[1] : out port p_tx = XS1_PORT_1C;
on tile[1] : port p_led = XS1_PORT_4A;
on tile[1] : port p_buttons = XS1_PORT_4C;

// I2C ports
on tile[1]: port p_scl = XS1_PORT_1F;
on tile[1]: port p_sda = XS1_PORT_1B;
//::Ports

#define ARRAY_SIZE(x) (sizeof(x)/sizeof(x[0]))
static unsigned char rx_buffer[64];

interface led_if {
  void set(int led_number);
  void clear(int led_number);
  void clear_all(void);
  void set_all(void);
  void cycle(void);
};

//::LED Server
[[distributable]]
void led_server(server interface led_if c[n], unsigned n, port p_led)
{
  int cycle_val = 0;
  p_led <: 0b1111;
  while (1) {
    select {
    case c[int i].set(int led_number):
      unsigned val;
      p_led :> val;
      val = val & ~(1 << (led_number - 1));
      p_led <: val;
      break;

    case c[int i].clear(int led_number):
      unsigned val;
      p_led :> val;
      val = val | (1 << (led_number - 1));
      p_led <: val;
      break;

    case c[int i].clear_all():
      p_led <: 0b1111;
      break;

    case c[int i].set_all():
      p_led <: 0b0000;
      break;

    case c[int i].cycle():
      cycle_val++;
      p_led <: ~cycle_val;
      break;
    }
  }
}
//::LED Server end

interface button_counter_if {
  void inc_button_count(int button_num);
  int  get_button_count(int button_num);
  void clear_button_counts(void);
};

//::Button Start
[[distributable]]
void button_counter(server interface button_counter_if c[n], unsigned n)
{
  int button_count[2] = {0, 0};
  while (1) {
    select {
    case c[int i].inc_button_count(int i):
      button_count[i]++;
      break;

    case c[int i].clear_button_counts():
      button_count[0] = button_count[1] = 0;
      break;

    case c[int i].get_button_count(int i) -> int value:
      value = button_count[i];
      break;
    }
  }
}
//::Button

#define DEBOUNCE_TIME XS1_TIMER_HZ/50

//::Button Handler
[[combinable]]
static void button_handler(port p_buttons,
                           client interface temp_sensor_if c_temp,
                           client interface led_if c_led,
                           client interface button_counter_if c_button_count)
{
  int enabled = 1;
  int button_value = -1;
  timer tmr;
  unsigned event_time;
  // Configure ADC by writing the settings to register
  while (1) {
    select {
      case enabled => p_buttons when pinsneq(button_value) :> button_value:
        tmr :> event_time;
        if (button_value == 0xd) {
          printstr("Temperature is :");
          printint(c_temp.get_temp());
          printstrln(" C");
          c_button_count.inc_button_count(0);
        } else if (button_value == 0xe) {
          c_led.cycle();
          c_button_count.inc_button_count(1);
        }
        // Disable the button to handle bouncing
        enabled = 0;
        break;

      case !enabled => tmr when timerafter(event_time + DEBOUNCE_TIME) :> void:
        enabled = 1;
        break;
    }
  }
}
//::Button Handler end

static void output_string(client interface uart_tx_if c_uart_tx, const char s[])
{
  int i = 0;
  while (s[i] != '\0') {
    c_uart_tx.output_byte(s[i]);
    i++;
  }
}

const char help_msg[] =
  "\r\n\r\n-------------------------HELP--------------------------------"
  "\r\n setall       - Sets all LEDs ON"
  "\r\n clearall     - Clear all LEDs"
  "\r\n setled 'N'   - Switch ON LED N"
  "\r\n clearled 'N' - Switch OFF LED 'N'"
  "\r\n help         - Display all supported commands"
  "\r\n chkbuttons   - Returns if any buttons pressed since last 'chkbuttons' command"
  "\r\n readadc      - Read ADC vaue and Displays temperature"
  "\r\n exit         - Exit from Command mode"
  "\r\n\r\n 'N' is in range 1 to 4\r\n";

//::Command Handler
static int handle_cmd(unsigned char cmd_buffer[CMD_BUFFER_SIZE],
                      client interface uart_tx_if c_uart_tx,
                      client interface temp_sensor_if c_temp,
                      client interface led_if c_led,
                      client interface button_counter_if c_button_count)
{
  if (strcmp(cmd_buffer,"exit") == 0) {
    return 0;
  }
  else if (strcmp(cmd_buffer,"setled 1") == 0) {
    c_led.set(1);
  }
  else if (strcmp(cmd_buffer,"clearled 1") == 0) {
    c_led.clear(1);
  }
  else if (strcmp(cmd_buffer,"setled 2") == 0) {
    c_led.set(2);
  }
  else if (strcmp(cmd_buffer,"clearled 2") == 0) {
    c_led.clear(2);
  }
  else if (strcmp(cmd_buffer,"setled 3") == 0) {
    c_led.set(3);
  }
  else if (strcmp(cmd_buffer,"clearled 3") == 0) {
    c_led.clear(3);
  }
  else if(strcmp(cmd_buffer,"setled 4") == 0) {
    c_led.set(4);
  }
  else if(strcmp(cmd_buffer,"clearled 4") == 0) {
    c_led.clear(4);
  }
  else if(strcmp(cmd_buffer,"clearall") == 0) {
    c_led.clear_all();
  }
  else if(strcmp(cmd_buffer,"setall") == 0) {
    c_led.set_all();
  }
  else if(strcmp(cmd_buffer,"chkbuttons") == 0) {
    int button1count = c_button_count.get_button_count(0);
    int button2count = c_button_count.get_button_count(1);
    output_string(c_uart_tx, "Button 1 pressed ");
    c_uart_tx.output_byte((button1count / 10) + '0');
    c_uart_tx.output_byte((button1count % 10) + '0');
    output_string(c_uart_tx, " times.\r\n");
    output_string(c_uart_tx, "Button 2 pressed ");
    c_uart_tx.output_byte((button2count / 10) + '0');
    c_uart_tx.output_byte((button2count % 10) + '0');
    output_string(c_uart_tx, " times.\r\n");
    c_button_count.clear_button_counts();
  }
  else if(strcmp(cmd_buffer,"help") == 0) {
    output_string(c_uart_tx, help_msg);
  }
  else if(strcmp(cmd_buffer,"readadc") == 0) {
    int val = c_temp.get_temp();
    output_string(c_uart_tx, "Temperature is : ");
    c_uart_tx.output_byte((val/10)+'0');
    c_uart_tx.output_byte((val%10)+'0');
    output_string(c_uart_tx, " C\r\n");
  }
  else {
    output_string(c_uart_tx, "\r\nINVALID COMMAND - Use 'help' for details\r\n");
  }
  return 1;
}
//::Command Handler

//::UART Handler
[[combinable]]
void uart_handler(client interface uart_tx_if c_uart_tx,
                  client interface uart_rx_if c_uart_rx,
                  client interface temp_sensor_if c_temp,
                  client interface led_if c_led,
                  client interface button_counter_if c_button_count)
{
  unsigned char cmd_buffer[CMD_BUFFER_SIZE];
  int cmd_buffer_index = 0;
  int in_command_mode = 0;
  char cmd_str[] = ">cmd\r";
  int cmd_str_index = 0;

  c_uart_tx.set_baud_rate(115200);
  c_uart_tx.set_parity(UART_TX_PARITY_EVEN);
  c_uart_tx.set_bits_per_byte(8);
  c_uart_tx.set_stop_bits(1);

  c_uart_rx.set_baud_rate(115200);
  c_uart_rx.set_parity(UART_TX_PARITY_EVEN);
  c_uart_rx.set_bits_per_byte(8);
  c_uart_rx.set_stop_bits(1);

  output_string(c_uart_tx, "\r\nWELCOME TO THE XMOS sliceKIT GPIO DEMO\r\n");
  output_string(c_uart_tx, "\r\n(**ECHO DATA MODE ACTIVATED**)\r\nPress '>cmd' for command mode\r\n");

  while(1)  {
    select {
      case c_uart_rx.data_ready():
        unsigned char data = c_uart_rx.input_byte();
        if (in_command_mode) {
          if (data == '\r') {
            cmd_buffer[cmd_buffer_index] = '\0';
            in_command_mode = handle_cmd(cmd_buffer, c_uart_tx,
                                         c_temp, c_led, c_button_count);
            if (!in_command_mode) {
              output_string(c_uart_tx, "\r\nCOMMAND MODE DE-ACTIVATED\r\n");
            }
            cmd_buffer_index = 0;
          }
          else {
            cmd_buffer[cmd_buffer_index] = data;
            cmd_buffer_index++;
            if (cmd_buffer_index > CMD_BUFFER_SIZE)
              cmd_buffer_index = 0;
          }
        } else {
          c_uart_tx.output_byte(data);
          if (tolower(data) == cmd_str[cmd_str_index]) {
            cmd_str_index++;
            if (cmd_str_index == strlen(cmd_str)) {
              output_string(c_uart_tx, "\r\nCOMMAND MODE ACTIVATED\r\n");
              in_command_mode = 1;
            }
          }
          else {
            cmd_str_index = 0;
          }
        }
        break;
    }
  }
}
//::UART Handler end

void xscope_user_init(void) {
  xscope_register(0);
  xscope_config_io(XSCOPE_IO_BASIC);
}


int main()
{
  interface uart_tx_if c_uart_tx[1];
  interface uart_rx_if c_uart_rx;
  interface i2c_master_if c_i2c[1];
  interface temp_sensor_if c_temp[2];
  interface led_if c_led[2];
  interface button_counter_if c_button_count[2];
  par {
      // The peripherals - a bidirectional uart, an i2c component and
      // a special led component implemented in this file.
      on tile[1] : [[distribute]] uart_tx(c_uart_tx, 1, p_tx);
      on tile[1] : uart_rx(c_uart_rx, rx_buffer, ARRAY_SIZE(rx_buffer), p_rx);
      on tile[1] : [[distribute]] i2c_master(c_i2c, 1, p_scl, p_sda);

      // The application logic consists of three tasks - one to handle button
      // input and one dealing with the serial I/O, these run on the same
      // logical core.
      // Both tasks communicate with the i2c and led tasks.
      on tile[1] : [[distribute]] led_server(c_led, 2, p_led);
      on tile[1] : [[distribute]] temp_sensor(c_temp, 2, c_i2c[0]);
      on tile[1] : [[distribute]] button_counter(c_button_count, 2);
      on tile[1] :
        [[combine]]
        par {
          button_handler(p_buttons, c_temp[0], c_led[0], c_button_count[0]);
          uart_handler(c_uart_tx[0], c_uart_rx, c_temp[1],
                      c_led[1], c_button_count[1]);
        }
  }
  return 0;
}



