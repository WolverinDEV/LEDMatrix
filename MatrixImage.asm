;******************************************************************************
;* Definitionen
;******************************************************************************

.include "m8def.inc"		; Definitionen für ATmega8
.def temp 		= r16		
.def delay_0 	= r17		
.def delay_1 	= r18		
.def delay_2 	= r19		
.def x        = r20
.def y        = r21
.def flag 		= r22
.def port 		= r23

.eseg
;.db "XXXX?XXXXX"
;.db "?XXXXXXXXX"
;.db "?X????????"
;.db "??X???????"
;.db "???X??????"
;.db "????X?????"
;.db "?????X????"
;.db "??????X???"
;.db "???????X??"
;.db "????????X?"
;.db "?????????X"
;.db "????????X?"

.cseg

;******************************************************************************
;* 	Programm Start nach Reset
;*
;* 	der Stackpointer wird initialisiert
;* 	RAMEND = $045F = 1119 beim ATmega8
;* 	Register werden gesetzt
;******************************************************************************

;Entry point
RESET:
        ;Reset stack ptr(SP)
	ldi 	r16, high(RAMEND)
	out 	SPH, r16	
	ldi 	r16, low(RAMEND)
	out 	SPL, r16

	ldi temp, 0b00011111
	out DDRB, temp			; Set needed ports as output
	ldi temp, 0b00001111
	out DDRC, temp			; Set needed ports as output
	ldi temp, 0b11110000
	out DDRD, temp			; Set needed ports as output

MAIN_LOOP:
	rcall DISPLAY_PATTERN
rjmp MAIN_LOOP


DISPLAY_PATTERN:
        cbi PORTB, 4 ;Set data to 0
        sbi PORTB, 2 ;Strobe on
        sbi PORTB, 3 ;Clock on
        cbi PORTB, 3 ;Clock off
        sbi PORTB, 4 ;Set data to 1
        
        ldi YH, 0
        ldi YL, 0
        
        	ldi x, 12 ;We have 12 columns
	COLUMN_LOOP:
                 ldi y, 10 ;We have 10 rows
		ROW_LOOP:
                         rcall EEPROM_read
                         adiw YH:YL, 1                   
                         
			cpi r16, 'X'
                        
			brne CONN
                                 ; Set LED
				cpi y, 10
				brne TEST_B0
                                        sbi PORTB, 1
                                        rjmp CONN
				TEST_B0:
				cpi y, 9
				brne TEST_D7
				     sbi PORTB, 0
                                      rjmp CONN
				TEST_D7:
				cpi y, 8
				brne TEST_D6
				     sbi PORTD, 7
                                      rjmp CONN
				TEST_D6:
				cpi y, 7
				brne TEST_D5
				     sbi PORTD, 6
                                      rjmp CONN
				TEST_D5:
				cpi y, 6
				brne TEST_D4
			             sbi PORTD, 5
                                      rjmp CONN
				TEST_D4:
				cpi y, 5
				brne TEST_C3
			             sbi PORTD, 4
                                      rjmp CONN
				TEST_C3:
				cpi y, 4
				brne TEST_C2
			             sbi PORTC, 3
                                      rjmp CONN
				TEST_C2:
				cpi y, 3
				brne TEST_C1
			             sbi PORTC, 2
                                      rjmp CONN
				TEST_C1:
				cpi y, 2
				brne TEST_C0
			             sbi PORTC, 1
                                      rjmp CONN
				TEST_C0: ;Must be the top line or curupt code
			        sbi PORTC, 0
			CONN:
			dec y         ;Sets the zero flag when its zero
			brne ROW_LOOP ;Next row if zero flag isnt set
			

    	         rcall SLEEP_65025 ;Change back to SLEEP_65025
    
                 ;Reset pins
                 in temp, PORTB
                 cbr temp, 0x03
                 out PORTB, temp
                 
                 in temp, PORTD
                 cbr temp, 0xF0
                 out PORTD, temp
                 
                 in temp, PORTC
                 cbr temp, 0x0F
                 out PORTC, temp
                 
		dec x ;Updates zero flag
		breq FRAME_COMPLETED ;Zero flag is set and we can break

                 sbi PORTB, 3 ;Clock on
                 cbi PORTB, 3 ;Clock off
            
                 rjmp COLUMN_LOOP
        FRAME_COMPLETED:
	ret


EEPROM_read:
    sbic    EECR,EEWE                   ; prüfe ob der vorherige Schreibzugriff beendet ist
    rjmp    EEPROM_read                 ; nein, nochmal prüfen

    out     EEARH, YH                   ; Adresse laden
    out     EEARL, YL
    sbi     EECR, EERE                  ; Lesevorgang aktivieren
    in      r16, EEDR                   ; Daten in CPU Register kopieren
    ret


;SLEEP_500:
;	ldi delay_0, 0
;	ldi delay_1, 0
;	ldi delay_2, 2
;       rcall SUB_DELAY
;	ret

SLEEP_65025:
	ldi delay_0, 128
	ldi delay_1, 1
	ldi delay_2, 1
	rcall SUB_DELAY
	ret
SUB_DELAY:													
	dec delay_0                    ; Loop layer 1		
	brne SUB_DELAY			
							
	dec delay_1		      ; Loop layer 2	
	brne SUB_DELAY
			
        dec delay_2		      ; Loop layer 3
	brne SUB_DELAY

	ret						