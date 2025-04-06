//**********************************************************
// Universidad del Valle de Guatemala
// IE2023 : Programación de Microcontroladores
// Proyecto: Laboratorio 4
// Autor: Andrés Barrientos
// Fecha: 04/04/2025
//**********************************************************

#define F_CPU 16000000UL
#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>

volatile uint8_t counter = 0;
volatile uint8_t adc_value = 0;
volatile uint8_t mux_state = 0;

const uint8_t tabla[16] = {0xC0, 0xF9, 0xA4, 0xB0, 0x99, 0x92, 0x82, 0xF8, 0x80, 0x90, 0x88, 0x83, 0xC6, 0xA1, 0x86, 0x8E};

void initADC() {
	ADMUX = (1 << REFS0) | (1 << ADLAR) | (1 << MUX2) | (1 << MUX1); //
	ADCSRA = (1 << ADEN) | (1 << ADPS2) | (1 << ADPS1) | (1 << ADPS0) | (1 << ADIE); 
	ADCSRA |= (1 << ADSC);
}

void initTimers() {
	// Timer0 para botones (~10ms)
	TCCR0A = 0;
	TCCR0B = (1 << CS02) | (1 << CS00);
	TIMSK0 = (1 << TOIE0);
	
	// Timer2 para multiplexado rápido
	TCCR2A = 0;
	TCCR2B = (1 << CS21); // prescaler 8
	TIMSK2 = (1 << TOIE2);
}

void setup() {
	// PORTD: segmentos
	DDRD = 0xFF;
	PORTD = 0xFF;

	// PORTC: contador (salida)
	DDRC = 0xFF;
	PORTC = 0x00;

	// PB0 y PB1 como entradas (botones)
	DDRB &= ~((1 << PB0) | (1 << PB1));
	PORTB |= (1 << PB0) | (1 << PB1); // pull-up

	// PB2 y PB3: transistores displays
	DDRB |= (1 << PB2) | (1 << PB3);

	// PB5: LED de alarma
	DDRB |= (1 << PB5);
	PORTB &= ~(1 << PB5);

	initADC();
	initTimers();
	sei();
}

int main(void) {
	setup();
	while (1) {
		// Mostrar contador
		PORTC = counter;

		// Alarma
		if (adc_value > counter) {
			PORTB |= (1 << PB5); // Encender alarma
			} else {
			PORTB &= ~(1 << PB5); // Apagar alarma
		}
	}
}

// Timer2 - multiplexado displays
ISR(TIMER2_OVF_vect) {
	// Apagar ambos displays
	PORTB &= ~((1 << PB2) | (1 << PB3));

	uint8_t low = adc_value & 0x0F;
	uint8_t high = (adc_value >> 4) & 0x0F;

	if (mux_state == 0) {
		PORTD = tabla[low];
		PORTB |= (1 << PB2);
		} else {
		PORTD = tabla[high];
		PORTB |= (1 << PB3);
	}
	mux_state ^= 1;
}

// Timer0 - botones
ISR(TIMER0_OVF_vect) {
	static uint8_t prevB0 = 1;
	static uint8_t prevB1 = 1;

	uint8_t nowB0 = PINB & (1 << PB0);
	uint8_t nowB1 = PINB & (1 << PB1);

	if (!nowB0 && prevB0) {
		if (counter > 0) counter--;
	}
	if (!nowB1 && prevB1) {
		if (counter < 255) counter++;
	}
	prevB0 = nowB0;
	prevB1 = nowB1;
}

// ADC - lectura de potenciómetro
ISR(ADC_vect) {
	adc_value = ADCH;
	ADCSRA |= (1 << ADSC); // iniciar nueva conversión
}