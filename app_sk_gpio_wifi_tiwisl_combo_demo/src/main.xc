// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#include <platform.h>
#include <xs1.h>
#include "wifi_tiwisl_server.h"
#include "web_server.h"
#include "app_handler.h"

#define DHCP

//::Ports Start
on stdcore[0]: spi_master_interface tiwisl_spi =
{
  XS1_CLKBLK_1,
  XS1_CLKBLK_2,
  XS1_PORT_1K, // MOSI
  XS1_PORT_1J, // CLK
  XS1_PORT_1I, // MISO
};

on stdcore[0]: wifi_tiwisl_ctrl_ports_t tiwisl_ctrl =
{
  XS1_PORT_4E, // nCS - Bit0, Power enable - Bit1
  XS1_PORT_1L, // nIRQ
};

on tile[1]: r_i2c p_i2c =
  {     XS1_PORT_1F,
		XS1_PORT_1B,
		1000 };
on tile[1]: port p_led=XS1_PORT_4A;
on tile[1]: port p_button=XS1_PORT_4C;
//::Ports End

// IP Config - change this to suit your network.  Leave with all
// 0 values to use DHCP
#ifdef DHCP
xtcp_ipconfig_t ipconfig = {
  { 0, 0, 0, 0 }, // ip address (eg 192,168,0,2)
  { 0, 0, 0, 0 }, // netmask (eg 255,255,255,0)
  { 0, 0, 0, 0 } // gateway (eg 192,168,0,1)
};
#else
xtcp_ipconfig_t ipconfig = {
  { 169, 254, 196, 178 },
  { 255, 255, 0, 0 },
  { 0, 0, 0, 0 }
};
#endif

// Wireless Access Point Configuration: SSID, Key, Security Type.
wifi_ap_config_t ap_config = {"xms6testap0", "", TIWISL_SEC_TYPE_UNSEC};

void tcp_handler(chanend c_xtcp, chanend c_gpio) {
  xtcp_connection_t conn;

  // Switch ON the Wi-Fi module
  xtcp_wifi_on(c_xtcp);
  // Connect to an access point
  xtcp_connect(c_xtcp, ap_config);
  
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
          on tile[0]: wifi_tiwisl_server(c_xtcp[0], tiwisl_spi, tiwisl_ctrl);
          on tile[0]: tcp_handler(c_xtcp[0], c_gpio);
          on tile[1]: app_handler(c_gpio, p_i2c, p_led, p_button);
	}
	return 0;
}
