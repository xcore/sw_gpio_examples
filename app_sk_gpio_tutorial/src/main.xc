#include <platform.h>
#include <xs1.h>
#include "pwm_tutorial_example.h"
#include "i2c.h"

#define TILE_IDX 1

on tile[TILE_IDX] : out port p_led = XS1_PORT_4A;

struct r_i2c i2cOne = {
		XS1_PORT_1F,
		XS1_PORT_1B,
		1000
};


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


int main() {
	chan c_pwm_duty;
	par {
		on tile[TILE_IDX]: {
			pwm_tutorial_example(c_pwm_duty, p_led, 4);
		}
		on tile[TILE_IDX]: {
			//pwm_controller(c_pwm_duty);
			pwm_controller_thermo(c_pwm_duty);
		}

	}
	return 0;
}
