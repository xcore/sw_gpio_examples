#include "temp_sensor.h"

static int TEMPERATURE_LUT[][2]= //Temperature Look up table
{
		{-10,850},{-5,800},{0,750},{5,700},{10,650},{15,600},{20,550},{25,500},{30,450},{35,400},
		{40,350},{45,300},{50,250},{55,230},{60,210}
};


static int linear_interpolation(int adc_value)
{
  int i=0,x1,y1,x2,y2,temper;
  while(adc_value<TEMPERATURE_LUT[i][1])
    {
      i++;
    }
  //Calculating Linear interpolation using the formula y=y1+(x-x1)*(y2-y1)/(x2-x1)
  x1=TEMPERATURE_LUT[i-1][1];
  y1=TEMPERATURE_LUT[i-1][0];
  x2=TEMPERATURE_LUT[i][1];
  y2=TEMPERATURE_LUT[i][0];
  temper=y1+(((adc_value-x1)*(y2-y1))/(x2-x1)); //Calculate temeperature valus using linear interploation technique
  return temper;//Return Temperature value
}

//::TEMP sensor
[[distributable]]
void temp_sensor(server interface temp_sensor_if c[n], unsigned n,
                 client interface i2c_master_if c_i2c)
{
  c_i2c.write_reg(0x28, 0x00, 0x13);
  while (1) {
    select {
    case c[int i].get_temp(void) -> int value:
      int adc_value;
      unsigned char data[2];
      //Read value from ADC
      c_i2c.rx(0x28, data, 2);
      data[0] = data[0] & 0x0F;
      adc_value = (data[0] << 6) | (data[1] >> 2);
      value = linear_interpolation(adc_value);
      break;
    }
  }
}

//::TEMP sensor end
