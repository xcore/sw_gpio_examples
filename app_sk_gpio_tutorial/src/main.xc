#include <platform.h>
#include <xs1.h>
#include "pwm_tutorial_example.h"

on tile[0] : out port p_led = XS1_PORT_4A;

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

int main() {
	chan c_pwm_duty;
	par {
		on tile[0]: {
			pwm_tutorial_example(c_pwm_duty, p_led, 4);
		}
		on tile[0]: {
			pwm_controller(c_pwm_duty);
		}

	}
	return 0;
}
