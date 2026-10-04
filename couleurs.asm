/*
 * couleurs.asm
 */ 


 .macro WS2812B_WRITE0
	clr u
	sbi PORTD, 1	;
	out PORTD, u	;
	nop
	nop
.endm

.macro WS2812B_WRITE1
	sbi PORTD, 1	;
	nop
	nop
	cbi PORTD, 1	;
.endm

ws2812b_init:
	OUTI DDRD, 0x02 ; Set PD1 as output ;
	ret

ws2812b_write3:
	ldi w, 8
ws_loop_a0:
	sbrc a0, 7
	rjmp ws_bit1_a0
	WS2812B_WRITE0
	rjmp ws_next_a0
ws_bit1_a0:
	WS2812B_WRITE1
ws_next_a0:
	lsl a0
	dec w
	brne ws_loop_a0

	ldi w, 8
ws_loop_a1:
	sbrc a1, 7
	rjmp ws_bit1_a1
	WS2812B_WRITE0
	rjmp ws_next_a1
ws_bit1_a1:
	WS2812B_WRITE1
ws_next_a1:
	lsl a1
	dec w
	brne ws_loop_a1

	ldi w, 8
ws_loop_a2:
	sbrc a2, 7
	rjmp ws_bit1_a2
	WS2812B_WRITE0
	rjmp ws_next_a2
ws_bit1_a2:
	WS2812B_WRITE1
ws_next_a2:
	lsl a2
	dec w
	brne ws_loop_a2
	ret

ws2812b_reset:
	cbi PORTD, 1	;
	ret

	ws2812b_freeze_frame:
    ldi zl, low(0x0400)
    ldi zh, high(0x0400)
    _LDI r0, 64               ; nombre de LEDs (64 x 3 octets RGB)

freeze_loop:
    ld a0, z+                 ; R
    ld a1, z+                 ; G
    ld a2, z+                 ; B
    cli
    rcall ws2812b_write3      ; envoyer (a0,a1,a2)
    sei
    dec r0
    brne freeze_loop

    rcall ws2812b_reset
    ret

vert:						;pour une LED verte
	ldi a0, 0x05
	st z+, a0
	clr a0
	st z+, a0
	st z+, a0
	ret

eteint:						;pour une LED eteinte
	clr a0
	st z+, a0
	st z+, a0
	st z+, a0
	ret

orange:						;pour une LED orange
	ldi a0,0x08
	st z+,a0
	ldi a0,0x3f
	st z+,a0
	ldi a0,0x00
	st z+,a0
	ret

rouge:						;pour une LED rouge
	clr a0
	st z+,a0
	ldi a0,0x3f
	st z+,a0
	ldi a0,0x00
	st z+,a0
	ret

bleu:						;pour une LED bleu
	clr a0
	st z+,a0
	st z+,a0
	ldi a0,0x0f
	st z+,a0
	ret

; Code pour afficher sur la LED:

affichage_rouge:
	ldi zl, low(0x0400)
	ldi zh, high(0x0400)
	ldi b2, 0x40
	rcall rouge
	dec b2
	cpi b2,0x00
	brne PC-3
	ret


affichage_bleu_2:
	ldi zl, low(0x0400)
	ldi zh, high(0x0400)
	ldi b2, 0x40
	rcall bleu
	dec b2
	cpi b2,0x00
	brne PC-3
	ret


petit_triangle:
	ldi zl, low(0x0400)
	ldi zh, high(0x0400)
	
	rcall eteint		;ligne 1
	rcall eteint
	rcall eteint
	rcall eteint
	rcall eteint
	rcall eteint
	rcall eteint
	rcall eteint

	rcall eteint		;ligne 2
	rcall eteint
	rcall eteint
	rcall eteint
	rcall eteint
	rcall eteint
	rcall eteint
	rcall eteint

	rcall eteint		;ligne 3
	rcall eteint
	rcall eteint
	rcall orange
	rcall eteint
	rcall eteint
	rcall eteint
	rcall eteint
	
	rcall eteint		;ligne 4
	rcall eteint
	rcall orange
	rcall eteint
	rcall orange
	rcall eteint
	rcall eteint
	rcall eteint
	
	rcall eteint		;ligne 5
	rcall orange
	rcall orange
	rcall orange
	rcall orange
	rcall orange
	rcall eteint
	rcall eteint
	
	rcall eteint		;ligne 6
	rcall eteint
	rcall eteint
	rcall eteint
	rcall eteint
	rcall eteint
	rcall eteint
	rcall eteint
	
	rcall eteint		;ligne 7
	rcall eteint
	rcall eteint
	rcall eteint
	rcall eteint
	rcall eteint
	rcall eteint
	rcall eteint
	
	rcall eteint		;ligne 8
	rcall eteint
	rcall eteint
	rcall eteint
	rcall eteint
	rcall eteint
	rcall eteint
	rcall eteint
	
	ret



grand_triangle:
	ldi zl, low(0x0400)
	ldi zh, high(0x0400)
	
	rcall eteint			;ligne 1
	rcall eteint
	rcall eteint
	rcall orange
	rcall orange
	rcall eteint
	rcall eteint
	rcall eteint

	rcall eteint			;ligne 2
	rcall eteint
	rcall eteint
	rcall orange
	rcall orange
	rcall eteint
	rcall eteint
	rcall eteint

	rcall eteint			;ligne 3
	rcall eteint
	rcall orange
	rcall orange
	rcall orange
	rcall orange
	rcall eteint
	rcall eteint
	
	rcall eteint			;ligne 4
	rcall eteint
	rcall orange
	rcall orange
	rcall orange
	rcall orange
	rcall eteint
	rcall eteint
	
	rcall eteint			;ligne 5
	rcall orange
	rcall orange
	rcall orange
	rcall orange
	rcall orange
	rcall orange
	rcall eteint
	
	rcall eteint			;ligne 6
	rcall orange
	rcall orange
	rcall orange
	rcall orange
	rcall orange
	rcall orange
	rcall eteint
	
	rcall orange			;ligne 7
	rcall orange
	rcall orange
	rcall orange
	rcall orange
	rcall orange
	rcall orange
	rcall orange
	
	rcall orange			;ligne 8
	rcall orange
	rcall orange
	rcall orange
	rcall orange
	rcall orange
	rcall orange
	rcall orange
	
	ret

affichage_orange:
	ldi zl, low(0x0400)
	ldi zh, high(0x0400)
	ldi b2, 0x40
	rcall orange
	dec b2
	cpi b2,0x00
	brne PC-3
	ret

affichage_vert:
	ldi zl, low(0x0400)
	ldi zh, high(0x0400)
	ldi b2, 0x40
	rcall vert
	dec b2
	cpi b2,0x00
	brne PC-3
	ret

affichage_eteint:
	ldi zl, low(0x0400)
	ldi zh, high(0x0400)
	ldi b2, 0x40
	rcall eteint
	dec b2
	cpi b2,0x00
	brne PC-3
	ret

