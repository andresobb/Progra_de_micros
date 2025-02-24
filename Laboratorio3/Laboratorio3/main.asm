;Universidad del Valle de Guatemala
;IE2023 : Programación de Microcontroladores
;PRELAB2.asm
;
;Autor: andres barrientos
;Proyecto: Laboratorio 3
;Hardware: ATMega328P

.include "M328PDEF.INC"
.cseg

.org	0x0000
	JMP	START
.org	PCI0addr
	JMP	INT_BOTONAZO
.org	OVF0addr
	JMP	TIMER0_OVERFLOW

;stack pointer
START:
	LDI		R16, LOW(RAMEND)
	OUT		SPL, R16
	LDI		R16, HIGH(RAMEND)
	OUT		SPH, R16

;configuracion
SETUP:
	CLI		//inhabilitamos interrupciones
	
	;configuramos el prescaler principal
	LDI		R16, (1<<CLKPCE)		//habilitamos cambio del prescaler
	STS		CLKPR, R16
	LDI		R16, (1<<CLKPS2)
	STS		CLKPR, R16				//configuramos el prescaler a 16 F_CPU = 1MHz

	;configuramos el timer0
	LDI		R16, 0x00
	OUT		TCCR0A, R16
	;con 0x00 activamos el modo normal del timer0
	LDI		R16, (1<<CS01) | (1<<CS00)		//prescaler de 64
	OUT		TCCR0B, R16
	;activamos la interrupcion de overflow
	LDI		R16, (1<<TOIE0)
	STS		TIMSK0, R16

	;configuramos puertos

	LDI		R16, 0xFF
	OUT		DDRC, R16				//puerto C como salida

	LDI		R16, 0xFF
	OUT		DDRD, R16				//puerto D como salida

	LDI		R16, 0x00
	OUT		DDRB, R16				//puerto B como entrada (botones)
	LDI		R16, 0xFF
	OUT		PORTB, R16				//activamos pullups internos

	;configuramos interrupciones
	LDI		R16, (1<<PCINT1) | (1<<PCINT0)
	STS		PCMSK0, R16
	LDI		R16, (1<<PCIE0)
	STS		PCICR, R16

	;apagamos los demas leds del arduino
	LDI		R16, 0x00
	STS		UCSR0B, R16

	;seteamos r20 como contador de 4 bits
	LDI		R20, 0x00

	;seteamos r18 como contador de 4 bits
	LDI		R18, 0x00

	;botones inicialmente encendidos
	LDI		R23, 0xFF

	SEI

;loop infinito
LOOP:
	CALL DISPLAY_UPDATE
	RJMP LOOP

;rutinas de interrupciones
INT_BOTONAZO:
	PUSH	R16
	IN		R16, SREG
	PUSH	R16

	IN		R21, PINB
	MOV		R22, R21		//guardamos el estado actual
	SBRS	R22, 0
	CALL	INCREMENTO
	SBRS	R22, 1
	CALL	DECREMENTO
	OUT		PORTC, R20
	LDI		R16, (1<<PCIF0)		//limpiar la bandera de interrupcion de pin-change
	STS		PCIFR, R16

	POP		R16
	OUT		SREG, R16
	POP		R16
	RETI

TIMER0_OVERFLOW:
	PUSH	R16
	IN		R16, SREG
	PUSH	R16

	CLI
	INC		R17		//incrementamos contador de interrupciones
	SEI

	CPI		R18, 0x0A
	BREQ	RESET_DISPLAY

	CPI		R17, 61		//61 interrupciones (1000ms) 16.3ms * 61 = 994.3ms
	BRNE	END_ISR		//si no han pasado, salir de la interrupcion

	LDI		R17, 0x00	//reinicia el contador de interrupciones
	INC		R18

END_ISR:
	POP		R16
	OUT		SREG, R16
	POP		R16
	RETI

;subrutinas sin interrupciones
INCREMENTO:
	INC		R20
	CPI		R20, 0x10
	BRNE	CONTINUAR
	LDI		R20, 0x00

RESET_DISPLAY:
	LDI		R18, 0x00
	RET

CONTINUAR:
	CALL	DISPLAY_UPDATE
	RET

DECREMENTO:
	CPI		R20, 0x00
	BREQ	MAXEO
	DEC		R20
	RET

RESET:
	LDI		R20, 0x00
	RET

MAXEO:
	LDI		R20, 0x0F
	RET

DISPLAY_UPDATE:
	LDI		ZH, HIGH(TABLA<<1)
	LDI		ZL, LOW(TABLA<<1)
	ADD		ZL, R18
	ADC		ZH, R1					//r1 siempre es 0 por lo que 0+r20
	LPM		R16, Z					//carga el byte Z en r16
	OUT		PORTD, R16
	RET

//tabla con valores para el display
TABLA:
	.DB 0x3F, 0xFC, 0x5B, 0x4F, 0x39, 0x12, 0x7F, 0x4F, 0x7F, 0x6F
																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																											