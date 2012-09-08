#include <xs1.h>
#include <platform.h>
#include "uart_rx.h"
#include "uart_tx.h"
#include <print.h>
#include<i2c.h>
#include<string.h>

#define SK_GPIO_SLOT_SQUARE
#define BAUD_RATE 115200
//#define AD7995_0 //define this in module_i2c_master


#ifdef SK_GPIO_SLOT_STAR
#define CORE_NUM 0
#define TYPE 0
#define BUTTON_PRESS_VALUE 14
on stdcore[CORE_NUM] : buffered in port:1 p_rx =  PORT_ETH_TXCLK_0;
on stdcore[CORE_NUM] : out port p_tx = PORT_ETH_RXDV_0;
on stdcore[CORE_NUM]: port p_led=PORT_ETH_RXD_0;
on stdcore[CORE_NUM]: in port p_button1=PORT_ETH_MDIOC_0;
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
on stdcore[CORE_NUM] : buffered in port:1 p_rx =  PORT_ETH_TXCLK_1;
on stdcore[CORE_NUM] : out port p_tx = PORT_ETH_RXDV_1;
on stdcore[CORE_NUM] : port p_led=PORT_ETH_RXD_1;
on stdcore[CORE_NUM] : in port p_button1=PORT_ETH_MDIO_1;
on stdcore[CORE_NUM] : in port p_button2=PORT_ETH_MDC_1;

struct r_i2c i2cOne = {
		PORT_ETH_TXEN_1,
		PORT_ETH_RXCLK_1,
		1000
 };
#endif

#ifdef SK_GPIO_SLOT_CIRCLE
#define CORE_NUM 1
#define TYPE 1
#define BUTTON_PRESS_VALUE 0
on stdcore[CORE_NUM] : buffered in port:1 p_rx =  PORT_ETH_TXCLK_3;
on stdcore[CORE_NUM] : out port p_tx = PORT_ETH_RXDV_3;
on stdcore[CORE_NUM]: port p_led=PORT_ETH_RXD_3;
on stdcore[CORE_NUM]: in port p_button1=PORT_ETH_MDIO_3;
on stdcore[CORE_NUM]: in port p_button2=PORT_ETH_MDC_3;

struct r_i2c i2cOne = {
		PORT_ETH_TXEN_3,
		PORT_ETH_RXCLK_3,
		1000
 };
#endif

#ifdef SK_GPIO_SLOT_SQUARE
#define CORE_NUM 1
#define TYPE 0
#define BUTTON_PRESS_VALUE 14
on stdcore[CORE_NUM] : buffered in port:1 p_rx =  PORT_ETH_TXCLK_2;
on stdcore[CORE_NUM] : out port p_tx = PORT_ETH_RXDV_2;
on stdcore[CORE_NUM]: port p_led=PORT_ETH_RXD_2;
on stdcore[CORE_NUM]: in port p_button1=PORT_ETH_MDIOC_2;
struct r_i2c i2cOne = {
		PORT_ETH_TXEN_2,
		PORT_ETH_RXCLK_2,
		1000
 };
#endif

typedef enum{
SET_LED_1,
SET_LED_2,
SET_LED_3,
SET_LED_4,
CLEAR_LED_1,
CLEAR_LED_2,
CLEAR_LED_3,
CLEAR_LED_4,
SET_ALL,
CLEAR_ALL,
CHK_BUTTONS,
EXIT,
HELP,
READ_ADC,
BUTTON_PRESSED,
BUTTON_1,
BUTTON_2,
INVALID
};

int linear_interpolation(int adc_value);

int TEMPERATURE_LUT[][2]={
		{-10,845},{-5,808},{0,765},{5,718},{10,668},{15,614},{20,559},{25,504},
		{30,450},{35,399},{40,352},{45,308},{50,269},{55,233},{60,202}
};

void init()
{
	char data;

#if ((TYPE==0)&&(CORE_NUM==0))
	p_select<:0;
	p_select<:64;
#endif
}

void dummy()
{
	while (1);
}

#define ARRAY_SIZE(x) (sizeof(x)/sizeof(x[0]))

void receive(chanend c_receive, chanend c_uartRX);
void app_manager(chanend c_uartTX,chanend c_chanRX,chanend c_process, chanend c_end);
void process_data(chanend c_process, chanend c_end);
void uart_tx_string(chanend c_uartTX,unsigned char message[100]);

unsigned char tx_buffer[64];
 unsigned char rx_buffer[64];

#pragma unsafe arrays
int main()
{
  chan c_chanTX, c_chanRX,c_receive,c_process,c_end;

	par
	{
    	on stdcore[CORE_NUM] : uart_rx(p_rx, rx_buffer, ARRAY_SIZE(rx_buffer), BAUD_RATE, 8, UART_TX_PARITY_EVEN, 1, c_chanRX);
    	on stdcore[CORE_NUM] : uart_tx(p_tx, tx_buffer, ARRAY_SIZE(tx_buffer), BAUD_RATE, 8, UART_TX_PARITY_EVEN, 1, c_chanTX);
    	on stdcore[CORE_NUM] : app_manager(c_chanTX,c_chanRX,c_process,c_end);
    	on stdcore[CORE_NUM] : process_data(c_process, c_end);
#if ((TYPE==0)&&(CORE_NUM==0))
    	on stdcore[CORE_NUM]: init();
#else
    	on stdcore[CORE_NUM]: dummy();
#endif
    	on stdcore[CORE_NUM]: dummy();
    	on stdcore[CORE_NUM]: dummy();
    	on stdcore[CORE_NUM]: dummy();
	}
  return 0;
}

void app_manager(chanend c_uartTX,chanend c_uartRX, chanend c_process, chanend c_end)
{
	unsigned char i2c_register[1]={0x13};
	unsigned char i2c_register1[2];
	int adc_value;
	timer t;
	unsigned char CONSOLE_MESSAGES[16][110]=
	{
	 "\r\nCOMMAND MODE ACTIVATED",
	 "\r\nEXIT COMMAND MODE\r\n",
	 "\r\nINVALID COMMAND - Use 'help' for details",
	 "\r\nCOMMAND EXECUTED",
	 "\r\nBUTTON x PRESSED",
	 "\r\nNO BUTTONS ARE PRESSED",
	 "\r\nWELCOME TO GPIO DEMO",
	 "\r\n setall \t- Sets all LEDs ON\r\n clearall \t- Clear all LEDs",
	 "\r\n setled 'N' \t- Switch ON LED N",
	 "\r\n help \t\t- Display all supported commands",
	 "\r\n chkbuttons \t- Returns if any buttons pressed since last 'chkbuttons' command",
	 "\r\n readadc \t- Read ADC vaue and Displays temperature\r\n\r\n 'N' is in range 1 to 4",
	 "\r\nCURRENT TEMPERATURE VALUE IS : ",
	 "\r\n(**ECHO DATA MODE ACTIVATED**)\r\nPress '>cmd' for command mode\r\n",
	 "\r\n\r\n-------------------------HELP--------------------------------",
	 "\r\n clearled 'N' \t- Switch OFF LED 'N'\r\n exit \t\t- Exit from Command mode"
	};
	unsigned char rcvbuffer;
	unsigned char cmd_rcvbuffer[20];
	unsigned char data_arr[1]={'K'};
	unsigned crc_value=0,data=0;
	unsigned byte,button_value1=0,button_value2=0,time;
	int j=0,skip=1,selection;
	int button, button1_press=0,button2_press=0;
	unsigned COMMAND_MODE=0;
	uart_rx_client_state rxState;
	unsigned char buffer;
	uart_rx_init(c_uartRX, rxState);
	uart_rx_set_baud_rate(c_uartRX, rxState, BAUD_RATE);

	uart_tx_set_baud_rate(c_uartTX, BAUD_RATE);

	t:>time;
	i2c_master_write_reg(0x28, 0x00, i2c_register, 1, i2cOne);
	uart_tx_string(c_uartTX,CONSOLE_MESSAGES[6]);
	uart_tx_string(c_uartTX,CONSOLE_MESSAGES[13]);
	uart_tx_send_byte(c_uartTX, '\r');
	uart_tx_send_byte(c_uartTX, '\n');
	 while(1)
	 {
		select
		{
			case c_end:>data:
				c_end:>data;
				if(data == BUTTON_1)
				{
					CONSOLE_MESSAGES[4][9]='1';
					uart_tx_string(c_uartTX,CONSOLE_MESSAGES[4]);
				}
				if(data == BUTTON_2)
				{
					CONSOLE_MESSAGES[4][9]='2';
					uart_tx_string(c_uartTX,CONSOLE_MESSAGES[4]);
				}
				break;
			case uart_rx_get_byte_byref(c_uartRX, rxState, buffer):

				if(buffer == '>')
				{
					j=0;
					uart_rx_get_byte_byref(c_uartRX, rxState, buffer);
					cmd_rcvbuffer[j]=buffer;
					if((cmd_rcvbuffer[j] == 'C' )|| (cmd_rcvbuffer[j] =='c'))
					{
						j++;
						uart_rx_get_byte_byref(c_uartRX, rxState, buffer);
						cmd_rcvbuffer[j]=buffer;

						if((cmd_rcvbuffer[j] == 'm' )|| (cmd_rcvbuffer[j] =='M'))
						{
							j++;
							uart_rx_get_byte_byref(c_uartRX, rxState, buffer);
							cmd_rcvbuffer[j]=buffer;
							if((cmd_rcvbuffer[j] == 'D' )|| (cmd_rcvbuffer[j] =='d'))
							{
								uart_tx_send_byte(c_uartTX, '\r');
								uart_tx_send_byte(c_uartTX, '\n');
								uart_tx_string(c_uartTX,CONSOLE_MESSAGES[0]);
								COMMAND_MODE=1;
								uart_tx_send_byte(c_uartTX, '\r');
								uart_tx_send_byte(c_uartTX, '\n');
								uart_tx_send_byte(c_uartTX, '>');
							}
							else
							{
								uart_tx_send_byte(c_uartTX, '>');
								for(int i=0;i<3;i++)
									uart_tx_send_byte(c_uartTX, cmd_rcvbuffer[i]);
							}
						}
						else
						{
							uart_tx_send_byte(c_uartTX, '>');
							for(int i=0;i<2;i++)
								uart_tx_send_byte(c_uartTX, cmd_rcvbuffer[i]);
						}
					}
					else
					{
						uart_tx_send_byte(c_uartTX, '>');
						uart_tx_send_byte(c_uartTX, cmd_rcvbuffer[j]);
						j=0;
					}
				}
				else
				{
					uart_tx_send_byte(c_uartTX,buffer);
				}
				while(COMMAND_MODE)
				{
					j=0;
					skip=1;
					while(skip == 1)
					{
						select
						{
							case uart_rx_get_byte_byref(c_uartRX, rxState, buffer):
								cmd_rcvbuffer[j]=buffer;
								if(cmd_rcvbuffer[j++] == '\n')
								{
									skip=0;
									j=0;
									while(cmd_rcvbuffer[j] != '\r')
									{
										c_process<:cmd_rcvbuffer[j];
										uart_tx_send_byte(c_uartTX, cmd_rcvbuffer[j]);
										j++;
									}
									cmd_rcvbuffer[j]='\0';
									c_process<:cmd_rcvbuffer[j];
									j=0;
								}
								break;
							case c_end:>data:
								if(data!=EXIT && data!=INVALID )
								{
									uart_tx_string(c_uartTX,CONSOLE_MESSAGES[3]);
								}

								switch(data)
								{
									case EXIT:
										COMMAND_MODE=0;
										skip=0;
										uart_tx_string(c_uartTX,CONSOLE_MESSAGES[1]);
										uart_tx_string(c_uartTX,CONSOLE_MESSAGES[13]);
										break;

									case SET_LED_1:
										p_led:>data;
										data=data | 0x01;
										p_led<:data;
										break;

									case CLEAR_LED_1:
										p_led:>data;
										p_led<:data&0x0E;
										break;

									case SET_LED_2:
										p_led:>data;
										p_led<:data | 0x02;
										break;

									case CLEAR_LED_2:
										p_led:>data;
										p_led<:data&0x0D;

										break;

									case SET_LED_3:
										p_led:>data;
										p_led<:data | 0x04;
										break;

									case CLEAR_LED_3:
										p_led:>data;
										p_led<:data&0x0B;
										break;

									case SET_LED_4:
										p_led:>data;
										p_led<:data | 0x08;
										break;

									case CLEAR_LED_4:
										p_led:>data;
										p_led<:data&0x07;

										break;

									case CLEAR_ALL:
										p_led<:0;
										break;

									case SET_ALL:
										p_led<:0x0F;
										break;

									case BUTTON_PRESSED:
										c_end:>button;
										if(button == BUTTON_1)
										{
											CONSOLE_MESSAGES[4][9]='1';
											uart_tx_string(c_uartTX,CONSOLE_MESSAGES[4]);
											button1_press=1;
										}
										if(button == BUTTON_2)
										{
											CONSOLE_MESSAGES[4][9]='2';
											uart_tx_string(c_uartTX,CONSOLE_MESSAGES[4]);
											button2_press=1;
										}
										break;
									case HELP:
										uart_tx_string(c_uartTX,CONSOLE_MESSAGES[14]);
										uart_tx_string(c_uartTX,CONSOLE_MESSAGES[7]);
										uart_tx_string(c_uartTX,CONSOLE_MESSAGES[8]);
										uart_tx_string(c_uartTX,CONSOLE_MESSAGES[9]);
										uart_tx_string(c_uartTX,CONSOLE_MESSAGES[10]);
										uart_tx_string(c_uartTX,CONSOLE_MESSAGES[15]);
										uart_tx_string(c_uartTX,CONSOLE_MESSAGES[11]);
										uart_tx_send_byte(c_uartTX, '\r');
										uart_tx_send_byte(c_uartTX, '\n');
										break;
									case READ_ADC:
										i2c_master_rx(0x28, i2c_register1, 2, i2cOne);
										i2c_register1[0]=i2c_register1[0]&0x0F;
										adc_value=(i2c_register1[0]<<6)|(i2c_register1[1]>>2);
										data_arr[0]=(linear_interpolation(adc_value));
										uart_tx_string(c_uartTX,CONSOLE_MESSAGES[12]);
										uart_tx_send_byte(c_uartTX, (data_arr[0]/10)+'0');
										uart_tx_send_byte(c_uartTX, (data_arr[0]%10)+'0');
										uart_tx_send_byte(c_uartTX, 32);
										uart_tx_send_byte(c_uartTX, 'C');
										break;
									case INVALID:
										uart_tx_string(c_uartTX,CONSOLE_MESSAGES[2]);
										break;
									case CHK_BUTTONS:
										if(button1_press)
										{
											CONSOLE_MESSAGES[4][9]='1';
											uart_tx_string(c_uartTX,CONSOLE_MESSAGES[4]);
										}
										if(button2_press)
										{
											CONSOLE_MESSAGES[4][9]='2';
											uart_tx_string(c_uartTX,CONSOLE_MESSAGES[4]);
										}
										if( !button1_press && !button2_press)
										{
											uart_tx_string(c_uartTX,CONSOLE_MESSAGES[5]);
										}
										button1_press=0;
										button2_press=0;
								}
								if(data != EXIT)
								{
									uart_tx_send_byte(c_uartTX, '\r');
									uart_tx_send_byte(c_uartTX, '\n');
									uart_tx_send_byte(c_uartTX, '>');
								}
								break;
						}//select
					}//skip
					j=0;
				}//command mode
				break;
		}//main select
	 }//superloop
}//thread

void process_data(chanend c_process, chanend c_end)
{
	int k=0,skip=1,i=0;
	unsigned data=0,button_value1,button_value2;
	unsigned char cmd_rcvbuffer[20];
	int button=1,button1_pressed=0,button2_pressed=0;
	timer t;
	unsigned time;

	t:>time;
	p_button1:>button_value1;
#ifndef TYPE
	p_button2:>button_value2;
#endif
	while(1)
	{
		select
		{
			case button => p_button1 when pinsneq(button_value1):>button_value1:
				button=0;
				break;
#ifndef TYPE
			case button=> p_button2 when pinsneq(button_value2):>button_value2:
				button=0;
				break;
#endif
			case !button => t when timerafter(time+20000000):>time:
				p_button1:> button_value1;
#ifndef TYPE
				p_button2:> button_value2;
#endif
				if(button_value1 == BUTTON_PRESS_VALUE)
				{
					button1_pressed=1;
					c_end<:BUTTON_PRESSED;
					c_end<:BUTTON_1;

				}
#ifdef TYPE
				if(button_value1 == BUTTON_PRESS_VALUE-1)
				{
					button2_pressed=1;
					c_end<:BUTTON_PRESSED;
					c_end<:BUTTON_2;

				}

#endif
#ifndef TYPE
				if(button_value2== (BUTTON_PRESS_VALUE-1))
				{
					c_end<:BUTTON_PRESSED;
					c_end<:BUTTON_2;
					button2_pressed=1;

				}
#endif
				button=1;
				break;

			case c_process:>cmd_rcvbuffer[i++]:
				skip=1;
				while(skip == 1)
				{
					c_process:>cmd_rcvbuffer[i];
					if(cmd_rcvbuffer[i++] == '\0')
						skip=0;
				}
				if(!strcmp(cmd_rcvbuffer,"exit"))
				{
					c_end<:EXIT;
				}
				else if(!strcmp(cmd_rcvbuffer,"setled 1"))
				{
					c_end<:SET_LED_1;
				}
				else if(!strcmp(cmd_rcvbuffer,"clearled 1"))
				{
					c_end<:CLEAR_LED_1;
				}
				else if(!strcmp(cmd_rcvbuffer,"setled 2"))
				{
					c_end<:SET_LED_2;
				}
				else if(!strcmp(cmd_rcvbuffer,"clearled 2"))
				{
					c_end<:CLEAR_LED_2;
				}
				else if(!strcmp(cmd_rcvbuffer,"setled 3"))
				{
					c_end<:SET_LED_3;
				}
				else if(!strcmp(cmd_rcvbuffer,"clearled 3"))
				{
					c_end<:CLEAR_LED_3;
				}
				else if(!strcmp(cmd_rcvbuffer,"setled 4"))
				{
					c_end<:SET_LED_4;
				}
				else if(!strcmp(cmd_rcvbuffer,"clearled 4"))
				{
					c_end<:CLEAR_LED_4;
				}
				else if(!strcmp(cmd_rcvbuffer,"clearall"))
				{
					c_end<:CLEAR_ALL;
				}
				else if(!strcmp(cmd_rcvbuffer,"setall"))
				{
					c_end<:SET_ALL;
				}
				else if(!strcmp(cmd_rcvbuffer,"chkbuttons"))
				{
					c_end<:CHK_BUTTONS;
				}
				else if(!strcmp(cmd_rcvbuffer,"help"))
				{
					c_end<:HELP;
				}
				else if(!strcmp(cmd_rcvbuffer,"readadc"))
				{

					c_end<:READ_ADC;
				}
				else
				{
					c_end<:INVALID;
				}
				i=0;
				break;

		}
	}
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

void uart_tx_string(chanend c_uartTX,unsigned char message[100])
{
	int i=0;
	while(message[i]!='\0')
	{
		uart_tx_send_byte(c_uartTX,message[i]);
		i++;
	}
}

