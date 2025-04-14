/*
 * Labortario_5.c
 *
 * Created: 4/7/2025 5:06:11 PM
 * Author : andre
 */ 

#define F_CPU 16000000
#include <avr/io.h>
#include <util/delay.h>
#include "PWM1_lib/PWM1.h"
#include "PMW2_lib/PMW2.h"
#include "PMW_LED/PMW_LED.h"

void ADC_init();
uint16_t ADC_Read(uint8_t channel);

int main(void)
{
	ADC_init();
    PMW1_init();
	PMW2_init();
	PMW_LED_init();
	
    while (1) 
    {
		uint16_t adc_value = ADC_Read(0); //lee el potenciometro (PC0)
		uint16_t pmw_value1 = (3600.0/1023.0)*adc_value + 1200; //mapea
		PMW1_SetDutyCycle(pmw_value1); //ajusta el servo
		
		uint16_t adc_value2 = ADC_Read(1); //lee el potenciometro (PC1)
		int16_t pmw_value2 = (uint8_t)((45.0/1023.0)*adc_value2)+5;
		PMW2_SetDutyCycle(pmw_value2); //ajusta el servo
		
		uint16_t adc_value3 = ADC_Read(2);
		uint8_t brillo = (uint8_t)((63.0/1023.0)*adc_value3);
		PMW_LED_BRILLO(brillo);
		
		_delay_ms(10);
    }
}

void ADC_init(){
	ADMUX |= (1 << REFS0);		//voltaje de referencia
	ADCSRA |= (1 << ADPS2) | (1 << ADPS1) | (1 << ADPS0); //PRESCALER 128 (125kHz)
	ADCSRA |= (1 << ADEN);		//habilita el adc
}

uint16_t ADC_Read(uint8_t channel){
	ADMUX = (ADMUX & 0xF8) | (channel & 0x07); //selecciona el canal
	ADCSRA |= (1 << ADSC);	//inicia la conversion
	while (ADCSRA & (1 << ADSC)); //espera hasta que termine
	return ADC;		//refresca el valor de 10 bits
}

