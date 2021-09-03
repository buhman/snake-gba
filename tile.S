        .global tile$fill_16
tile$fill_16:
        /* arg r0: vram address */
        /* arg r1: palette index */

        /* 6.1.4: 0x20 bytes per tile */
        orr r1, r1, r1, LSL #4
        orr r1, r1, r1, LSL #8
        orr r1, r1, r1, LSL #16
        .irp i, 2, 3, 4, 5, 6, 7, 8
        mov r\i, r1
        .endr
        stmia r0!, {r1 - r8}

        bx lr

        .global tile$basic
tile$basic:
        /* arg r0: vram base address */

        mov r12, lr
        mov r10, #0
        mov r11, #16

_loop:
        mov r1, r10
        bl tile$fill_16 /* tile n: color n */
        add r10, r10, #1
        cmp r11, r10
        bne _loop

        mov lr, r12
        bx lr

tile$bits_16:
        /* arg r0: vram address */
        /* arg r1: palette index */
        /* arg r2: 1bpp tile address */
        ldrb r3, [r2], #1 /* in byte */
        mov r4, #0 /* in shift */
        /*mov r5, #0 /* in */
        mov r6, #0 /* out shift */
        mov r7, #0 /* out (int) row in screen format */
        mov r8, #1 /* const 1 */
_next_bit:
        mov r5, #0
        tst r8, r3, LSR r4
        add r4, r4, #1
        movne r5, r1

        orr r7, r7, r5, LSL r6
        add r6, r6, #4

        cmp r4, #8
        bne _next_bit

        /* store row */
        str r7, [r0], #4

        bx lr

        .global tile$arrows
tile$arrows:
        /* arg r0: vram address */
        /* arg r1: palette index */
        ldr r2, =__arrow_first
        ldr r9, =__arrow_last

        mov fp, lr

_next_arrow:
        bl tile$bits_16
        cmp r2, r9
        bne _next_arrow

        mov lr, fp
        bx lr
