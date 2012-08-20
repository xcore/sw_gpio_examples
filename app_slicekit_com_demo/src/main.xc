#include <xs1.h>
#include <platform.h>
#include "uart_rx.h"
#include "uart_tx.h"
#include <print.h>
#include<string.h>
#include<xscope.h>
#include<i2c.h>


buffered in port:1 rx = on stdcore[0] : XS1_PORT_1F;
out port tx = on stdcore[0] : XS1_PORT_1E;
port led=XS1_PORT_4F;
in port button1=XS1_PORT_1K;
in port button2=XS1_PORT_1L;

struct r_i2c i2cOne = {
    XS1_PORT_1A,
    XS1_PORT_1B,
   };

#define BAUD_RATE 115200



#define ARRAY_SIZE(x) (sizeof(x)/sizeof(x[0]))

void receive(chanend c_receive, chanend c_uartRX);
void app_manager(chanend c_uartTX,chanend c_chanRX,chanend c_process, chanend c_end);
void process_data(chanend c_process, chanend c_end);

#pragma unsafe arrays
int main()
{
  chan c_chanTX, c_chanRX,c_receive,c_process,c_end;

    unsigned char tx_buffer[64];
    unsigned char rx_buffer[64];
    tx <: 1;

#ifdef ENABLE_XSCOPE
    xscope_register(0, 0, "", 0, "");
    xscope_config_io(XSCOPE_IO_BASIC);
#endif

    printstr("Test Start...\n");
	par
	{
        uart_rx(rx, rx_buffer, ARRAY_SIZE(rx_buffer), BAUD_RATE, 8, UART_TX_PARITY_EVEN, 1, c_chanRX);
        uart_tx(tx, tx_buffer, ARRAY_SIZE(tx_buffer), BAUD_RATE, 8, UART_TX_PARITY_EVEN, 1, c_chanTX);
        app_manager(c_chanTX,c_chanRX,c_process,c_end);
        process_data(c_process, c_end);
	}
  return 0;
}

void app_manager(chanend c_uartTX,chanend c_uartRX, chanend c_process, chanend c_end)
{
	timer t;
	unsigned char rcvbuffer;
	unsigned char cmd_rcvbuffer[20];
	unsigned char cmd_buffer[] = "\nCOMMAND MODE ACTIVATED";
	unsigned char cmd_buffer1[] = "\nEXIT COMMAND  MODE\n";
	unsigned char cmd_buffer2[] = "\nBUTTON x PRESSED";
	unsigned char cmd_buffer3[] = "\nNO BUTTONS ARE PRESSED";
	unsigned char message1[] = "\n setall - Sets all LEDs ON\n clearall - Clear all LEDs \n setled N - Switch ON LED N\n "
			 "clearled N - Switch OFF LED N\n exit - Exit from Command mode\n help - Display all supported Commands\n "
			 "chkbuttons - Returns if any buttons pressed since last run \n readadc - Read ADC vaue and Displays temperature\n\n 'N' is in range 1 to 4";
	unsigned char message2[] ="\nInvalid Command";
	unsigned char message3[] ="Welcome To XMOS GPIO Demo";
	unsigned char data_arr[1]={'K'};
	unsigned crc_value=0,data=0;
	unsigned byte,button_value1=0,button_value2=0,time;
	int i=0,j=0,k=0,skip=1,selection;
	int button, button1_press=0,button2_press=0;
	unsigned COMMAND_MODE=0;
	uart_rx_client_state rxState;
	unsigned char buffer;
	uart_rx_init(c_uartRX, rxState);
	uart_rx_set_baud_rate(c_uartRX, rxState, BAUD_RATE);

	uart_tx_set_baud_rate(c_uartTX, BAUD_RATE);

	i=0;
	t:>time;
	while(i!=25)
	{
		uart_tx_send_byte(c_uartTX, message3[i]);
		i++;
	}
	uart_tx_send_byte(c_uartTX, '\n');
	 while(1)
	 {
		select
		{
			case c_end:>data:
				c_end:>data;
				if(data == 1)
					printstr("Button 1 Pressed");
				if(data == 2)
					printstrln("Button 2 PRessed");

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
								uart_tx_send_byte(c_uartTX, '\n');
								for(int i=0;i<23;i++)
									uart_tx_send_byte(c_uartTX, cmd_buffer[i]);
								COMMAND_MODE=1;
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
								switch(data)
								{
									case 0:
										COMMAND_MODE=0;
										skip=0;
										i=0;
										while(cmd_buffer1[i]!='\0')
										{
											uart_tx_send_byte(c_uartTX, cmd_buffer1[i]);
											i++;
										}
										break;

									case 1:
										led:>data;
										data=data | 0x01;
										led<:data;
										break;

									case 2:
										led:>data;
										led<:data&0x0E;
										break;

									case 3:
										led:>data;
										led<:data | 0x02;
										break;

									case 4:
										led:>data;
										led<:data&0x0D;

										break;

									case 5:
										led:>data;
										led<:data | 0x04;
										break;

									case 6:
										led:>data;
										led<:data&0x0B;
										break;

									case 7:
										led:>data;
										led<:data | 0x08;
										break;

									case 8:
										led:>data;
										led<:data&0x07;

										break;

									case 9:
										led<:0;
										break;

									case 10:
										led<:0x0F;
										break;

									case 11:
										c_end:>button;
										if(button ==1)
										{
											printstrln("Button 1 Pressed");
											button1_press=1;
										}
										else if(button ==2)
										{
											printstrln("BUtton 2 Pressed");
											button2_press=1;
										}
										break;
									case 12:
										i=0;
										while(message1[i]!='\0')
										{
											uart_tx_send_byte(c_uartTX, message1[i]);
											i++;
										}
										uart_tx_send_byte(c_uartTX, '\n');
										break;
									case 13:
										i2c_master_write_reg(0x10, 0x12, data_arr, 1, i2cOne);
										i2c_master_rx(0x10, data_arr, 1, i2cOne);
										uart_tx_send_byte(c_uartTX, data_arr[0]);
										break;
									case 14:
										i=0;
										while(message2[i]!='\0')
										{
											uart_tx_send_byte(c_uartTX, message2[i]);
											i++;
										}
										break;
									case 15:
										if(button1_press)
										{
											printstr("B1 is pressed");
										}
										if(button2_press)
										{
											printstr("B2 is pressed");
										}
										if( !button1_press && !button2_press)
										{
											printstr("No buttons are pressed");
										}
										button1_press=0;
										button2_press=0;
								}
								if(data)
								{
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
	button1:>button_value1;
	button2:>button_value2;
	while(1)
	{
		select
		{
			case button => button1 when pinsneq(button_value1):>button_value1:
				button=0;
				break;

			case button=> button2 when pinsneq(button_value2):>button_value2:
				button=0;
				break;

			case !button => t when timerafter(time+20000000):>time:
				button1:> button_value1;
				button2:> button_value2;
				if(!button_value1)
				{
					button1_pressed=1;
					c_end<:11;
					c_end<:1;
					//printstrln("Button 1 Pressed");
				}
				if(!button_value2)
				{
					c_end<:11;
					c_end<:2;
					button2_pressed=1;
					//printstrln("Button 2 Pressed");
				}
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
					c_end<:0;
				}
				else if(!strcmp(cmd_rcvbuffer,"setled 1"))
				{
					c_end<:1;
				}
				else if(!strcmp(cmd_rcvbuffer,"clearled 1"))
				{
					c_end<:2;
				}
				else if(!strcmp(cmd_rcvbuffer,"setled 2"))
				{
					c_end<:3;
				}
				else if(!strcmp(cmd_rcvbuffer,"clearled 2"))
				{
					c_end<:4;
				}
				else if(!strcmp(cmd_rcvbuffer,"setled 3"))
				{
					c_end<:5;
				}
				else if(!strcmp(cmd_rcvbuffer,"clearled 3"))
				{
					c_end<:6;
				}
				else if(!strcmp(cmd_rcvbuffer,"setled 4"))
				{
					c_end<:7;
				}
				else if(!strcmp(cmd_rcvbuffer,"clearled 4"))
				{
					c_end<:8;
				}
				else if(!strcmp(cmd_rcvbuffer,"clearall"))
				{
					c_end<:9;
				}
				else if(!strcmp(cmd_rcvbuffer,"setall"))
				{
					c_end<:10;
				}
				else if(!strcmp(cmd_rcvbuffer,"chkbuttons"))
				{
					c_end<:15;
				}
				else if(!strcmp(cmd_rcvbuffer,"help"))
				{
					c_end<:12;
				}
				else if(!strcmp(cmd_rcvbuffer,"readadc"))
				{

					c_end<:13;
				}
				else
				{
					c_end<:14;
				}
				i=0;
				break;

		}
	}
}
