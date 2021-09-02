#include "base.h"

        .global screen$text_fill
screen$text_fill:
        /* arg r0: screen base block address */
        /* arg r1: tile index */

        /* 6.1.6: 0x40 bytes per row */
        add r9, r0, #SCREEN_BASE_BLOCK_LENGTH
        orr r1, r1, r1, LSL #16
        .irp i, 2, 3, 4, 5, 6, 7, 8
        mov r\i, r1
        .endr

_loop:
        stmia r0!, {r1 - r8}
        cmp r0, r9
        bne _loop

        bx lr
