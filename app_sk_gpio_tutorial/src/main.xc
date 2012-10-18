#include <platform.h>
#include <xs1.h>
#include "pwm_tutorial_example.h"
#include "i2c.h"
#include "stdio.h"

#define TILE_IDX 1

on tile[TILE_IDX] : out port p_led = XS1_PORT_4A;

on stdcore[TILE_IDX]: struct r_i2c i2cOne = {
		XS1_PORT_1F,
		XS1_PORT_1B,
		1000
};

on stdcore[TILE_IDX]: port p_buttons = XS1_PORT_4C;

/** =========================================================================
 * wait
 *
 * function that causes a task to wait for a given number of cycles using a timer
 *
 * \param wait_cycles in number of reference clocks
 *
 * \return None
 *
 **/
void wait(unsigned wait_cycles) {
    timer tmr;
    unsigned t;
    tmr :> t;
    t+=wait_cycles;
    tmr when timerafter (t) :> void;
}

/** =========================================================================
 * pwm_controller
 *
 * periodically changes PWM duty cycle to dim LEDs up and down
 *
 * \param c_pwm. PWM control channel
 *
 * \return None
 *
 **/
void pwm_controller(chanend c_pwm)
{
	// PWM period is 10us. 1000 cycles at 10ns (100MHz ref clock)
	int period = 1000;
	// duty_cycle starts at 100% which switches all LEDs off (LEDs active low on GPIO slice)
	int duty_cycle = 1000;
	// duty cycle step (up or down)
	unsigned step = period / 100;
	// duty_cycle delta.
	int delta = -step; // start with increasing brightness

	// send the PWM period length
	c_pwm <: period;
	// send the PWM duty cycle length
	c_pwm <: duty_cycle;

	while(1) {
		// update the duty cycle length
		c_pwm <: duty_cycle;

		wait(XS1_TIMER_HZ/100); // 0.01 s
		duty_cycle += delta;
		if(duty_cycle > period) {
			delta = -step; // increase brightness
			duty_cycle = period;
		}
		else if(duty_cycle < 0) {
			delta = step; // decrease brightness
			duty_cycle = 0;
		}
	}
}

/** =========================================================================
 * pwm_controller_thermo
 *
 * Controls the LEDs according to temperature read from ADC via I2C.
 * temperature is measured by a linearised thermistor connected to the ADC
 *
 * \param c_pwm. PWM control channel
 *
 * \return None
 *
 **/
void pwm_controller_thermo(chanend c_pwm) {
	// PWM period is 10us. 1000 cycles at 10ns (100MHz ref clock)
	const int period = 1000;
	// duty_cycle starts at 100% which switches all LEDs off (LEDs active low on GPIO slice)
	int duty_cycle = 1000;
	// I2C write data
	unsigned char wr_data[1]={0x13};
	// I2C read data
	unsigned char rd_data[2];
    // ADC value. 845 corresponds to -10 degC, 202 corresponds to 60 degrees.
	int adc_value;

	//::Write config
	i2c_master_write_reg(0x28, 0x00, wr_data, 1, i2cOne); //Write configuration information to ADC

	// send the PWM period length
	c_pwm <: period;
	// send the PWM duty cycle length
	c_pwm <: duty_cycle;

	while(1) {
		rd_data[0]=0;rd_data[1]=0;
		//Read ADC value using I2C read
		i2c_master_rx(0x28, rd_data, 2, i2cOne);

		rd_data[0]=rd_data[0]&0x0F;
		adc_value=(rd_data[0]<<6)|(rd_data[1]>>2);

        // convert from ADC scale to duty cycle scale.
		// 845 (-10 degC) corresponds to duty_cycle 1000 (LEDs off)
		// 242 (60 decC) corresponds to duty_cycle 0 (LEDs fully on)
		duty_cycle = (adc_value-242) * 1000/(845-242);

		// saturate
		if(duty_cycle < 0) {
			duty_cycle = 0;
		} else if(duty_cycle > period) {
			duty_cycle = period;
		}

		c_pwm <: duty_cycle;
		wait(XS1_TIMER_HZ/10);  // 0.1 seconds

	}
}

/** =========================================================================
 * pwm_controller_thermo_ctrl
 *
 * Controls the LEDs according to temperature read from ADC via I2C.
 * temperature is measured by a linearised thermistor connected to the ADC.
 * Temperature range can be changed by pressng button 0
 *
 * \param c_pwm. PWM control channel
 * \param p_button. button port
 *
 * \return None
 *
 **/
void pwm_controller_thermo_ctrl(chanend c_pwm, port p_button) {
	// PWM period is 10us. 1000 cycles at 10ns (100MHz ref clock)
	const int period = 1000;
	// duty_cycle starts at 100% which switches all LEDs off (LEDs active low on GPIO slice)
	int duty_cycle = 1000;
	// I2C write data
	unsigned char wr_data[1]={0x13};
	// I2C read data
	unsigned char rd_data[2];
    // ADC value. 845 corresponds to -10 degC, 202 corresponds to 60 degrees.
	int adc_value;

	timer adc_tmr;
	unsigned adc_time;
	const unsigned adc_rd_period = XS1_TIMER_HZ/10; // Read ADC every 0.1 seconds

	timer debounce_tmr;
	unsigned debounce_time;
	const unsigned press_time = XS1_TIMER_HZ/5; // button must be pressed for 0.2 seconds

	unsigned button_val_0,button_val_1;
	// state variable to control when a button change should be detected.
	unsigned detect_button=1;
	// Selected temperature range
	unsigned sensitive_range=0;

	set_port_drive_low(p_button);

	//::Write config
	i2c_master_write_reg(0x28, 0x00, wr_data, 1, i2cOne); //Write configuration information to ADC

	// send the PWM period length
	c_pwm <: period;
	// send the PWM duty cycle length
	c_pwm <: duty_cycle;

	// init times
	debounce_tmr :> debounce_time;
	adc_tmr :> adc_time;
    // init button val
	p_button :> button_val_0;

	while(1) {
		select
		{
			// Controls frequency of reading ADC and updating PWM duty_cycle
			case adc_tmr when timerafter(adc_time+adc_rd_period) :> adc_time:
				rd_data[0]=0;rd_data[1]=0;
				//Read ADC value using I2C read
				i2c_master_rx(0x28, rd_data, 2, i2cOne);

				rd_data[0]=rd_data[0]&0x0F;
				adc_value=(rd_data[0]<<6)|(rd_data[1]>>2);
				// convert from ADC scale to duty cycle scale.
				if(!sensitive_range) {
					// range: -10 degC to 60 degC
					// 845 (-10 degC) corresponds to duty_cycle 1000 (LEDs off)
					// 242 (60 decC) corresponds to duty_cycle 0 (LEDs fully on)
					duty_cycle = (adc_value-242) * period/(845-242);
				} else {
					// range: 27.5 degC to 30 degC
					// 477 (27.5 degC) corresponds to duty_cycle 1000 (LEDs off)
					// 450 (30 decC) corresponds to duty_cycle 0 (LEDs fully on)
					// this range is sensitive enough to change LED brighness by blowing on the GPIO Slice
					duty_cycle = (adc_value-450) * period/(477-450);
				}
				// saturate
				if(duty_cycle < 0) {
					duty_cycle = 0;
				} else if(duty_cycle > period) {
					duty_cycle = period;
				}

				// Update duty cycle in PWM server
				c_pwm <: duty_cycle;
				break;

			//checks if any button changes
			case detect_button => p_button when pinsneq(button_val_0):> button_val_0:
				detect_button=0;
			    debounce_tmr :> debounce_time; // record the time
				break;

		    // waits for pressed_time and checks if the same button is still pressed
			case !detect_button => debounce_tmr when timerafter(debounce_time+press_time):>void:
			    p_button :> button_val_1;
		    	detect_button=1; // re-activate detection of button change
				if(button_val_0==button_val_1) {
					if(button_val_0 == 0b10) //button 1 is pressed
					{
						printf("button 1 Pressed\n");
						if(sensitive_range) {
							printf("switching temperature controlled LED dimmer to temperature range -10 degC to 60degC\n");
							sensitive_range=0;
						} else {
							printf("switching temperature controlled LED dimmer to sensitive temperature range 27.5 degC to 30degC\n");
							sensitive_range=1;
						}

					}
				}
				break;

		}
	}
}


int main() {
	chan c_pwm_duty;
	par {
		on tile[TILE_IDX]: {
			pwm_tutorial_example(c_pwm_duty, p_led, 4);
		}
		on tile[TILE_IDX]: {
			//pwm_controller(c_pwm_duty);
			//pwm_controller_thermo(c_pwm_duty);
			pwm_controller_thermo_ctrl(c_pwm_duty, p_buttons);
		}

	}
	return 0;
}
