/*
 * PMW_LED.c
 *
 * Created: 4/14/2025 11:19:41 AM
 *  Author: andre
 */ 

#include "PMW_LED.h"

volatile uint8_t pmw_counter = 0;
volatile uint8_t pmw_valor = 128;

void PMW_LED_init(){
	//configuramos PD5 como salida para el LED
	DDRD |= (1 << DDD5);
	
	//configuramos timer0 para interrupciones regulares
	TCCR0A = 0; //modo normal
	TCCR0B = (1 << CS00);		//no prescaler
	TIMSK0 |= (1 << TOIE0);			//habilitamos intnerrupcion por desbordamiento
	
	sei();
}

void PMW_LED_BRILLO(uint8_t brillo){
	pmw_valor = brillo;
}

//rutina de interrupcion para el timer0
ISR(TIMER0_OVF_vect){
	pmw_counter++;
	
	if(pmw_counter >= 64){
	pmw_counter = 0;
	}
	
	if (pmw_counter < pmw_valor){
		PORTD |= (1 << PORTD5);
	}
	else {
		PORTD &= ~(1 << PORTD5);
	}
}
