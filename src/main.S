.nolist
.include "./inc/tn13adef.h"
.list

A = 16
CURRENT_SLICE = 17
CURRENT_INDEX = 18
CURRENT_LED = 19

.text

reset:
    rjmp start
    reti
    reti
    reti
    reti
    reti
    reti
    reti
    reti
    reti

start:
    ldi A, lo8(RAMEND)
    out SPL, A

    ser A
    out DDRB, A

    SBI PORTB, 1
    cbi PORTB, 1
    cbi PORTB, 0

reset_scan:
    ldi CURRENT_INDEX, 0
    ldi ZL, lo8(pm(state))
    ldi ZH, hi8(pm(state))
    lsl ZL
    rol ZH

next_byte:
    lpm CURRENT_SLICE, Z+
    clr CURRENT_LED

next_led:
    mov A, CURRENT_SLICE
    andi A, 0x01
    breq clear
    cbi PORTB, 2
    rjmp strobe
clear:
    sbi PORTB, 2
strobe:
    sbi PORTB, 0
    cbi PORTB, 0
    lsr CURRENT_SLICE
    inc CURRENT_LED
    cpi CURRENT_LED, 8
    brlo next_led

    sbi PORTB, 1
    cbi PORTB, 1
    inc CURRENT_INDEX

    ldi  r19, 2 ; delay for 250 MS then move to next byte
    ldi  r20, 69
    ldi  r21, 170
L1: dec  r21
    brne L1
    dec  r20
    brne L1
    dec  r19
    brne L1
    nop
    nop

    cpi CURRENT_INDEX, 112
    brsh reset_scan
    rjmp next_byte

state:
.byte 255,127,63,31,15,7,3,1
.byte 255,127,63,31,15,7,3,2
.byte 255,127,63,31,15,7,6,4
.byte 255,127,63,31,15,14,12,8
.byte 255,127,63,31,30,28,24,16
.byte 255,127,63,62,60,56,48,32
.byte 255,127,126,124,120,112,96,64
.byte 255,254,252,248,240,224,192,128
.byte 255,254,252,248,240,224,192,64
.byte 255,254,252,248,240,224,96,32
.byte 255,254,252,248,240,112,48,16
.byte 255,254,252,248,120,56,24,8
.byte 255,254,252,124,60,28,12,4
.byte 255,254,126,62,30,14,6,2
