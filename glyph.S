        .section .text
        .global _start
_start:
        .global copy_glyphs
copy_glyphs:
        /* arg r0: base destination address */

        /*

        -> 0x3e 0011_1110 ; 01111100

            l  h
           [w, b, = [0x10,
            b, b,    0x11,
            b, b,    0x11,
            w, w]    0x0 ]

        <- 0x00111110   0000 0000  0001 0001  0001 0001  0001 0000
        */

        ldr r1, =_first_glyph
        ldr r11, =_last_glyph

_next_row:
        /* 1 dot per bit */
        ldrb r2, [r1], #1 /* in byte */
        mov r10, #1 /* const 1 */
        mov r3, #0 /* in shift */
        /*mov r4, #0 /* in (bool) */
        mov r5, #0 /* out shift */
        mov r6, #0 /* out (int) row in screen format */
_next_bit:
        and r4, r10, r2, LSR r3
        add r4, r4, #1
        add r3, r3, #1

        orr r6, r6, r4, LSL r5
        add r5, r5, #4

        cmp r3, #8
        bne _next_bit

        /* store row */
        str r6, [r0], #4

        cmp r1, r11
        bne _next_row

        bx lr

        /* 6.1.4 Character Data Format */
        /* 4 bits per px */
        /* 4 bytes per row */

        /* font data */
_first_glyph:
        .include "font.s"
_last_glyph:
