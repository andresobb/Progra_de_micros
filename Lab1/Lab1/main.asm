;
; Lab1.asm
;
; Created: 2/2/2025 10:16:10 PM
; Author : andres
;

// Encabezado
    .INCLUDE "M328PDEF.INC"

    .ORG 0x00
    RJMP START

START:
	// Configuramos registros
	LDI		R16, 0x00	//para que el contador inicie en 0
	LDI		R17, 0x01	//valor para incremento o decremento
	OUT		DDRB, R17	//configuramos PORTB como salida
	OUT		PORTB, R16	//mostrar el contador en PORTB

INCREMENTO:
	//leemos el boton de incremento
	IN		R16, PINB	//leer el estado del boton
	CPI		R16, 0x01	//chequear si el boton esta presionado
	BRNE	DECREMENTO //si el de incremento no esta presionado, chequear el de decremento
	
	CALL ANTIRREBOTE	//aplicamos el antirrebote

	IN		R16, PINB
	CPI		R16, 0x01
	BRNE	DECREMENTO	//verificar si sigue presionado

	IN		R16, PORTB	//leer el valor actual del contador
	ADD		R16, R17	//incrementar el contador si necesario
	CPI		R16, 0x10	//verificar si es mayor que 0x0F
	BRNE	NO_RESET_INC
	LDI		R16, 0x00	//reiniciar

NO_RESET_INC:
	OUT PORTB, R16	//mostrar el contador

WAIT_RELEASE_INC:
    IN      R16, PINB
    CPI     R16, 0x01
    BREQ    WAIT_RELEASE_INC  ; Esperar a que el botón se suelte
	
DECREMENTO:
	IN		R16, PINC	//leer el estado del boton de decremento
	CPI		R16, 0x01	//chequeaar si el boton esta presionado
	BRNE	INCREMENTO //si el de incremento no esta presionado, chequear el de incremento

	CALL ANTIRREBOTE

	IN		R16, PINC
	CPI		R16, 0x01
	BRNE	INCREMENTO	//verificar si sigue presionado

	IN		R16, PORTB	//leer el valor actual
	SUB		R16, R17	//decrementar el contador
	CPI		R16, 0X00	
	BRNE	NO_RESET_DEC
	LDI		R16, 0x0F

NO_RESET_DEC:
	OUT		PORTB, R16	//mostrar el contador

WAIT_RELEASE_DEC:
    IN      R16, PINC
    CPI     R16, 0x01
    BREQ    WAIT_RELEASE_DEC  ; Esperar a que el botón se suelte



	RJMP INCREMENTO


ANTIRREBOTE:
	LDI		R18, 0xFF	//ponemos un valor para un delay
DELAY:
	DEC R18
	BRNE DELAY
	RET

