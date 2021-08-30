        .section .text
        .global draw_base16
draw_base16:
        /* arg/return r0: base address */
        /* arg r1: screen */
        /* arg r2: number */
        mov fp, sp /* original sp */

        /* collect digits */
_next_digit:
        and r3, r2, #0xf
        strb r3, [sp], #1
        lsrs r2, r2, #4
        bne _next_digit

        /* draw glyphs */
        mov r3, fp
_next_glyph:
        ldrb r4, [sp, #-1]!
        orr r4, r1, r4
        strh r4, [r0], #2
        cmp sp, fp
        bne _next_glyph

        mov sp, fp /* restore sp */

        bx lr
