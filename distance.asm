
///////// detecteur de distance /////////

reset_ad:
	LDSP	RAMEND				; set up le SP
	OUTI	DDRB,0xff			; configure le portB en output
	rcall	LCD_init			; initialise le LCD
	
	OUTI	ADCSR,(1<<ADEN)+6	; AD Enable, PS=CK/64	
	OUTI	ADMUX, 3			; select channel potentiometre
	rjmp	mesure_dist				; saut a la fonction de mesure
	


mesure_dist:
	sbi	ADCSR,ADSC				; AD start conversion
	WP1	ADCSR,ADSC				; attend si ADIF=0
	in	a0,ADCL					; lis le low byte en premier
	in	a1,ADCH					; lis le high byte ensuite

	rcall LCD_clear             ;efface ce qui est ecrit sur le LCD
	PRINTF	LCD
	.db	CR,CR,"DISTANCE= ",FDEC2,a,"    ",0     ;DISTANCE= a
	WAIT_MS	100				; attend 100 msec

	ret
