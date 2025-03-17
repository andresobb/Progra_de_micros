;Universidad del Valle de Guatemala
;IE2023 : Programacion de Microcontroladores
;RELOJ.asm
;
;Autor: andres barrientos
;Proyecto 1: RELOJ
;Hardware: ATMega328P

.include "M328PDEF.inc"
.cseg

.def	unitdia = R0
.def	decdia = R1
.def	unitmes = R2
.def	decmes = R3
.def	Aunitmin = R4
.def	Adecmin = R5
.def	Aunithora = R6
.def	Adechora = R7
.def	contador500ms = R18
.def	contador1s = R19
.def	estado = R20
.def	unitseg = R21
.def	decseg = R22
.def	unitmin = R23
.def	decmin = R24
.def	unithora = R25
//.def	dechora = R26

.org 0x00
	jmp MAIN

.org 0x0006
	jmp ISR_PCINT0

.org 0x0020
	jmp ISR_TIMER0_OVF

MAIN:
	LDI R16, LOW(RAMEND)
	OUT SPL, R16
	LDI R17, HIGH(RAMEND)
	OUT SPH, R17

TABLA: .DB 0xC0, 0xF9, 0xA4, 0xB0, 0x99, 0x92, 0x82, 0xF8, 0x80, 0x90

	;INPUTS
	SBI PORTB, PB0
	CBI DDRB, PB0
	SBI PORTB, PB1
	CBI DDRB, PB1
	SBI PORTB, PB2
	CBI DDRB, PB2
	
	;OUTPUT
	LDI R16, 0XFF		; DISPLAY
	OUT DDRC, R16
	SBI DDRB, PB4		
	CBI PORTB, PB4
	
	SBI DDRB, PB3		
	CBI PORTB, PB3
	
	SBI DDRB, PB5		; ALARMA
	CBI PORTB, PB5
	
	;TRANSISTORS
	LDI R16, 0XFF
	OUT DDRD, R16
	
	CALL INIT_TIMER0	; INICIALIZAR TIMER0

	; INTERRUPCIONES POR PULSADORES
				; PB2           PB1           PB0
    LDI R16, (1 << PCINT2)|(1 << PCINT1)|(1 << PCINT0)
    STS PCMSK0, R16   

    LDI R16, (1 << PCIE0)
    STS PCICR, R16        

    SEI                    ; HABILITAR INTERRUPCIONES GLOBALES

    CLR R27               
    LDI ZH, HIGH(TABLA << 1)
    LDI ZL, LOW(TABLA << 1)
    ADD ZL, R27
    LPM R27, Z

; VALORES INICIALES
    CLR CONTADOR500MS
    CLR CONTADOR1S
    LDI ESTADO, 0

    LDI R28, 0B1000_0000
    MOV R8, R28

    CLR R28
; HORA
    LDI R26, 0
    LDI UNITHORA, 0
    LDI DECMIN, 0 
    LDI UNITMIN, 0
    LDI DECSEG, 0
    LDI UNITSEG, 0

; FECHA
    LDI R28, 0
    MOV DECDIA, R28
    LDI R28, 1
    MOV UNITDIA, R28

    LDI R28, 0
    MOV DECMES, R28
    LDI R28, 1
    MOV UNITMES, R28

; ALARMA
    LDI R28, 0
    MOV ADECHORA, R28
    LDI R28, 0
    MOV AUNITHORA, R28

    LDI R28, 0
    MOV ADECMIN, R28
    LDI R28, 0
    MOV AUNITMIN, R28

    LDI R29, 0

//****************************
//LOOP
//****************************

LOOP:
    SBRs ESTADO, 0        
    JMP EX000             
    JMP EXXX1             
    
    RJMP PULSO

//***************************************************************************
// PULSO
//***************************************************************************
PULSO:
    CPI CONTADOR500MS, 50
    BRNE LOOP
    CLR CONTADOR500MS
    ; encender o no: DOS PUNTOS
    SBRc R8, 7
    SBI PINB, PB3
    SBRs R8, 7
    CBI PORTB, PB3

    INC CONTADOR1S
    CPI CONTADOR1S, 2
    BRNE LOOP
    CLR CONTADOR1S
    ; segundos
    LDI R28, 9
    CPSE UNITSEG, R28
    CALL INC_UNITSEG
    CLR UNITSEG

    LDI R28, 5
    CPSE DECSEG, R28
    CALL INC_DECSEG
    CLR DECSEG
    ; minutos
    LDI R28, 9
    CPSE UNITMIN, R28
    CALL INC_UNITMIN
    CLR UNITMIN

    LDI R28, 5
    CPSE DECMIN, R28
    CALL INC_DECMIN
    CLR DECMIN

    ; horas
    LDI R28, 9
    CPSE UNITHORA, R28
    CALL INC_UNITHORA
    CLR UNITHORA

    LDI R28, 2
    CPSE R26, R28
    CALL INC_DECHORA
    CLR R26

    RJMP LOOP

//***************************************************************************
// DEFINIR ESTADOS
//***************************************************************************
EXXX0:
	SBRS ESTADO, 1
	JMP EXX00
	JMP EXX10

EXX00:
	SBRS ESTADO, 2
	JMP EX000
	JMP EX100

EX000:
	SBRS ESTADO, 3
	JMP E0000
	JMP E1000

EXXX1:
	SBRS ESTADO, 1
	JMP EXX01
	JMP EXX11

EXX01:
	SBRS ESTADO, 2
	JMP EX001
	JMP EX101

EX001:
	SBRS ESTADO, 3
	JMP E0001
	JMP E1001

EXX10:
	SBRS ESTADO, 2
	JMP EX010
	JMP EX110

EX010:
	SBRS ESTADO, 3
	JMP E0010
	JMP E1010

EXX11:
	SBRS ESTADO, 2
	JMP EX011
	JMP EX111

EX011:
	SBRS ESTADO, 3
	JMP E0011
	JMP E1011

EX100:
	SBRS ESTADO, 3
	JMP E0100
	JMP LOOP
	
EX101:
	SBRS ESTADO, 3
	JMP E0101

EX110:
	SBRS ESTADO, 3
	JMP E0110

EX111:
	SBRS ESTADO, 3
	JMP E0111

//***************************************************************************
// ESTADOS
//***************************************************************************
;                                     0000
E0000:
	LDI R28, 0b1000_0000
	MOV R8, R28
	CALL UNITMIN_DISPLAY
	CALL DECMIN_DISPLAY
	CALL UNITHORA_DISPLAY
	CALL DECHORA_DISPLAY

	SBRS R29, 0
	CBI PORTB, PB5
	SBRC R29, 0
	CALL ALARMA

	RJMP PULSO
	JMP LOOP

;                                     0001
E0001:
	CLR R8
	CALL UNITDIA_DISPLAY
	CALL DECDIA_DISPLAY
	CALL UNITMES_DISPLAY
	CALL DECMES_DISPLAY
	RJMP PULSO
	JMP LOOP

;                                     0010
E0010:
	SBI PORTB, PB3
	CALL AUNITMIN_DISPLAY
	CALL ADECMIN_DISPLAY
	CALL AUNITHORA_DISPLAY
	CALL ADECHORA_DISPLAY
	CLR R8
	RJMP PULSO
	JMP LOOP

;                                     0011
E0011:
	CLR R8
	CALL UNITHORA_DISPLAY
	CALL DECHORA_DISPLAY
	RJMP PULSO
	JMP LOOP

;                                     0100
E0100:
	LDI R28, 12
	CALL UNITDIA_DISPLAY
	CALL DECDIA_DISPLAY
	RJMP PULSO
	JMP LOOP

;                                     0101
E0101:
	CALL AUNITHORA_DISPLAY
	CALL ADECHORA_DISPLAY
	RJMP PULSO
	JMP LOOP

;                                     0110
E0110:
	CLR R8
	CALL UNITMIN_DISPLAY
	CALL DECMIN_DISPLAY
	RJMP PULSO
	JMP LOOP

;                                     0111
E0111:
	CALL UNITMES_DISPLAY
	CALL DECMES_DISPLAY
	RJMP PULSO
	JMP LOOP

;                                     1000
E1000:
	CALL AUNITMIN_DISPLAY
	CALL ADECMIN_DISPLAY
	RJMP PULSO
	JMP LOOP

;                                     1001
E1001:
	LDI R29, 0
	RJMP PULSO
	JMP LOOP

;                                     1010
E1010:
	LDI R29, 1
	JMP LOOP

;                                     1011
E1011:
	CLR R8
	SBI PORTB, PB3
	SBI PORTB, PB5
	CALL UNITMIN_DISPLAY
	CALL DECMIN_DISPLAY
	CALL UNITHORA_DISPLAY
	CALL DECHORA_DISPLAY
	RJMP PULSO
	JMP LOOP

//***************************************************************************
// ALARMA COMPARACION
//***************************************************************************
ALARMA:
    CPSE ADECHORA, R26
    RET
    CPSE AUNITHORA, UNITHORA
    RET
    CPSE ADECMIN, DECMIN
    RET
    CPSE AUNITMIN, UNITMIN
    RET
    LDI ESTADO, 11
    RET
    
//***************************************************************************
// TIMER0
//***************************************************************************
INIT_TIMER0:
    LDI R16, (1 << CS02)|(1 << CS00)    ;config prescaler 1024
    OUT TCCR0B, R16
    LDI R16, 99                         ;valor desbordamiento
    OUT TCNT0, R16                       ; valor inicial contador
    LDI R16, (1 << TOIE0)
    STS TIMSK0, R16
    RET

//***************************************************************************
// ISR Timer 0 Overflow
//***************************************************************************
ISR_TIMER0_OVF:
    ;PUSH R17                ; guardar en pila R16
    ;IN R17, SREG
    ;PUSH R17                ; guardar en pila SREG

    LDI R17, 99              ; cargar el valor de desbordamiento
    OUT TCNT0, R17           ; cargar valor inicial
    SBI TIFR0, TOV0          ; borrar bandera TOV0
    INC CONTADOR500MS            ; incrementar contador 10 ms

    ;POP R17                  ; obtener SREG
    ;OUT SREG, R17           ; restaurar valor antiguo SREG
    ;POP R17                  ; obtener valor R16
    RETI

//***************************************************************************
// ISR PCINT0
//***************************************************************************
ISR_PCINT0:
    PUSH R16
    IN R16, SREG
    PUSH R16

    SBRs ESTADO, 0           ; estado bit0 = 1?
    JMP ISR_EXX00      ; bit0 = 0
    JMP ISR_EXX01      ; bit0 = 1

//***************************************************************************
// DEFINIR ISR_ESTADOS
//***************************************************************************
ISR_EXXX0:
	SBRS ESTADO, 1
	JMP ISR_EXX00
	JMP ISR_EXX10

ISR_EXX00:
	SBRS ESTADO, 2
	JMP ISR_EX000
	JMP ISR_EX100

ISR_EX000:
	SBRS ESTADO, 3
	JMP ISR_E0000
	JMP ISR_E1000

ISR_EXXX1:
	SBRS ESTADO, 1
	JMP ISR_EXX01
	JMP ISR_EXX11

ISR_EXX01:
	SBRS ESTADO, 2
	JMP ISR_EX001
	JMP ISR_EX101
ISR_EX001:
	SBRS ESTADO, 3
	JMP ISR_E0001
	JMP ISR_E1001
ISR_EXX10:
	SBRS ESTADO, 2
	JMP ISR_EX010
	JMP ISR_EX110
ISR_EX010:
	SBRS ESTADO, 3
	JMP ISR_E0010
	JMP ISR_E1010
ISR_EXX11:
	SBRS ESTADO, 2
	JMP ISR_EX011
	JMP ISR_EX111
ISR_EX011:
	SBRS ESTADO, 3
	JMP ISR_E0011
	JMP ISR_E1011
ISR_EX100:
	SBRS ESTADO, 3
	JMP ISR_E0100
	JMP ISR_POP_PCINT0
ISR_EX101:
	SBRS ESTADO, 3
	JMP ISR_E0101
	JMP ISR_POP_PCINT0
ISR_EX110:
	SBRS ESTADO, 3
	JMP ISR_E0110
	JMP ISR_POP_PCINT0
ISR_EX111:
	SBRS ESTADO, 3
	JMP ISR_E0111
	JMP ISR_POP_PCINT0

//***************************************************************************
// ISR_ESTADOS
//***************************************************************************
//                                     0000
ISR_E0000:
	IN R16, PINB
	SBRS R16, PB0
	LDI ESTADO, 1			; PB0 = 0
	IN R16, PINB
	SBRS R16, PB1
	LDI ESTADO, 2			; PB1 = 0
	IN R16, PINB
	SBRS R16, PB2
	LDI ESTADO, 3			; PB2 = 0
	JMP ISR_POP_PCINT0
//                                     0001
ISR_E0001:
	IN R16, PINB
	SBRS R16, PB0
	LDI ESTADO, 0			; PB0 = 0
	IN R16, PINB
	SBRS R16, PB2
	LDI ESTADO, 7
	JMP ISR_POP_PCINT0
//                                     0010
ISR_E0010:
	IN R16, PINB
	SBRS R16, PB2			; PB2
	LDI ESTADO, 5
	IN R16, PINB
	SBRS R16, PB1
	LDI ESTADO, 0			; PB1 = 0
	JMP ISR_POP_PCINT0
//                                     0011
ISR_E0011:
	IN R16, PINB
	SBRS R16, PB0
	JMP ISR_INC_UNITHORA			; PB0 = 0
	IN R16, PINB
	SBRS R16, PB1
	JMP ISR_DEC_UNITHORA		; PB1 = 0
	IN R16, PINB
	SBRS R16, PB2
	LDI ESTADO, 6			; PB2 = 0
	JMP ISR_POP_PCINT0
//                                     0100
ISR_E0100:
	IN R16, PINB
	SBRS R16, PB2
	LDI ESTADO, 1			; PB2 = 0
	IN R16, PINB
	SBRS R16, PB0
	JMP ISR_INC_UNITDIA
	IN R16, PINB
	SBRS R16, PB1
	JMP ISR_DEC_DIA
	JMP ISR_POP_PCINT0
//                                     0101
ISR_E0101:
	IN R16, PINB
	SBRS R16, PB2
	LDI ESTADO, 8
	IN R16, PINB
	SBRS R16, PB0
	JMP ISR_INC_AUNITHORA
	IN R16, PINB
	SBRS R16, PB1
	JMP ISR_DEC_AUNITHORA
	JMP ISR_POP_PCINT0
//                                     0110
ISR_E0110:
	IN R16, PINB
	SBRS R16, PB2
	LDI ESTADO, 0			; PB2 = 0
	IN R16, PINB
	SBRS R16, PB0
	JMP ISR_INC_UNITMIN
	IN R16, PINB
	SBRS R16, PB1
	JMP ISR_DEC_UNITMIN
	JMP ISR_POP_PCINT0
//                                     0111
ISR_E0111:
	IN R16, PINB
	SBRS R16, PB2
	LDI ESTADO, 4			; PB2 = 0
	IN R16, PINB
	SBRS R16, PB0
	JMP ISR_INC_UNITMES
	IN R16, PINB
	SBRS R16, PB1
	JMP ISR_DEC_UNITMES
	JMP ISR_POP_PCINT0
//                                     1000
ISR_E1000:
	IN R16, PINB
	SBRS R16, PB2
	LDI ESTADO, 9
	IN R16, PINB
	SBRS R16, PB0
	JMP ISR_INC_AUNITMIN
	IN R16, PINB
	SBRS R16, PB1
	JMP ISR_DEC_AUNITMIN
	JMP ISR_POP_PCINT0
//                                     1001
ISR_E1001:
	IN R16, PINB
	SBRS R16, PB2
	LDI ESTADO, 2
	IN R16, PINB
	SBRS R16, PB0
	LDI ESTADO, 10
	JMP ISR_POP_PCINT0
//                                     1010
ISR_E1010:
	IN R16, PINB
	SBRS R16, PB2
	LDI ESTADO, 2
	IN R16, PINB
	SBRS R16, PB1
	LDI ESTADO, 9
	JMP ISR_POP_PCINT0
//                                     1011
ISR_E1011:
	IN R16, PINB
	SBRS R16, PB2
	JMP ISR_E1011_2
	JMP ISR_POP_PCINT0

ISR_E1011_2:
	LDI R29, 0
	LDI ESTADO, 0
	CBI PORTB, PB5
	JMP ISR_POP_PCINT0

//***************************************************************************
// ISR_POP_PCINT0
//***************************************************************************
ISR_POP_PCINT0:
	SBI PCIFR, PCIF0

	POP R16
	OUT SREG, R16
	POP R16
	RETI

//***************************************************************************
// TEST_DISPLAY
//***************************************************************************
TEST_DISPLAY:
	sbi PINC, PC0
	sbi PINC, PC1
	sbi PINC, PC2
	sbi PINC, PC3
	sbi PINC, PC4
	sbi PINC, PC5
	sbi PINB, PB4
	;sbi PORTB, PB3
	;sbi PINB, PB5

	sbi PIND, PD2
	sbi PIND, PD3
	sbi PIND, PD4
	sbi PIND, PD5
	sbi PIND, PD6
	sbi PIND, PD7
	
	ret

//***************************************************************************
// TEST LISTA DISPLAY
//***************************************************************************
TEST_LISTA_DISPLAY:
	;ldi useg, 0 
	mov R27, UNITSEG
	ldi ZH, HIGH(TABLA << 1)
	ldi ZL, LOW(TABLA << 1)
	add ZL, R27
	lpm R27, Z

	sbrc R27, PC6
	sbi PORTB, PB4
	sbrs R27, PC6
	cbi PORTB, PB4

	out PORTC, R27
	sbi PIND, PD7

	ret

//***************************************************************************
// UNITMIN DISPLAY
//***************************************************************************
UNITMIN_DISPLAY:
	CBI PORTD, PD2
	CBI PORTD, PD3
	CBI PORTD, PD4
	CBI PORTD, PD6
	CBI PORTD, PD7

	MOV R27, UNITMIN
	LDI ZH, HIGH(TABLA << 1)
	LDI ZL, LOW(TABLA << 1)
	ADD ZL, R27
	LPM R27, Z

	CBI PORTD, PD2
	CBI PORTD, PD3
	CBI PORTD, PD4
	CBI PORTD, PD6
	CBI PORTD, PD7

	SBRS R27, PC6
	CBI PORTB, PB4
	SBRC R27, PC6
	SBI PORTB, PB4

	OUT PORTC, R27
	SBI PORTD, PD5
	
	CBI PORTD, PD2
	CBI PORTD, PD3
	CBI PORTD, PD4
	CBI PORTD, PD6
	CBI PORTD, PD7

	RET

//***************************************************************************
// DECMIN DISPLAY
//***************************************************************************
DECMIN_DISPLAY:
	CBI PORTD, PD2
	CBI PORTD, PD3
	CBI PORTD, PD5
	CBI PORTD, PD6
	CBI PORTD, PD7

	MOV R27, DECMIN
	LDI ZH, HIGH(TABLA << 1)
	LDI ZL, LOW(TABLA << 1)
	ADD ZL, R27
	LPM R27, Z

	CBI PORTD, PD2
	CBI PORTD, PD3
	CBI PORTD, PD5
	CBI PORTD, PD6
	CBI PORTD, PD7

	SBRS R27, PC6
	CBI PORTB, PB4
	SBRC R27, PC6
	SBI PORTB, PB4

	OUT PORTC, R27
	SBI PORTD, PD4
	
	CBI PORTD, PD2
	CBI PORTD, PD3
	CBI PORTD, PD5
	CBI PORTD, PD6
	CBI PORTD, PD7

	RET

//***************************************************************************
// UNITHORA DISPLAY
//***************************************************************************
UNITHORA_DISPLAY:
	CBI PORTD, PD2
	CBI PORTD, PD4
	CBI PORTD, PD5
	CBI PORTD, PD6
	CBI PORTD, PD7

	MOV R27, UNITHORA
	LDI ZH, HIGH(TABLA << 1)
	LDI ZL, LOW(TABLA << 1)
	ADD ZL, R27
	LPM R27, Z

	CBI PORTD, PD2
	CBI PORTD, PD4
	CBI PORTD, PD5
	CBI PORTD, PD6
	CBI PORTD, PD7

	SBRS R27, PC6
	CBI PORTB, PB4
	SBRC R27, PC6
	SBI PORTB, PB4

	OUT PORTC, R27
	SBI PORTD, PD3
	
	CBI PORTD, PD2
	CBI PORTD, PD4
	CBI PORTD, PD5
	CBI PORTD, PD6
	CBI PORTD, PD7

	RET

//***************************************************************************
// DECHORA DISPLAY
//***************************************************************************
DECHORA_DISPLAY:
	CBI PORTD, PD3
	CBI PORTD, PD4
	CBI PORTD, PD5
	CBI PORTD, PD6
	CBI PORTD, PD7

	MOV R27, R26
	LDI ZH, HIGH(TABLA << 1)
	LDI ZL, LOW(TABLA << 1)
	ADD ZL, R27
	LPM R27, Z

	CBI PORTD, PD3
	CBI PORTD, PD4
	CBI PORTD, PD5
	CBI PORTD, PD6
	CBI PORTD, PD7

	SBRS R27, PC6
	CBI PORTB, PB4
	SBRC R27, PC6
	SBI PORTB, PB4

	OUT PORTC, R27
	SBI PORTD, PD2
	
	CBI PORTD, PD3
	CBI PORTD, PD4
	CBI PORTD, PD5
	CBI PORTD, PD6
	CBI PORTD, PD7

	RET

//***************************************************************************
// UNITDIA DISPLAY
//***************************************************************************
UNITDIA_DISPLAY:
	CBI PORTD, PD5
	CBI PORTD, PD4
	CBI PORTD, PD2
	CBI PORTD, PD6
	CBI PORTD, PD7

	MOV R27, UNITDIA
	LDI ZH, HIGH(TABLA << 1)
	LDI ZL, LOW(TABLA << 1)
	ADD ZL, R27
	LPM R27, Z

	CBI PORTD, PD5
	CBI PORTD, PD4
	CBI PORTD, PD2
	CBI PORTD, PD6
	CBI PORTD, PD7

	SBRS R27, PC6
	CBI PORTB, PB4
	SBRC R27, PC6
	SBI PORTB, PB4

	OUT PORTC, R27
	SBI PORTD, PD3
	
	CBI PORTD, PD5
	CBI PORTD, PD4
	CBI PORTD, PD2
	CBI PORTD, PD6
	CBI PORTD, PD7

	RET

//***************************************************************************
// DECDIA DISPLAY
//***************************************************************************
DECDIA_DISPLAY:
	CBI PORTD, PD3
	CBI PORTD, PD5
	CBI PORTD, PD4
	CBI PORTD, PD6
	CBI PORTD, PD7

	MOV R27, DECDIA
	LDI ZH, HIGH(TABLA << 1)
	LDI ZL, LOW(TABLA << 1)
	ADD ZL, R27
	LPM R27, Z

	CBI PORTD, PD3
	CBI PORTD, PD5
	CBI PORTD, PD4
	CBI PORTD, PD6
	CBI PORTD, PD7

	SBRS R27, PC6
	CBI PORTB, PB4
	SBRC R27, PC6
	SBI PORTB, PB4

	OUT PORTC, R27
	SBI PORTD, PD2
	
	CBI PORTD, PD3
	CBI PORTD, PD5
	CBI PORTD, PD4
	CBI PORTD, PD6
	CBI PORTD, PD7

	RET

//***************************************************************************
// UNITMES DISPLAY
//***************************************************************************
UNITMES_DISPLAY:
	CBI PORTD, PD4
	CBI PORTD, PD3
	CBI PORTD, PD2
	CBI PORTD, PD6
	CBI PORTD, PD7

	MOV R27, UNITMES
	LDI ZH, HIGH(TABLA << 1)
	LDI ZL, LOW(TABLA << 1)
	ADD ZL, R27
	LPM R27, Z

	CBI PORTD, PD4
	CBI PORTD, PD3
	CBI PORTD, PD2
	CBI PORTD, PD6
	CBI PORTD, PD7

	SBRS R27, PC6
	CBI PORTB, PB4
	SBRC R27, PC6
	SBI PORTB, PB4

	OUT PORTC, R27
	SBI PORTD, PD5
	
	CBI PORTD, PD4
	CBI PORTD, PD3
	CBI PORTD, PD2
	CBI PORTD, PD6
	CBI PORTD, PD7

	RET

//***************************************************************************
// DECMES DISPLAY
//***************************************************************************
DECMES_DISPLAY:
	CBI PORTD, PD2
	CBI PORTD, PD5
	CBI PORTD, PD3
	CBI PORTD, PD6
	CBI PORTD, PD7

	MOV R27, DECMES
	LDI ZH, HIGH(TABLA << 1)
	LDI ZL, LOW(TABLA << 1)
	ADD ZL, R27
	LPM R27, Z

	CBI PORTD, PD2
	CBI PORTD, PD5
	CBI PORTD, PD3
	CBI PORTD, PD6
	CBI PORTD, PD7

	SBRS R27, PC6
	CBI PORTB, PB4
	SBRC R27, PC6
	SBI PORTB, PB4

	OUT PORTC, R27
	SBI PORTD, PD4
	
	CBI PORTD, PD2
	CBI PORTD, PD5
	CBI PORTD, PD3
	CBI PORTD, PD6
	CBI PORTD, PD7

	RET

//***************************************************************************
// AUNITMIN DISPLAY
//***************************************************************************
AUNITMIN_DISPLAY:
	CBI PORTD, PD4
	CBI PORTD, PD3
	CBI PORTD, PD2
	CBI PORTD, PD6
	CBI PORTD, PD7

	MOV R27, AUNITMIN
	LDI ZH, HIGH(TABLA << 1)
	LDI ZL, LOW(TABLA << 1)
	ADD ZL, R27
	LPM R27, Z

	CBI PORTD, PD4
	CBI PORTD, PD3
	CBI PORTD, PD2
	CBI PORTD, PD6
	CBI PORTD, PD7

	SBRS R27, PC6
	CBI PORTB, PB4
	SBRC R27, PC6
	SBI PORTB, PB4

	OUT PORTC, R27
	SBI PORTD, PD5
	
	CBI PORTD, PD4
	CBI PORTD, PD3
	CBI PORTD, PD2
	CBI PORTD, PD6
	CBI PORTD, PD7

	RET

//***************************************************************************
// ADECMIN DISPLAY
//***************************************************************************
ADECMIN_DISPLAY:
	CBI PORTD, PD5
	CBI PORTD, PD3
	CBI PORTD, PD2
	CBI PORTD, PD6
	CBI PORTD, PD7

	MOV R27, ADECMIN
	LDI ZH, HIGH(TABLA << 1)
	LDI ZL, LOW(TABLA << 1)
	ADD ZL, R27
	LPM R27, Z

	CBI PORTD, PD5
	CBI PORTD, PD3
	CBI PORTD, PD2
	CBI PORTD, PD6
	CBI PORTD, PD7

	SBRS R27, PC6
	CBI PORTB, PB4
	SBRC R27, PC6
	SBI PORTB, PB4

	OUT PORTC, R27
	SBI PORTD, PD4
	
	CBI PORTD, PD5
	CBI PORTD, PD3
	CBI PORTD, PD2
	CBI PORTD, PD6
	CBI PORTD, PD7

	RET

//***************************************************************************
// AUNITHORA DISPLAY
//***************************************************************************
AUNITHORA_DISPLAY:
	CBI PORTD, PD4
	CBI PORTD, PD5
	CBI PORTD, PD2
	CBI PORTD, PD6
	CBI PORTD, PD7

	MOV R27, AUNITHORA
	LDI ZH, HIGH(TABLA << 1)
	LDI ZL, LOW(TABLA << 1)
	ADD ZL, R27
	LPM R27, Z

	CBI PORTD, PD4
	CBI PORTD, PD5
	CBI PORTD, PD2
	CBI PORTD, PD6
	CBI PORTD, PD7

	SBRS R27, PC6
	CBI PORTB, PB4
	SBRC R27, PC6
	SBI PORTB, PB4

	OUT PORTC, R27
	SBI PORTD, PD3
	
	CBI PORTD, PD4
	CBI PORTD, PD5
	CBI PORTD, PD2
	CBI PORTD, PD6
	CBI PORTD, PD7

	RET

//***************************************************************************
// ADECHORA DISPLAY
//***************************************************************************
ADECHORA_DISPLAY:
	CBI PORTD, PD4
	CBI PORTD, PD3
	CBI PORTD, PD5
	CBI PORTD, PD6
	CBI PORTD, PD7

	MOV R27, ADECHORA
	LDI ZH, HIGH(TABLA << 1)
	LDI ZL, LOW(TABLA << 1)
	ADD ZL, R27
	LPM R27, Z

	CBI PORTD, PD4
	CBI PORTD, PD3
	CBI PORTD, PD5
	CBI PORTD, PD6
	CBI PORTD, PD7

	SBRS R27, PC6
	CBI PORTB, PB4
	SBRC R27, PC6
	SBI PORTB, PB4

	OUT PORTC, R27
	SBI PORTD, PD2
	
	CBI PORTD, PD4
	CBI PORTD, PD3
	CBI PORTD, PD5
	CBI PORTD, PD6
	CBI PORTD, PD7

	RET


//***************************************************************************
// INCREMENTAR RELOJ
//***************************************************************************
INC_UNITSEG:
	INC UNITSEG
	RJMP LOOP

INC_DECSEG:
	INC DECSEG
	RJMP LOOP

INC_UNITMIN:
	INC UNITMIN
	RJMP LOOP

INC_DECMIN:
	INC DECMIN
	RJMP LOOP

INC_UNITHORA:
	LDI R28, 2
	CPSE R26, R28
	CALL INC_UNITHORA_2
	LDI R28, 3
	CPSE UNITHORA, R28
	CALL INC_UNITHORA_2
	CLR UNITHORA
	CLR R26
	CALL INC_UNITDIA
	RJMP LOOP

INC_UNITHORA_2:
	INC UNITHORA
	RJMP LOOP

INC_DECHORA:
	INC R26
	RJMP LOOP

//***************************************************************************
// INCREMENTAR FECHA
//***************************************************************************
INC_UNITDIA:
	LDI R28, 0
	CPSE R28, DECMES
	RJMP MES_1X
	RJMP MES_0X

INC_UNITDIA_2:
	INC UNITDIA
	RJMP LOOP

INC_DECDIA:
	INC DECDIA
	RJMP LOOP

INC_UNITMES:
	LDI R28, 1
	CPSE DECMES, R28
	CALL INC_UNITMES_3

	LDI R28, 2
	CPSE UNITMES, R28
	CALL INC_UNITMES_2
	LDI R28, 1
	MOV UNITMES, R28
	CLR DECMES
	RJMP LOOP

INC_UNITMES_3:
	LDI R28, 9
	CPSE UNITMES, R28
	CALL INC_UNITMES_2
	CLR UNITMES
	RJMP INC_DECMES

INC_UNITMES_2:
	INC UNITMES
	RJMP LOOP

INC_DECMES:
	LDI R28, 2
	CPSE UNITMES, R28
	CALL INC_DECMES_2
	CLR DECMES
	RJMP LOOP

INC_DECMES_2:
	INC DECMES
	RJMP LOOP

//***************************************************************************
// MESES PARTE 2
//***************************************************************************
MES_31D_2:
;CONTINUIDAD DE DIAS 
	LDI R28, 9
	CPSE UNITDIA, R28
	CALL INC_UNITDIA_2
	CLR UNITDIA
; LIMITE MES
	LDI R28, 3
	CPSE DECDIA, R28
	CALL INC_DECDIA
	CLR DECDIA			; RESET
	LDI R28, 1
	MOV UNITDIA, R28

	RJMP LOOP
//***************************************************************************
MES_30D_2:
;CONTINUIDAD DE DIAS
	LDI R28, 9
	CPSE UNITDIA, R28
	CALL INC_UNITDIA_2
	CLR UNITDIA
; LIMITE MES
	LDI R28, 3
	CPSE DECDIA, R28
	CALL INC_DECDIA
	CLR DECDIA			; RESET
	LDI R28, 1
	MOV UNITDIA, R28

	RJMP LOOP
//***************************************************************************
MES_28D_2:
;CONTINUIDAD DE DIAS
	LDI R28, 9
	CPSE UNITDIA, R28
	CALL INC_UNITDIA_2
	CLR UNITDIA
; LIMITE MES
	LDI R28, 2
	CPSE DECDIA, R28
	CALL INC_DECDIA
	CLR DECDIA			; RESET
	LDI R28, 1			
	MOV UNITDIA, R28

	RJMP LOOP
//***************************************************************************
// MES 28 DIAS
//***************************************************************************
MES_28D:
	LDI R28, 2			; LIMITE DECENAS
	CPSE DECDIA, R28
	RJMP MES_28D_2

	LDI R28, 8			; LIMITE UNIDADES
	CPSE UNITDIA, R28
	CALL INC_UNITDIA_2
	LDI R28, 1			; RESET
	MOV UNITDIA, R28
	CLR DECDIA

	RJMP INC_UNITMES
//***************************************************************************
// SELECCIONAR MES 0X
//***************************************************************************
MES_0X:
	MOV R28, UNITMES
	CPI R28, 1
	BREQ MES_31D
	CPI R28, 2
	BREQ MES_28D
	CPI R28, 3
	BREQ MES_31D
	CPI R28, 4
	BREQ MES_30D
	CPI R28, 5
	BREQ MES_31D
	CPI R28, 6
	BREQ MES_30D
	CPI R28, 7
	BREQ MES_31D
	CPI R28, 8
	BREQ MES_31D
	CPI R28, 9
	BREQ MES_30D
	RJMP LOOP
//***************************************************************************
// SELECCIONAR MES 1X
//***************************************************************************
MES_1X:
	MOV R28, UNITMES
	CPI R28, 0
	BREQ MES_31D
	CPI R28, 1
	BREQ MES_30D
	CPI R28, 2
	BREQ MES_31D
	RJMP LOOP
//***************************************************************************
// MES 31 DIAS
//***************************************************************************
MES_31D:
	LDI R28, 3			; LIMITE DECENAS
	CPSE DECDIA, R28
	RJMP MES_31D_2

	LDI R28, 1			; LIMITE UNIDADES
	CPSE UNITDIA, R28
	CALL INC_UNITDIA_2
	LDI R28, 1			; RESET
	MOV UNITDIA, R28
	CLR DECDIA

	RJMP INC_UNITMES
//***************************************************************************
// MES 30 DIAS
//***************************************************************************
MES_30D:
	LDI R28, 3			; LIMITE DECENAS
	CPSE DECDIA, R28
	RJMP MES_30D_2

	LDI R28, 0			; LIMITE UNIDADES
	CPSE UNITDIA, R28	
	CALL INC_UNITDIA_2
	LDI R28, 1			; RESET
	MOV UNITDIA, R28
	CLR DECDIA
	RJMP INC_UNITMES

//***************************************************************************
// HORA INTERRUPCIONES
//***************************************************************************

//***************************************************************************
//  MINUTOS INTERRUPCIONES
//***************************************************************************
ISR_INC_UNITMIN:						; INCREMENTAR
	LDI R28, 9
	CPSE UNITMIN, R28
	JMP ISR_INC_UNITMIN_2
	CLR UNITMIN
	JMP ISR_INC_DECMIN
ISR_INC_UNITMIN_2:
	INC UNITMIN
	JMP ISR_POP_PCINT0
ISR_INC_DECMIN:
	LDI R28, 5
	CPSE DECMIN, R28
	JMP ISR_INC_DECMIN_2
	CLR DECMIN
	JMP ISR_POP_PCINT0
ISR_INC_DECMIN_2:
	INC DECMIN
	JMP ISR_POP_PCINT0
ISR_DEC_UNITMIN:						; DECREMENTAR
	LDI R28, 0
	CPSE UNITMIN, R28
	JMP ISR_DEC_UNITMIN_2
	LDI UNITMIN, 9
	LDI R28, 0
	CPSE DECMIN, R28
	JMP ISR_DEC_UNITMIN_3
	LDI DECMIN, 5
	JMP ISR_POP_PCINT0
ISR_DEC_UNITMIN_2:
	DEC UNITMIN
	JMP ISR_POP_PCINT0
ISR_DEC_UNITMIN_3:
	DEC DECMIN
	JMP ISR_POP_PCINT0
//***************************************************************************
//  HORAS INTERRUPCIONES
//***************************************************************************
ISR_INC_UNITHORA:						; INCREMENTAR
	LDI R28, 2
	CPSE R26, R28			
	JMP ISR_INC_UNITHORA_2
	LDI R28, 3
	CPSE UNITHORA, R28
	JMP ISR_INC_UNITHORA_2
	CLR UNITHORA
	CLR R26
	JMP ISR_POP_PCINT0
ISR_INC_UNITHORA_2:
	LDI R28, 9
	CPSE UNITHORA, R28
	JMP ISR_INC_UNITHORA_3
	CLR UNITHORA
	INC R26
	JMP ISR_POP_PCINT0
ISR_INC_UNITHORA_3:
	INC UNITHORA
	JMP ISR_POP_PCINT0
ISR_DEC_UNITHORA:						; DECREMENTAR
	LDI R28, 0
	CPSE R26, R28
	JMP ISR_DEC_UNITHORA_3
	LDI R28, 0
	CPSE UNITHORA, R28
	JMP ISR_DEC_UNITHORA_2
	LDI R26, 2
	LDI UNITHORA, 3
	JMP ISR_POP_PCINT0
ISR_DEC_UNITHORA_2:
	DEC UNITHORA
	JMP ISR_POP_PCINT0
ISR_DEC_UNITHORA_3:
	LDI R28, 0
	CPSE UNITHORA, R28
	JMP ISR_DEC_UNITHORA_2
	LDI UNITHORA, 9
	DEC R26
	JMP ISR_POP_PCINT0

	//***************************************************************************
// ALARMA INTERRUPCIONES
//***************************************************************************

//***************************************************************************
//  MINUTOS INTERRUPCIONES
//***************************************************************************
ISR_INC_AUNITMIN:						; INCREMENTAR
	LDI R28, 9
	CPSE AUNITMIN, R28
	JMP ISR_INC_AUNITMIN_2
	CLR AUNITMIN
	JMP ISR_INC_ADECMIN
ISR_INC_AUNITMIN_2:
	INC AUNITMIN
	JMP ISR_POP_PCINT0
ISR_INC_ADECMIN:
	LDI R28, 5
	CPSE ADECMIN, R28
	JMP ISR_INC_ADECMIN_2
	CLR ADECMIN
	JMP ISR_POP_PCINT0
ISR_INC_ADECMIN_2:
	INC ADECMIN
	JMP ISR_POP_PCINT0
ISR_DEC_AUNITMIN:						; DECREMENTAR
	LDI R28, 0
	CPSE AUNITMIN, R28
	JMP ISR_DEC_AUNITMIN_2
	LDI R28, 9
	MOV AUNITMIN, R28
	LDI R28, 0
	CPSE ADECMIN, R28
	JMP ISR_DEC_AUNITMIN_3
	LDI R28, 5
	MOV ADECMIN, R28
	JMP ISR_POP_PCINT0
ISR_DEC_AUNITMIN_2:
	DEC AUNITMIN
	JMP ISR_POP_PCINT0
ISR_DEC_AUNITMIN_3:
	DEC ADECMIN
	JMP ISR_POP_PCINT0
//***************************************************************************
//  HORAS INTERRUPCIONES
//***************************************************************************
ISR_INC_AUNITHORA:						; INCREMENTAR
	LDI R28, 2
	CPSE ADECHORA, R28			
	JMP ISR_INC_AUNITHORA_2
	LDI R28, 3
	CPSE AUNITHORA, R28
	JMP ISR_INC_AUNITHORA_2
	CLR AUNITHORA
	CLR ADECHORA
	JMP ISR_POP_PCINT0
ISR_INC_AUNITHORA_2:
	LDI R28, 9
	CPSE AUNITHORA, R28
	JMP ISR_INC_AUNITHORA_3
	CLR AUNITHORA
	INC ADECHORA
	JMP ISR_POP_PCINT0
ISR_INC_AUNITHORA_3:
	INC AUNITHORA
	JMP ISR_POP_PCINT0
ISR_DEC_AUNITHORA:						; DECREMENTAR
	LDI R28, 0
	CPSE ADECHORA, R28
	JMP ISR_DEC_AUNITHORA_3
	LDI R28, 0
	CPSE AUNITHORA, R28
	JMP ISR_DEC_AUNITHORA_2
	LDI R28, 2
	MOV ADECHORA, R28
	LDI R28, 3
	MOV AUNITHORA, R28
	JMP ISR_POP_PCINT0
ISR_DEC_AUNITHORA_2:
	DEC AUNITHORA
	JMP ISR_POP_PCINT0
ISR_DEC_AUNITHORA_3:
	LDI R28, 0
	CPSE AUNITHORA, R28
	JMP ISR_DEC_AUNITHORA_2
	LDI R28, 9
	MOV AUNITHORA, R28
	DEC ADECHORA
	JMP ISR_POP_PCINT0

//***************************************************************************
// FECHA INTERRUPCIONES
//***************************************************************************

//***************************************************************************
//  MESES INTERRUPCIONES
//***************************************************************************
ISR_INC_UNITMES:
	LDI R28, 0
	CPSE DECMES, R28
	JMP ISR_INC_UNITMES_3
	LDI R28, 9
	CPSE UNITMES, R28
	JMP ISR_INC_UNITMES_2
	CLR UNITMES
	LDI R28, 1
	MOV DECMES, R28
	JMP ISR_POP_PCINT0
ISR_INC_UNITMES_2:	
	INC UNITMES
	JMP ISR_POP_PCINT0
ISR_INC_UNITMES_3:
	LDI R28, 2
	CPSE UNITMES, R28
	JMP ISR_INC_UNITMES_2
	LDI R28, 1
	MOV UNITMES, R28
	CLR DECMES
	JMP ISR_POP_PCINT0
ISR_DEC_UNITMES:
	LDI R28, 0
	CPSE DECMES, R28
	JMP ISR_DEC_UNITMES_2
	LDI R28, 1
	CPSE UNITMES, R28
	JMP ISR_DEC_UNITMES_3
	LDI R28, 2
	MOV UNITMES, R28
	LDI R28, 1
	MOV DECMES, R28
	JMP ISR_POP_PCINT0
ISR_DEC_UNITMES_2:
	LDI R28, 0
	CPSE UNITMES, R28
	JMP ISR_DEC_UNITMES_3
	LDI R28, 9
	MOV UNITMES, R28
	DEC DECMES
	JMP ISR_POP_PCINT0
ISR_DEC_UNITMES_3:
	DEC UNITMES
	JMP ISR_POP_PCINT0
//***************************************************************************
//  DIAS INTERRUPCIONES INCREMENTAR
//***************************************************************************
ISR_INC_UNITDIA:
	LDI R28, 0
	CPSE R28, DECMES
	JMP ISR_MES_1X
	JMP ISR_MES_0X
ISR_MES_28D:
	LDI R28, 2			; LIMITE DECENAS
	CPSE DECDIA, R28
	JMP ISR_MES_28D_2

	LDI R28, 8			; LIMITE UNIDADES
	CPSE UNITDIA, R28
	JMP ISR_INC_UNITDIA_2
	LDI R28, 1			; RESET
	MOV UNITDIA, R28
	CLR DECDIA

	JMP ISR_POP_PCINT0
//***************************************************************************
// SELECCIONAR MES 0X
//***************************************************************************
ISR_MES_0X:
	MOV R28, UNITMES
	CPI R28, 1
	BREQ ISR_MES_31D
	CPI R28, 2
	BREQ ISR_MES_28D
	CPI R28, 3
	BREQ ISR_MES_31D
	CPI R28, 4
	BREQ ISR_MES_30D
	CPI R28, 5
	BREQ ISR_MES_31D
	CPI R28, 6
	BREQ ISR_MES_30D
	CPI R28, 7
	BREQ ISR_MES_31D
	CPI R28, 8
	BREQ ISR_MES_31D
	CPI R28, 9
	BREQ ISR_MES_30D
	JMP ISR_POP_PCINT0
ISR_MES_1X:
	MOV R28, UNITMES
	CPI R28, 0
	BREQ ISR_MES_31D
	CPI R28, 1
	BREQ ISR_MES_30D
	CPI R28, 2
	BREQ ISR_MES_31D
	JMP ISR_POP_PCINT0
ISR_MES_31D:
	LDI R28, 3			; LIMITE DECENAS
	CPSE DECDIA, R28
	JMP ISR_MES_31D_2

	LDI R28, 1			; LIMITE UNIDADES
	CPSE UNITDIA, R28
	JMP ISR_INC_UNITDIA_2
	LDI R28, 1			; RESET
	MOV UNITDIA, R28
	CLR DECDIA
	JMP ISR_POP_PCINT0
//***************************************************************************
ISR_MES_30D:
	LDI R28, 3			; LIMITE DECENAS
	CPSE DECDIA, R28
	JMP ISR_MES_30D_2

	LDI R28, 0			; LIMITE UNIDADES
	CPSE UNITDIA, R28	
	JMP ISR_INC_UNITDIA_2
	LDI R28, 1			; RESET
	MOV UNITDIA, R28
	CLR DECDIA
	JMP ISR_POP_PCINT0

ISR_MES_31D_2:
;CONTINUIDAD DE DIAS 
	LDI R28, 9
	CPSE UNITDIA, R28
	JMP ISR_INC_UNITDIA_2
	CLR UNITDIA
; LIMITE MES
	LDI R28, 3
	CPSE DECDIA, R28
	JMP ISR_INC_DECDIA
	CLR DECDIA			; RESET
	LDI R28, 1
	MOV UNITDIA, R28

	JMP ISR_POP_PCINT0
ISR_INC_UNITDIA_2:
	INC UNITDIA
	JMP ISR_POP_PCINT0
ISR_INC_DECDIA:
	INC DECDIA
	JMP ISR_POP_PCINT0
//***************************************************************************
ISR_MES_30D_2:
;CONTINUIDAD DE DIAS
	LDI R28, 9
	CPSE UNITDIA, R28
	JMP ISR_INC_UNITDIA_2
	CLR UNITDIA
; LIMITE MES
	LDI R28, 3
	CPSE DECDIA, R28
	JMP ISR_INC_DECDIA
	CLR DECDIA			; RESET
	LDI R28, 1
	MOV UNITDIA, R28
	JMP ISR_POP_PCINT0
//***************************************************************************
ISR_MES_28D_2:
;CONTINUIDAD DE DIAS
	LDI R28, 9
	CPSE UNITDIA, R28
	JMP ISR_INC_UNITDIA_2
	CLR UNITDIA
; LIMITE MES
	LDI R28, 2
	CPSE DECDIA, R28
	JMP ISR_INC_DECDIA
	CLR DECDIA			; RESET
	LDI R28, 1			
	MOV UNITDIA, R28
	JMP ISR_POP_PCINT0

//***************************************************************************
//  DIAS INTERRUPCIONES DECREMENTAR
//***************************************************************************
ISR_DEC_DIA:
	LDI R28, 0
	CPSE R28, DECMES
	JMP ISR_DEC_MES_1X
	JMP ISR_DEC_MES_0X
//***************************************************************************
ISR_DEC_MES_28D:
	LDI R28, 0						; LIMITE DECDIA
	CPSE R28, DECDIA
	JMP ISR_DECREMENTAR_28D_2
	LDI R28, 1						; LIMITE UNITDIA
	CPSE R28, UNITDIA
	JMP ISR_DECREMENTAR_28D
	LDI R28, 8						; RESET
	MOV UNITDIA, R28
	LDI R28, 2
	MOV DECDIA, R28
	JMP ISR_POP_PCINT0
ISR_DECREMENTAR_28D:
	DEC UNITDIA
	JMP ISR_POP_PCINT0
ISR_DECREMENTAR_28D_2:
	LDI R28, 0
	CPSE UNITDIA, R28
	JMP ISR_DECREMENTAR_28D 
	LDI R28, 9
	MOV UNITDIA, R28
	DEC DECDIA
	JMP ISR_POP_PCINT0
//***************************************************************************
// SELECCIONAR MES 0X
//***************************************************************************
ISR_DEC_MES_0X:
	MOV R28, UNITMES
	CPI R28, 1
	BREQ ISR_DEC_MES_31D
	CPI R28, 2
	BREQ ISR_DEC_MES_28D
	CPI R28, 3
	BREQ ISR_DEC_MES_31D
	CPI R28, 4
	BREQ ISR_DEC_MES_30D
	CPI R28, 5
	BREQ ISR_DEC_MES_31D
	CPI R28, 6
	BREQ ISR_DEC_MES_30D
	CPI R28, 7
	BREQ ISR_DEC_MES_31D
	CPI R28, 8
	BREQ ISR_DEC_MES_31D
	CPI R28, 9
	BREQ ISR_DEC_MES_30D
	JMP ISR_POP_PCINT0
ISR_DEC_MES_1X:
	MOV R28, UNITMES
	CPI R28, 0
	BREQ ISR_DEC_MES_31D
	CPI R28, 1
	BREQ ISR_DEC_MES_30D
	CPI R28, 2
	BREQ ISR_DEC_MES_31D
	JMP ISR_POP_PCINT0
//***************************************************************************
ISR_DEC_MES_31D:
	LDI R28, 0						; LIMITE DECDIA
	CPSE R28, DECDIA
	JMP ISR_DECREMENTAR_31D_2
	LDI R28, 1						; LIMITE UNITDIA
	CPSE R28, UNITDIA
	JMP ISR_DECREMENTAR_31D
	LDI R28, 1						; RESET
	MOV UNITDIA, R28
	LDI R28, 3
	MOV DECDIA, R28
	JMP ISR_POP_PCINT0
ISR_DECREMENTAR_31D:
	DEC UNITDIA
	JMP ISR_POP_PCINT0
ISR_DECREMENTAR_31D_2:
	LDI R28, 0
	CPSE UNITDIA, R28
	JMP ISR_DECREMENTAR_31D 
	LDI R28, 9
	MOV UNITDIA, R28
	DEC DECDIA
	JMP ISR_POP_PCINT0
//***************************************************************************
ISR_DEC_MES_30D:
	LDI R28, 0						; LIMITE DECDIA
	CPSE R28, DECDIA
	JMP ISR_DECREMENTAR_30D_2
	LDI R28, 1						; LIMITE UNITDIA
	CPSE R28, UNITDIA
	JMP ISR_DECREMENTAR_30D
	LDI R28, 0						; RESET
	MOV UNITDIA, R28
	LDI R28, 3
	MOV DECDIA, R28
	JMP ISR_POP_PCINT0
ISR_DECREMENTAR_30D:
	DEC UNITDIA
	JMP ISR_POP_PCINT0
ISR_DECREMENTAR_30D_2:
	LDI R28, 0
	CPSE UNITDIA, R28
	JMP ISR_DECREMENTAR_30D 
	LDI R28, 9
	MOV UNITDIA, R28
	DEC DECDIA
	JMP ISR_POP_PCINT0

