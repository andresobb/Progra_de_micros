/*
 * PMW2.c
 *
 * Created: 4/7/2025 5:41:26 PM
 *  Author: andre
 */ 

#include "PMW2.h"

void PMW2_init(){
	DDRD |= (1 << DDD3); //pd3 como salida para oc2b 
	
	//configuramos timer2 modo fast 3 
	TCCR2A = 0;
	TCCR2A |= (1 << COM2B1) | (1 << WGM21) | (1 << WGM20); //modo 3 011
	TCCR2B = 0;
	TCCR2B |= (1 << CS22) | (1 << CS21)| (1 << CS20);  //prescaler 1024 periodo 16.38ms 
	
	//ICR1 = 39999; //TOP = 39999 frecuencia 50Hz (20ms)
}

void PMW2_SetDutyCycle(uint16_t duty){
	//limitamos el valor a 255 (8 bits)
	if(duty > 255) duty = 255;
	OCR2B = duty; //valor del pulso 
}