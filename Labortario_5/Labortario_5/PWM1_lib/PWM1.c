/*
 * PWM1.c
 *
 * Created: 4/7/2025 5:06:56 PM
 *  Author: andre
 */ 
#include "PWM1.h"

void PMW1_init(){
	DDRB |= (1 << DDB1); //pb1 como salida (OC1A)
	
	//configuramos timer1 en modo Fast PMW con ICR1 como TOP (modo 14)
	TCCR1A |= (1 << COM1A1) | (1 << WGM11); //pmw no invertido
	TCCR1B |= (1 << WGM13) | (1 << WGM12) | (1 << CS11);  //prescaler 8 modo 14
	
	ICR1 = 39999; //TOP = 39999 frecuencia 50Hz (20ms)
}

void PMW1_SetDutyCycle(uint16_t duty){
	OCR1A = duty; //valor del pulso (2000 = 1ms)
}


