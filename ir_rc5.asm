/*
 * ir_rc5.asm
 */ 

;livre page 302


reset_IR:
	LDSP		RAMEND 			; load stack pointer SP
	rcall		LCD_init		; initialize LCD
	rjmp		read_IR			; jump to main


read_IR:	CLR2	b1,b0			; clear 2-byte register
	ldi			b2,14			; load bit-counter
	WP1	PINE,IR					; Wait if Pin=1	
	WAIT_US		(T50/4)			; wait a quarter period
	
loop:	P2C		PINE,IR			; move Pin to Carry (P2C)
	ROL2		b1,b0			; roll carry into 2-byte reg
	WAIT_US		(T50-4)			; wait bit period (- compensation)	
	DJNZ		b2,loop			; Decrement and Jump if Not Zero
	
	com		b0					; complement b0
	andi	b0, 0xEF			; ignorer le toggle bit
	WAIT_MS 1000

	ret