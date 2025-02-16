
;Universidad del Valle de Guatemala
;IE2023 : Programación de Microcontroladores
;PRELAB2.asm
;
;Autor: andres barrientos
;Proyecto: Lab 2
;Hardware: ATMega328P


.INCLUDE "M328PDEF.INC"
.cseg
.org	0x0000

//PRELAB modidificado
LDI		R16, 0xFF
OUT		DDRC, R16		//PORTC como salida

LDI		R16, 0x05		//prescaler de 1024
OUT		TCCR0B, R16		//configurar el timer0

LDI		R17, 0			//iniciamos el contador de segundos
LDI		R19, 0			//iniciamos el contador de 100ms

LOOP:
	CALL	T100ms
	INC		R19			//incrementar el contador
	CPI		R19, 10		//ver si han pasado los 10 ciclos (1 segundo)
	BRNE	LOOP
	LDI		R19, 0
	INC		R17
	OUT		PORTC, R17
	RJMP	LOOP

T100ms:
	LDI		R18, 6

TIEMPO:
	SBIS	TIFR0, TOV0		//esperar a que el timer0 se desborde
	RJMP	TIEMPO
	LDI		R16, (1 << TOV0)	//restablecer bandera de desbordamiento
	OUT		TIFR0, R16
	DEC		R18
	BRNE	TIEMPO
	RET

//LAB

.def	COUNTER = R20

LDI		R16, 0xFF
OUT		DDRD, R16		//configuramos PORTD como salida para el display
LDI		R16, 0xC0     	//apagamos los segmentos con 1 en vez de 0 porque el display es de anodo comun
OUT		PORTD, R16		//se carga a portd para que empiece en 0

LDI		R16, 0x00
OUT		DDRB, R16		// coonfigura los botones como entrada
LDI		R16, 0b00000011	//ahora tenemos 00000110 ya que usaremos el bit 0 del PORTB para un segmento del display
OUT		PORTB, R16		//habilita el pull-up en PB1 y PB2

LDI		COUNTER, 0x00

MAIN:
	SBIC	PINB, 1		//si PB1 (B1) esta  presionado, llama a incremento
	CALL	INCREMENTO
	SBIC	PINB, 2		//si PB2 (B2) esta presionado, llama a decremento
	CALL	DECREMENTO

	CALL	DISPLAY
	RJMP	MAIN

INCREMENTO:
	CALL	ANTIRREBOTE
	INC		COUNTER
	CPI		COUNTER, 16
	BRLO	RETURN
	LDI		COUNTER, 0
	RET

RETURN:
	RET

DECREMENTO:
	CALL	ANTIRREBOTE					
	DEC		COUNTER
	BRPL	RETURN
	LDI		COUNTER, 15
	RET


ANTIRREBOTE:
	LDI		R18, 100
WAIT:
	NOP
	DEC		R18
	BRNE	WAIT
	RET	

DISPLAY:
	LDI		ZH, HIGH(TABLA)
	MOV		ZL, COUNTER
	LPM		R16, Z				//leer el valor de la tabla
	OUT		PORTD, R16
	RET

TABLA: .DB 0xC0, 0xF9, 0xA4, 0xB0, 0x99, 0x92, 0x82, 0xF8, 0x80, 0x90, 0x88, 0x83, 0xC6, 0xA1, 0x86, 0x8E
