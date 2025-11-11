; PIC16F887 Configuration Bit Settings

; Assembly source line config statements

#include "p16f887.inc"

; CONFIG1
; __config 0x23E1
 __CONFIG _CONFIG1, _FOSC_XT & _WDTE_OFF & _PWRTE_ON & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _IESO_OFF & _FCMEN_OFF & _LVP_OFF
; CONFIG2
; __config 0x3FFF
 __CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF

W_TEMP		EQU 0x70
STATUS_TEMP	EQU 0x71 

;Variables

indice			    EQU	0x20            ; indice 
TMR0_cont		    EQU	0x21	        ; contador timer0 (0 a 5)
adc_flg			    EQU	0x22            ; flag aux bandera adc
adc_val		        EQU	0x23	        ; valor del adc convertido a digital
rx_val			    EQU	0x24	        ; valor que recibe de la PC para enviar 
modo			    EQU	0x25            ; auto/manual	1=auto/0=manual
tmr0_flg		    EQU 0x26	        ; flag: llegó el ?tick? de ~50 ms

ORG		    0x00
GOTO		INICIO
ORG		    0x04
GOTO		ISR
ORG         0x05

INICIO		
    ;Banco 0
    BCF	    	STATUS, RP0
    BCF	    	STATUS, RP1

    ; Limpiamos los contadores y flags
  CLRF		indice
  CLRF		TMR0_cont
  CLRF		adc_flg
  CLRF		adc_val
  CLRF		rx_val
  CLRF		tmr0_flg
  CLRF		modo

  ; Banco 3
    BSF     	STATUS, RP0
    BSF     	STATUS, RP1
  ; Configuración de pines analogicos/digitales
    MOVLW   	b'00000001'      	; AN0 analógico
    MOVWF   	ANSEL
    CLRF    	ANSELH           	; resto digital


  ; Banco 1
  BSF		STATUS, RP0
    BCF		STATUS, RP1

    ; Configuración de puertos
    BSF     	TRISA, 0          ; RA0 entrada (ADC)
    BCF    	TRISC, 2         	; RC2 salida (PWM)
      BSF     	TRISB, 0         	; RB0 entrada (INT)
      BCF     	TRISC, 6         	; TX out
      BSF     	TRISC, 7         	; RX in

      ; TMR0 cada 5ms
      MOVLW 	        b'11101101'
      MOVWF 	        TMR0
      MOVLW 	        b'00000111' 		        ; TMR0 ON, prescaler 1:256
      MOVWF 	        OPTION_REG

      BSF	WPUB, 0

  ; Refs en VDD y VSS, y los LSB en ADRESL
      CLRF		ADCON1

  ; UART 9600 bps 4 MHz
      BSF     	TXSTA, BRGH     	; alta velocidad
      MOVLW   	D'25'             ; SPBRG=25 -> ~9600 bps
      MOVWF   	SPBRG
     BSF     	TXSTA, TXEN      	; TX on
      BCF       TXSTA,SYNC          ;modo asincrono

      MOVLW D'124'                            ; precarga el valor 124 en el registro para f de PWM
      MOVWF PR2

  ; Banco 0
      BCF		STATUS, RP0
      BCF		STATUS, RP1

      ; CLK en FOSC/4, AN0
      MOVLW	B'01000001'
      MOVWF	ADCON0

      ; Activo el RX para recibir datos
    BSF 		RCSTA,SPEN		; habilita serial
      BSF 		RCSTA,CREN		; RX on

      ; INT externa RB0/INT
      BSF     	OPTION_REG, INTEDG      ; flanco ascendente (a gusto)
      BSF     	INTCON, INTE           
      BCF     	INTCON, INTF

      ; Interrupciones
      BSF     	INTCON, T0IE
      BCF     	INTCON, T0IF
      BSF     	PIE1, ADIE
      BSF     	INTCON, PEIE
      BSF     	INTCON, GIE

      ; PWM (modulacion de ancho de pulso) CCP1 en RC2 500 Hz con Fosc=4 MHz formula: TPWM=124·4·0.25µs·16=1,98ms 
      MOVLW           b'00000111'             ; bit 2 TMR2 on/off, bit 1 y 0 prescaler en 16
      MOVWF           T2CON
      MOVLW           b'00001100'             ; CCP1CON: PWM mode
      MOVWF           CCP1CON
      CLRF            CCPR1L                  ; duty inicial = 0
      BCF             CCP1CON, 5              ; DC1B1=0 por tener solo 8 bits de resolucion
      BCF             CCP1CON, 4              ; DC1B0=0 por tener solo 8 bits de resolucion

MAIN
      ; Cada 5 ms disparar conversión
      MOVF            tmr0_flg, W
      BTFSC           STATUS, Z
      GOTO            actualizar_ADC
      CLRF            tmr0_flg
      BSF             ADCON0, GO          ; inicia conversión

      actualizar_ADC
        ; Si terminó conversión actualizar PWM (AUTO)
        MOVF           adc_flg, W
        BTFSC          STATUS, Z
        GOTO           MAIN
        CLRF           adc_flg

        ; Si modo = 1 (automático) usar ADC
        MOVF        modo, W
        BTFSC       STATUS, Z        ; modo = 0 ? manual
        GOTO        usar_manual

        ; MODO AUTOMÁTICO
        COMF        adc_val, W
        MOVWF       CCPR1L
        BCF         CCP1CON, 5
        BCF         CCP1CON, 4
        GOTO        MAIN

        usar_manual
            MOVF        rx_val, W
	    ANDLW	0xFF
            MOVWF       CCPR1L
            BCF            CCP1CON, 5
            BCF            CCP1CON, 4
            CALL           DELAY_100MS
            GOTO           MAIN

ISR         
      ; Guarda contexto
      MOVWF           W_TEMP	
      SWAPF           STATUS, W	
      MOVWF           STATUS_TEMP	

      ; TMR0 cada 5 ms 
      BTFSS           INTCON, T0IF
      GOTO            Check_INT
      BCF             INTCON, T0IF

      ; Recargar TMR0 (mismo preload que en INICIO)
      MOVLW           b'11101101'                       
      MOVWF           TMR0
      INCF            tmr0_flg, F                     ; flag de 5 ms

      ; INT externa RB0 modo
      Check_INT
            BTFSS       INTCON, INTF                 
            GOTO        Check_ADC
            BCF         INTCON, INTF
            MOVF        modo, W                         ;copia el modo en W 
            XORLW       0x01                            ;cambia el modo
            MOVWF       modo                            ;carga el nuevo valor de modo

      ; ADC fin de conversión lee SOLO ADRESH (8 bits)
      Check_ADC
            BTFSS       PIR1, ADIF
            GOTO        Check_RX
            BCF         PIR1, ADIF

            MOVF        ADRESH, W
            MOVWF       adc_val          ; 0..255
            INCF        adc_flg, F       ; ?dato nuevo? listo

      ; Interrupción de recepción RX
      Check_RX
            BTFSS       PIR1, RCIF              ; ¿Llegó algo por UART?
            GOTO        salir_ISR

            MOVF        RCREG, W                ; leer dato recibido
            MOVWF       rx_val                  ; guardar
            BCF        PIR1,RCIF                ; limpiar flags si querés (no siempre necesario)

      ; Recupera contexto
      salir_ISR
            SWAPF	STATUS_TEMP, W
            MOVWF	STATUS
            SWAPF	W_TEMP, F
            SWAPF	W_TEMP, W
            RETFIE
  ;
  ; DELAY_100MS: espera ~100 ms (20 × 5 ms)
  ; Usa: TMR0_cont (contador), tmr0_flg (tick 5 ms)
  ; Clobbers: W, STATUS
  ; Requisito: la ISR de TMR0 debe hacer INCF tmr0_flg, F
  ;
  DELAY_100MS
      CLRF    TMR0_cont          ; arranca contador en 0
  D100_WAIT_TICK
      MOVF    tmr0_flg, W
      BTFSC   STATUS, Z
      GOTO    D100_WAIT_TICK     ; espera un tick de 5 ms
      CLRF    tmr0_flg           ; consume el tick
      INCF    TMR0_cont, F       ; +1 tick (5 ms)

      MOVF    TMR0_cont, W
      XORLW   D'20'              ; ¿llegó a 20 ticks?
      BTFSS   STATUS, Z
      GOTO    D100_WAIT_TICK

      CLRF    TMR0_cont
      RETURN

  

END