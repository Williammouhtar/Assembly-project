/*
 * menu_main.asm
 *
 */ 

.include "macros.asm"        ; macro definitions
.include "definitions.asm"   ; register/constant definitions


.org 0    ; Adresse du reset + interruptions du bouton 0
	jmp reset
	jmp ext_int0


; !! ////////////// RESET SOUS-ROUTINE POUR MAIN ///////////////// !!
reset: 
	LDSP		RAMEND 			; load le SP
	OUTI	DDRB,0xff			; configure le portB en output
	OUTI	DDRD,0x00			; configure portD to input (bouton poussoir 0)
	
	 ;Pour le detecteur de distance (distance.asm)
	OUTI	ADCSR,(1<<ADEN)+6	; AD Enable, PS=CK/64	
	OUTI	ADMUX, 3			; select channel POT (potentiometer)

	; Pour les interruptions
	OUTI	EIMSK,0b00000001 	; enable INT0..INT3
	OUTEI EICRA, 0b00000010  
	sei							

	
	rjmp main


; !! ////////////// INTERRUPTION SOUS-ROUTINE POUR BOUTON DU REMOTE ///////////////// !!
ext_int0:		; routine d'interruption lorsque le bouton de la telecommande est presse
		
		rcall print_SOS	; print SOS sur LCD
		rcall petit_triangle
		rcall ws2812b_freeze_frame
		WAIT_MS 100
		rcall grand_triangle
		rcall ws2812b_freeze_frame  ;petite animation
		reti


; !! ////////////// INCLUDE LES LIBRAIRIES ///////////////// !!
.include "lcd.asm"			 ; lcd sous-routines
.include "printf.asm"	     ; printf sous-routines
.include "ir_rc5.asm"	     ; Infra Rouge decodeur sous-routines
.include "distance.asm"		 ; detecteur de distance sous-routines
.include "wire1.asm"		 ; Dallas 1-wire(R) routines
.include "temperature.asm"	 ; module temperature
.include "couleurs.asm"		 ; sous routines LED ws2812b

; !! ////////////// DEFINITIONS ///////////////// !!
.equ	distance_de_transition = 200		; distance de transition vert/rouge
.equ	T50 = 1778			; bit period T50= 1778 usec




; !! ////////////// MAIN ///////////////// !!

// sous-routine read IR signal principale pour le controle du projet
lecture_signal_IR:
	; recois le signal IR et le stock dans b0
	CLR2	b1,b0			; clear les 2 registres
	ldi			b2,14		; load bit-counter
	WP1	PINE,IR				; Wait si Pin=1
	WAIT_US		(T50/4)		; attend un quart de period

	loop_code:	P2C		PINE,IR		; move Pin to Carry (P2C)
		ROL2		b1,b0
		WAIT_US		(T50-4)			; compensation
		DJNZ		b2,loop_code
		com		b0					; complement de b0
	WAIT_US	1000

	ret

// main code du projet
main:
	
	; executions a faire une seule fois
	rcall   LCD_init        ; Initialise le LCD
	rcall	LCD_clear		; clear LCD
	rcall	wire1_init 		; initialise l'interface 1-wire(R)
	rcall   ws2812b_init
	
	WAIT_MS 200
	PRINTF	LCD
	.db	"BIENVENUE"			; print BIENVENUE sur le LCD

	; lis le signal IR en loop et saute a la fonction voulue
	main_loop:
		rcall lecture_signal_IR	; lis le signal IR de la telecommande
		WAIT_MS 2     ; delai approximatif equivalent a "cmd=" 


		; compare le signal recu et saute au menu voulu
		
		cpi b0, 0x20	; Bouton 1
		breq temperature
		cpi b0, 0x33            ;plusieurs code pour la meme fonction a cause de l'irregularite de la telecommande
		breq temperature
		cpi b0, 0x31
		breq temperature
		cpi b0, 0x3f	; Bouton 'arriere'
		breq distance
		cpi b0,0x3b
		breq distance       ;plusieurs code pour la meme fonction a cause de l'irregularite de la telecommande
		cpi b0,0x2f
		breq distance
		cpi b0,0x2b
		breq distance

		rjmp main_loop
			
		
	temperature:
		rcall mesure_temp	; lis et ecris la temperature
		rjmp main_loop
		
	distance:
		rcall mesure_dist		; lis et ecris la distance
		;compare la valeur de la distance avec la distance de transition
		cpi a0, low(distance_de_transition)
		ldi r16, high(distance_de_transition)
		cpc a1, r16
		brsh distance_limite
		rcall affichage_vert
		rcall ws2812b_freeze_frame	
		; si la limite n'est pas atteinte --> vert
		rjmp main_loop

		; si la limite est atteinte --> rouge
		distance_limite:
			rcall affichage_rouge
            rcall ws2812b_freeze_frame
			rcall LCD_lf
			PRINTF	LCD
            .db	"    STOP !",0      ;message si proche
			rjmp main_loop



; !! ////////////// SOUS-ROUTINES ///////////////// !!

; Sous-routine message SOS 
	print_SOS:
		rcall	LCD_clear
		PRINTF	LCD
		.db	"      SOS"
	ret
; ////////////////////////
