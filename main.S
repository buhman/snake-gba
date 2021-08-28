#include "base.h"
#include "regs.h"

        .section .text
        .global main
main:
        mov r0, #IO_REG

        mov r1, #0x0
        orr r1, r1, #DISPCNT__BG2
        orr r1, r1, #DISPCNT__BG_MODE_3
        str r1, [r0, #DISPCNT]

        mov r0, #VRAM
        add r1, r0, #0x12c00
        mov r2, #0x1f
_fill_display:
        strh r2, [r0], #2
        cmp r0, r1
        bne _fill_display

_stop:
        b _stop
