.nolist
.include "./inc/tn13adef.h"
.list

.text

; registers
.equ ZERO,       2  ; zero for the hi byte in our load
.equ GEN,        16 ; general purpose
.equ ROW_LEN,    17 ; ROW length for a slice
.equ ROW_OFF,    19 ; the current row given as an offset from start address
.equ COL_NUM,    20 ; which column I'm on in the slice
.equ BIT_PAT,    21 ; the actual value of the slice for a row
.equ BIT_POS,    22 ; the current bit clocked out
.equ SLICE_TIME, 23

; shift register pins
.equ CLK, 0
.equ LAT, 1
.equ DAT, 2

; constants
.equ SLICES_PER_ROW,  8
.equ ROW_END,         56
.equ BITS_PER_SLICE,  8

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
    ldi GEN, lo8(RAMEND)
    out SPL, GEN

    sbi DDRB, PORTB0
    sbi DDRB, PORTB1
    sbi DDRB, PORTB2

    SBI PORTB, DAT
    cbi PORTB, CLK
    cbi PORTB, LAT

    ldi ROW_LEN, SLICES_PER_ROW
    lsr ROW_LEN
    clr ZERO

reset_scan:
    clr ROW_OFF

; delay between shifts of the head LED in the chase
; Don't know the exact timing at the moment, would need add up the cylces
scan:
    ldi  r24, 50
L1:
    rcall do_time_slices
    dec  r24
    brne L1
    add ROW_OFF, ROW_LEN
    cpi ROW_OFF, ROW_END
    brlo scan
    rjmp reset_scan

do_time_slices:
    ldi SLICE_TIME, 1
    clr COL_NUM
    ldi ZL, lo8(pm(bcm_index))
    ldi ZH, hi8(pm(bcm_index))
    add ZL, ROW_OFF
    adc ZH, ZERO
    lsl ZL
    rol ZH
next_byte:
    lpm BIT_PAT, Z+
    clr BIT_POS
    rcall shift_bits_out
    inc COL_NUM
    cpi COL_NUM, SLICES_PER_ROW
    brsh slice_return
slice_delay: ; bcm delay
    dec SLICE_TIME
    brne slice_delay
    lsl SLICE_TIME
    inc SLICE_TIME
    rjmp next_byte
slice_return:
    ret

; Active low display, so "on" is 0 and "off" is 1
shift_bits_out:
next_bit:
    mov GEN, BIT_PAT
    andi GEN, 0x01 ; only care about LSB, each bit is shift to LSB
    breq off
    cbi PORTB, DAT
    rjmp clock
off:
    sbi PORTB, DAT
clock:
    sbi PORTB, CLK
    cbi PORTB, CLK
shift:
    lsr BIT_PAT
    inc BIT_POS
    cpi BIT_POS, BITS_PER_SLICE
    brlo next_bit
latch:
    sbi PORTB, LAT
    cbi PORTB, LAT
    ret

delay:
    ret

; Bit Code Modulation/Bit Angle Modulation
; LED case completely laid on in program storage
; oranized in 14 rows of 8 bytes. 14 rows are the
; positions of the leds in the chase going forward
; and coming back.
;
; Each row represent the time_slice for those leds
; at that point in the chase.
bcm_index:
.byte 255,119,55,31,15,7,3,1
.byte 255,119,55,31,15,7,3,2
.byte 255,119,55,31,15,7,6,4
.byte 255,126,62,31,15,14,12,8
.byte 255,125,61,31,30,28,24,16
.byte 255,123,59,62,60,56,48,32
.byte 255,119,118,124,120,112,96,64
.byte 255,238,236,248,240,224,192,128
.byte 255,238,236,248,240,224,192,128
.byte 255,238,236,248,240,224,192,64
.byte 255,238,236,248,240,224,96,32
.byte 255,126,124,248,240,112,48,16
.byte 255,190,188,248,120,56,24,8
.byte 255,222,220,124,60,28,12,4
.byte 255,238,110,62,30,14,6,2
