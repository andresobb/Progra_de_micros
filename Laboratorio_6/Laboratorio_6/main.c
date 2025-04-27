/*
 * Labortario_6.c
 *
 * Created: 4/20/2025
 * Author : andres barrientos
 */ 

#define F_CPU 16000000UL  // Frecuencia del CPU (16MHz para Arduino Nano)

#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>

#define BAUD 9600         // Velocidad de baudios
#define UBRR_VALUE ((F_CPU/16/BAUD)-1)  // Valor para el registro UBRR
volatile unsigned char caracter_recibido = 0;
volatile uint8_t dato_recibido = 0;

// Inicializar USART
void USART_init(void) {
	// Configurar velocidad de baudios
	UBRR0 = UBRR_VALUE;
	
	// Habilitar transmisor y receptor
	UCSR0B = (1 << RXEN0) | (1 << TXEN0) | (1 << RXCIE0);
	
	// Configurar formato: 8 bits de datos, 1 bit de parada, sin paridad
	UCSR0C = (1 << UCSZ01) | (1 << UCSZ00);
	
	sei();
}

// Enviar un carácter
void USART_transmit(unsigned char data) {
	// Esperar a que el buffer de transmisión esté vacío
	while (!(UCSR0A & (1 << UDRE0)));
	
	// Colocar el dato en el buffer, envía el dato
	UDR0 = data;
}

void USART_string(char* texto){
	uint8_t i = 0;
	
	//enviar los caracteres 
	while (texto[i] != '\0'){
		USART_transmit(texto[i]);
		i++;
	}
}

//rutina interrupcion dato recibido
ISR(USART_RX_vect){
	caracter_recibido = UDR0;
	dato_recibido = 1;
}

//inicializamos el ADC
void ADC_init(){
	//configuramos ADC
	ADMUX = (1 << REFS0);
	//habilitamos adc
	ADCSRA = (1 << ADEN) | (1 << ADPS2) | (1 << ADPS1) | (1 << ADPS0); 
}

//leemos adc
uint16_t ADC_read(uint8_t channel){
	ADMUX = (ADMUX & 0xF0) | (channel & 0x0F);
	ADCSRA |= (1 << ADSC);
	
	while (ADCSRA & (1 << ADSC));
	return ADC >> 2;
}

void mostrar_menu(void){
	USART_string("\r\n----- MENU -----\r\n");
	USART_string("1. Leer Potenciometro\r\n");
	USART_string("2. Enviar Ascii\r\n");
	USART_string("Seleccione una opcion: ");
}

int main(void) {
	// Configurar puertos
	DDRB = 0xFF;   // Puerto B como salida (para los LEDs)
	DDRD |= (1 << DDD2) | (1 << DDD3);  // PD2 y PD3 como salidas
	
	uint8_t ascii_mode = 0; 
	
	// Inicializar USART
	USART_init();
	//Inicializamos ADC
	ADC_init();
	
	//desplegamos el menu en la hiperterminal
	 mostrar_menu();
	
	while(1)
	{
		//ver si se recibio un caracter
		if (dato_recibido){
			dato_recibido = 0;   //reiniciamos la bandera
			
			if (ascii_mode == 0){
				
				//OPCION 1
				if (caracter_recibido == '1'){
					uint8_t valor_potenciometro = ADC_read(0);
				
					//mostramos el valor leido
					USART_string("\r\nValor del potenciometro: ");
				
					//convertimos el valor a digitos y los mostramos
				
					//centenas
					if (valor_potenciometro >= 100){
						USART_transmit('0'  + (valor_potenciometro / 100));
					}
				
					//decenas
					if (valor_potenciometro >= 10){
						USART_transmit('0' + ((valor_potenciometro / 10) % 10));
					}
				
					//unidades
					USART_transmit('0' + (valor_potenciometro % 10));
					
					PORTB = valor_potenciometro & 0x3F;
					
					// 2 bits más significativos en D2 y D3
					if (valor_potenciometro & 0x40) {
						PORTD |= (1 << PD2);
						} else {
						PORTD &= ~(1 << PD2);
					}
					
					if (valor_potenciometro & 0x80) {
						PORTD |= (1 << PD3);
						} else {
						PORTD &= ~(1 << PD3);
					}
				
					mostrar_menu();
			
				}
				else if (caracter_recibido == '2'){
					
					//pedimos que ingrese el caracter que mostrar en los leds
					USART_string("\r\nIntroduzca un caracter: ");
					ascii_mode = 1;					
				}
				else{
					mostrar_menu();
				}
			}
			else if (ascii_mode == 1){
				PORTB = caracter_recibido & 0x3F; //usamos 0011 1111  (los primeros seis bits)
				
				if (caracter_recibido & 0x40){			//bit 6 (0100 0000)
					PORTD |= (1 << PORTD2);
				}
				else{
					PORTD &= ~(1 << PORTD2);
				}
				
				if (caracter_recibido & 0x80){			//bit 6 (1000 0000)
					PORTD |= (1 << PORTD3);
				}
				else{
					PORTD &= ~(1 << PORTD3);
				}
				
				mostrar_menu();
				ascii_mode = 0;
			}
		}
		
	}
}