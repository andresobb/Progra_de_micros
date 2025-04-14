/*
 * PMW_LED.h
 *
 * Created: 4/14/2025 11:17:51 AM
 *  Author: andre
 */ 


#ifndef PMW_LED_H_
#define PMW_LED_H_

#include <avr/io.h>
#include <avr/interrupt.h>

void PMW_LED_init();
void PMW_LED_BRILLO(uint8_t brillo);

#endif /* PMW_LED_H_ */