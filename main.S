#include "base.h"
#include "regs.h"
#include "color.h"
#include "screen.h"

        .section .text
        .global main
main:
        /* stack */
        mov sp, #IWRAM

        b minmin
        .global minmin_ret
minmin_ret:

        /* palettes */
        mov r0, #PRAM_BG
        add r0, r0, #32 /* palette 1 */
        add r0, r0, #2
        mov r1, #BLACK
        strh r1, [r0], #2
        ldr r1, =#WHITE
        strh r1, [r0], #2
        mov r1, #0x8 /* red */
        strh r1, [r0], #2

        /* tiles */
        mov r0, #VRAM
        add r0, r0, #0x8000 /* tile base block 2 */
        bl copy_glyphs

        /* fill screen */
        mov r0, #VRAM
        add r0, r0, #0xf000 /* screen base block 30 */
        add r1, r0, #0x800
        mov r2, #0x100
        orr r2, r2, #SCREEN_TEXT_PALETTE(1)
_fill_loop:
        strh r2, [r0], #2
        cmp r0, r1
        bne _fill_loop

        /* aoc2020 part1 */
        add sp, sp, #16384
        bl day1_part1
        mov r10, r0
        add sp, sp, #-16384

        /* screen */
        mov r0, #VRAM
        add r0, r0, #0xf000 /* screen base block 30 */
        mov r1, #SCREEN_TEXT_PALETTE(1)
        ldr r2, =#0xda1
        bl draw_base16
        add r0, r0, #2
        mov r2, r10
        bl draw_base16

        /* set text mode */
        mov r0, #IO_REG
        mov r1, #0x0
        orr r1, r1, #BG_CNT__COLOR_16_16
        orr r1, r1, #BG_CNT__SCREEN_SIZE(0)
        orr r1, r1, #BG_CNT__CHAR_BASE_BLOCK(2)
        orr r1, r1, #BG_CNT__SCREEN_BASE_BLOCK(30)
        orr r1, r1, #BG_CNT__PRIORITY(0)
        strh r1, [r0, #BG1CNT]

        /* */
        mov r0, #IO_REG
        mov r1, #0x0
        orr r1, r1, #DISPCNT__BG0
        orr r1, r1, #DISPCNT__BG1
        orr r1, r1, #DISPCNT__BG_MODE_0
        strh r1, [r0, #DISPCNT]


        .global int
int:
        mov r9, #0 /* dx[1] */
        mov r10, #0 /* dx[0] */
        mov r11, #0 /* dy[0] */
        mov r2, #1

        /* enable int */
        ldr r0, =#0x3007ffc
        ldr r1, =_input_isr
        str r1, [r0]

        mov r0, #IO_REG
        mov r1, #DISPSTAT__V_BLANK_INT_ENABLE
        str r1, [r0, #DISPSTAT]


        mov r1, #IE__RENDER_BLANK_V
        /*orr r1, r1, #IE__KEY*/
        str r1, [r0, #IE]

        /*
        mov r1, #KEYCNT__INT_ENABLE
        str r1, [r0, #KEYCNT]
        */

        mov r1, #IME__INT_MASTER_ENABLE
        str r1, [r0, #IME]

_stop:
        b _stop


        /* input ISR */

_input_isr:
        mov r0, #IO_REG
        add r5, r0, #KEY_INPUT
        ldr r1, [r5]
        ands r3, r1, r2, LSL #KEY_INPUT__RIGHT
        addeq r10, r10, #1
        ands r3, r1, r2, LSL #KEY_INPUT__LEFT
        addeq r10, r10, #-1
        ands r3, r1, r2, LSL #KEY_INPUT__UP
        addeq r11, r11, #-1
        ands r3, r1, r2, LSL #KEY_INPUT__DOWN
        addeq r11, r11, #1
        ands r3, r1, r2, LSL #KEY_INPUT__L
        addeq r9, r9, #-1
        ands r3, r1, r2, LSL #KEY_INPUT__R
        addeq r9, r9, #1

        asr r1, r10, #8
        strh r1, [r0, #BG1HOFS]

        asr r2, r11, #8
        strh r2, [r0, #BG1VOFS]

        asr r2, r9, #8
        strh r2, [r0, #BG0VOFS]

        bx lr
