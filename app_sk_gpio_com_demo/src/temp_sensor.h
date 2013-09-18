#ifndef __temp_sensor_h__
#define __temp_sensor_h__
#include "i2c.h"

interface temp_sensor_if {
  int get_temp(void);
};

/**
* Reads ADC value from the Temperature sensor and calculates the temperature
* value using Linear Interpolation.
* @param	temp_sensor_if 	Server Interface to temperature sensor
* @param	n 	Number of server interfaces
* @param	i2c_master_if 	Client Interface to I2C
* @return	None
*/

[[distributable]]
void temp_sensor(server interface temp_sensor_if c[n], unsigned n,
                 client interface i2c_master_if i2c);

#endif // __temp_sensor_h__
