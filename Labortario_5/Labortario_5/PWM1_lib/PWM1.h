/*
 * PWM1.h
 *
 * Created: 4/7/2025 5:06:46 PM
 *  Author: andre
 */ 
#include <avr/io.h>

#ifndef PWM1_H_
#define PWM1_H_

void PMW1_init();
void PMW1_SetDutyCycle(uint16_t duty);

#endif /* PWM1_H_ */