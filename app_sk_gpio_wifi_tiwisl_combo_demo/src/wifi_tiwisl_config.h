// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/*===========================================================================
 Info
 ----
 
 ===========================================================================*/

#ifndef _wifi_tiwisl_config_h_
#define _wifi_tiwisl_config_h_

/*---------------------------------------------------------------------------
 nested include files
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 constants
 ---------------------------------------------------------------------------*/
/* SSID as advertized by your wireless router */
#define WIFI_SSID           "xms6testap0"
/* Password (if any) to connect to your wireless router */
#define WIFI_PASSWORD       ""
/*
 * Security type of your wireless router
 * If its unsecured (no password or open): TIWISL_SEC_TYPE_UNSEC
 * If its WEP: TIWISL_SEC_TYPE_WEP
 * If its WPA: TIWISL_SEC_TYPE_WPA
 * If its WPA2: TIWISL_SEC_TYPE_WPA2
 */
#define WIFI_SECURITY_TYPE  TIWISL_SEC_TYPE_UNSEC

/*---------------------------------------------------------------------------
 typedefs
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 global variables
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 extern variables
 ---------------------------------------------------------------------------*/
 
/*---------------------------------------------------------------------------
 prototypes
 ---------------------------------------------------------------------------*/


#endif // _wifi_tiwisl_config_h_
/*==========================================================================*/
