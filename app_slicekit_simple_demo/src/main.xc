#include<xs1.h>
#include<print.h>
#include "i2c.h"

port p_PORT_BUT_1=XS1_PORT_1K;
port p_PORT_BUT_2=XS1_PORT_1L;
port p_led=XS1_PORT_4F;

struct r_i2c i2cOne = {
    XS1_PORT_1A,
    XS1_PORT_1B,
   };

int main(void)
{
	unsigned button1,button2,time,time1;
	int button =1;
	timer t,t1;
	unsigned char data[1]={'a'};
    unsigned char data1[2];
    unsigned led_value=0x01;
	p_PORT_BUT_1:> button1;
	p_PORT_BUT_2:> button2;

	t:>time;

	while(1)
	{
		select
		{
			case button => p_PORT_BUT_1 when pinsneq(button1):> button1:
				button=0;
				break;

			case button => p_PORT_BUT_2 when pinsneq(button2):> button2:
				button=0;
				break;

			case !button => t when timerafter(time+20000000):>time:
				PORT_BUT_1:> button1;
				PORT_BUT_2:> button2;
				if(!button1)
				{
					p_led<:(led_value);
					p_led_value=led_value<<1;
					if(led_value == 16)
					{
						led_value=0x01;
					}
					printstrln("Button 1 Pressed");
				}
				if(!button2) //Read data from ADC when button 2 is pressed
				{
					printstrln("Button 1 Pressed");
					i2c_master_write_reg(0x10, 0x12, data, 1, i2cOne);
					printstr("Master Transmitted Data:");
					printcharln(data[0]);
					t1 when timerafter(time1+100000000):>time1;
					i2c_master_rx(0x10, data1, 2, i2cOne);
					printstr("Master Received Data:");
					printcharln(data1[0]);
					data[0]+=1;
				}
				button=1;
				break;
		}
	}
	return 0;
}

