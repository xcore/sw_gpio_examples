#ifndef __temp_sensor_h__
#define __temp_sensor_h__
#include "i2c.h"

interface temp_sensor_if {
  int get_temp(void);
};

[[distributable]]
void temp_sensor(server interface temp_sensor_if c[n], unsigned n,
                 client interface i2c_master_if i2c);

#endif // __temp_sensor_h__
