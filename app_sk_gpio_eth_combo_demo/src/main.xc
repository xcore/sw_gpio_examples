// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#include <platform.h>
#include <xs1.h>
#include "xtcp.h"
#include "web_server.h"
#include "app_handler.h"
#include "ethernet_board_support.h"


//::Ports Start
ethernet_xtcp_ports_t xtcp_ports =
  {    on tile[1]:  OTP_PORTS_INITIALIZER,
       ETHERNET_DEFAULT_SMI_INIT,
       ETHERNET_DEFAULT_MII_INIT_lite,
       ETHERNET_DEFAULT_RESET_INTERFACE_INIT};
on tile[1]: r_i2c p_i2c =
  {     XS1_PORT_1F,
		XS1_PORT_1B,
		1000 };
on tile[1]: port p_led=XS1_PORT_4A;
on tile[1]: port p_button=XS1_PORT_4C;
//::Ports End

// IP Config - change this to suit your network.  Leave with all
// 0 values to use DHCP
#ifdef STATIC_IP
xtcp_ipconfig_t ipconfig = {
  { 192, 168, 1, 178 },
  { 255, 255, 0, 0 },
  { 0, 0, 0, 0 }
};
#else
xtcp_ipconfig_t ipconfig = {
  { 0, 0, 0, 0 }, // ip address (eg 192,168,0,2)
  { 0, 0, 0, 0 }, // netmask (eg 255,255,255,0)
  { 0, 0, 0, 0 } // gateway (eg 192,168,0,1)
};
#endif

void tcp_handler(chanend c_xtcp, chanend c_gpio) {
  xtcp_connection_t conn;
  web_server_init(c_xtcp, null, null);
  init_web_state(c_gpio);
  while (1) {
    select
      {
      case xtcp_event(c_xtcp,conn):
        web_server_handle_event(c_xtcp, null, null, conn);
        break;
      }
  }
}

// Program entry point
int main(void) {
	chan c_xtcp[1];
	chan c_gpio;

	par
	{
          on tile[1]: ethernet_xtcp_server(xtcp_ports, ipconfig, c_xtcp, 1);
          on tile[1]: tcp_handler(c_xtcp[0], c_gpio);
          on tile[1]: app_handler(c_gpio, p_i2c, p_led, p_button);
	}
	return 0;
}
