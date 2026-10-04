/*
 * temperature.asm
 */ 


; === initialisation (reset) ===
temp_reset:		
	LDSP	RAMEND			; load le SP
	rcall	wire1_init		; initialize l'interface 1-wire(R)
	rcall	lcd_init		; initialise LCD
	rjmp	mesure_temp




; === main pour mesure de la temperature ===
mesure_temp:
	rcall	wire1_reset			; send a reset pulse
	CA	wire1_write, skipROM	; skip ROM identification
	CA	wire1_write, convertT	; initiate temp conversion
	;WAIT_MS	750					; wait 750 msec on aurait pu contourner 85 deg au debut avec le WAIT mais irrespect du temps reel.


	rcall LCD_clear
	rcall	lcd_home			; place le curseur en position initiale
	rcall	wire1_reset			; send a reset pulse
	CA	wire1_write, skipROM
	CA	wire1_write, readScratchpad	
	rcall	wire1_read			; Lis la temp LSB
	mov	c0,a0
	rcall	wire1_read			; Lis la temp MSB
	mov	a1,a0
	mov	a0,c0
	PRINTF	LCD
	.db	"temperature",FFRAC2+FSIGN,a,4,$42,"C ",CR,0		; imprime le resultat sur l'ecran LCD
   //new code:
    mov r16, c0       ; LSB dans r16
    mov r17, a1       ; MSB dans r17

    ldi r18, low(416) ; code pour le 26
    ldi r19, high(416); code pour le 26

    cp r16, r18       ; compare LSB
    cpc r17, r19      ; compare MSB avec retenue

    brlo temp_lower
    //allume rouge
    rcall affichage_rouge
    rcall ws2812b_freeze_frame
    ret
    temp_lower:
        //allume bleu
        rcall affichage_bleu_2
        rcall ws2812b_freeze_frame
        ret