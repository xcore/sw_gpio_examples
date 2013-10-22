#ifndef _wifi_tiwisl_config_h_
#define _wifi_tiwisl_config_h_

/* SSID as advertized by your wireless router */
#define WIFI_SSID           "testap"

/* Password (if any) to connect to your wireless router */
#define WIFI_PASSWORD       "testpwd"

/*
 * Security type of your wireless router
 * If its unsecured (no password or open): TIWISL_SEC_TYPE_UNSEC
 * If its WEP: TIWISL_SEC_TYPE_WEP
 * If its WPA: TIWISL_SEC_TYPE_WPA
 * If its WPA2: TIWISL_SEC_TYPE_WPA2
 */
#define WIFI_SECURITY_TYPE  TIWISL_SEC_TYPE_WPA2

#endif // _wifi_tiwisl_config_h_
