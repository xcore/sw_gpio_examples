#include<xs1.h>
#include<print.h>
#include "i2c.h"
#include<platform.h>
#include<string.h>


#define SK_GPIO_SLOT_STAR
//#define AD7995_0 //define this in module_i2c_master

#ifdef SK_GPIO_SLOT_STAR
#define CORE_NUM 0
#define TYPE 0
#define BUTTON_PRESS_VALUE 14

on stdcore[CORE_NUM]: out port p_led=PORT_ETH_RXD_0;
on stdcore[CORE_NUM]: in port p_PORT_BUT_1=PORT_ETH_MDIOC_0;

on stdcore[0]: port p_select=PORT_SPI_DISABLE;
struct r_i2c i2cOne = {
		PORT_ETH_TXEN_0,
		PORT_ETH_RXCLK_0,
		1000
 };
#endif

#ifdef SK_GPIO_SLOT_TRIANGLE
#define CORE_NUM 0
#define TYPE 1
#define BUTTON_PRESS_VALUE 0
on stdcore[CORE_NUM]: out port p_led=PORT_ETH_RXD_1;
on stdcore[CORE_NUM]: in port p_PORT_BUT_1=PORT_ETH_MDIO_1;
on stdcore[CORE_NUM]: in port p_PORT_BUT_2=PORT_ETH_MDC_1;

struct r_i2c i2cOne = {
		PORT_ETH_TXEN_1,
		PORT_ETH_RXCLK_1,
		1000
 };
#endif

#ifdef SK_GPIO_SLOT_SQUARE
#define CORE_NUM 1
#define TYPE 0
#define BUTTON_PRESS_VALUE 14

on stdcore[CORE_NUM]: out port p_led=PORT_ETH_RXD_2;
on stdcore[CORE_NUM]: in port p_PORT_BUT_1=PORT_ETH_MDIOC_2;
struct r_i2c i2cOne = {
		PORT_ETH_TXEN_2,
		PORT_ETH_RXCLK_2,
		1000
 };
#endif

#ifdef SK_GPIO_SLOT_CIRCLE
#define CORE_NUM 1
#define TYPE 1
#define BUTTON_PRESS_VALUE 0
on stdcore[CORE_NUM]: out port p_led=PORT_ETH_RXD_3;
on stdcore[CORE_NUM]: in port p_PORT_BUT_1=PORT_ETH_MDIO_3;
on stdcore[CORE_NUM]: in port p_PORT_BUT_2=PORT_ETH_MDC_3;

struct r_i2c i2cOne = {
		PORT_ETH_TXEN_3,
		PORT_ETH_RXCLK_3,
		1000
 };
#endif

int linear_interpolation(int adc_value);

int TEMPERATURE_LUT[][2]={
		{-10,845},{-5,808},{0,765},{5,718},{10,668},{15,614},{20,559},{25,504},{30,450},{35,399},
		{40,352},{45,308},{50,269},{55,233},{60,202}
};

void application()
{
	unsigned button1,button2,time,time1;
	int button =1,index=0,toggle=0;
	timer t;
	unsigned char data[1]={0x13};
	unsigned char data1[2];
	int adc_value;
	unsigned led_value=0x01;
	p_PORT_BUT_1:> button1;
#if TYPE
	p_PORT_BUT_2:> button2;
#endif
	i2c_master_write_reg(0x28, 0x00, data, 1, i2cOne);
	t:>time;

	while(1)
	{

		select
		{
			case button => p_PORT_BUT_1 when pinsneq(button1):> button1:
				button=0;
				break;
#if TYPE
			case button => p_PORT_BUT_2 when pinsneq(button2):> button2:
				button=0;
				break;
#endif
			case !button => t when timerafter(time+20000000):>time:
				p_PORT_BUT_1:> button1;
				if(button1 == BUTTON_PRESS_VALUE)
				{
					printstrln("Button 1 Pressed");
					p_led<:(led_value);
					led_value=led_value<<1;
					if(led_value == 16)
					{
						led_value=0x01;
					}
				}
#if TYPE==0
				if(button1 == 13)
				{
					data1[0]=0;data1[1]=0;
					i2c_master_rx(0x28, data1, 2, i2cOne);
					printstrln("Reading Temperature value....");
					data1[0]=data1[0]&0x0F;
					adc_value=(data1[0]<<6)|(data1[1]>>2);
					printstr("Temperature is :");
					printintln(linear_interpolation(adc_value));
				}
#endif

#if TYPE
				p_PORT_BUT_2:> button2;
				if(!button2) //Read data from ADC when button 2 is pressed
				{
					data1[0]=0;data1[1]=0;
					i2c_master_rx(0x28, data1, 2, i2cOne);
					printstrln("Reading Temperature value....");
					data1[0]=data1[0]&0x0F;
					adc_value=(data1[0]<<6)|(data1[1]>>2);
					printstr("Temperature is :");
					printintln(linear_interpolation(adc_value));
				}
#endif
				button=1;
				break;
		}
	}
}

void dummy()
{
	while (1);
}

void init()
{
	char data;

#if ((TYPE==0)&&(CORE_NUM==0))
	p_select<:0;
	p_select<:64;
#endif
}

int linear_interpolation(int adc_value)
{
	int i=0,x1,y1,x2,y2,temper;
	while(adc_value<TEMPERATURE_LUT[i][1])
	{
		i++;
	}
	x1=TEMPERATURE_LUT[i-1][1];
	y1=TEMPERATURE_LUT[i-1][0];
	x2=TEMPERATURE_LUT[i][1];
	y2=TEMPERATURE_LUT[i][0];
	temper=y1+(((adc_value-x1)*(y2-y1))/(x2-x1));
	return temper;
}

int main(void)
{

	par
	{

		on stdcore[CORE_NUM]: application();
		/* use all 8 thereads*/
#if ((TYPE==0)&&(CORE_NUM==0))
		on stdcore[CORE_NUM]: init();
#else
		on stdcore[CORE_NUM]: dummy();
#endif
		on stdcore[CORE_NUM]: dummy();
		on stdcore[CORE_NUM]: dummy();
		on stdcore[CORE_NUM]: dummy();
		on stdcore[CORE_NUM]: dummy();
		on stdcore[CORE_NUM]: dummy();
		on stdcore[CORE_NUM]: dummy();

	}

	return 0;
}


