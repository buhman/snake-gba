#include "base.h"
#include "regs.h"
#include "snake.h"

        .section .text
        .global main

main:
        /*
        stack
        */
	ldr sp, =#IWRAM_SP_USR

        /*
        palettes
        */
        mov r0, #PRAM_BG
        bl palette$basic /* pallete 0 */

        /*
        tiles
        */
        mov r0, #VRAM
        bl tile$basic

        mov r1, #1
        bl tile$arrows

        /*
        screens
        */
        ldr r0, =#SCREEN_BASE_BLOCK(31)
        add r0, r0, #VRAM
        mov r1, #15
        bl screen$text_fill

        ldr r0, =#SCREEN_BASE_BLOCK(30)
        add r0, r0, #VRAM
        mov r1, #0
        bl screen$text_fill

        /*
        ldr r0, =#SCREEN_BASE_BLOCK(30)
        add r0, r0, #VRAM
        mov r1, #SCREEN_TEXT_PALETTE(0)
        mov r3, #7
_loop:
        orr r2, r1, r3
        strh r2, [r0], #2
        subs r3, r3, #1
        bne _loop
        */

        /* allocate (GRID_SIZE + head + tail + xorshift + snake_len from sp */
        /*                       0      4      8          12                */
        ldr r1, =#-(GRID_SIZE + 4 + 4 + 4 + 4)
        add sp, sp, r1
        mov r0, sp
        bl snake$init
        mov r11, sp

        /*
        BG modes
        */
        mov r0, #IO_REG
        mov r2, #0x0
        orr r2, r2, #BG_CNT__COLOR_16_16
        orr r2, r2, #BG_CNT__SCREEN_SIZE(0)
        orr r2, r2, #BG_CNT__CHAR_BASE_BLOCK(0)
        orr r2, r2, #BG_CNT__SCREEN_BASE_BLOCK(31)
        orr r2, r2, #BG_CNT__PRIORITY(1)
        strh r2, [r0, #BG1CNT]

        mov r0, #IO_REG
        mov r2, #0x0
        orr r2, r2, #BG_CNT__COLOR_16_16
        orr r2, r2, #BG_CNT__SCREEN_SIZE(0)
        orr r2, r2, #BG_CNT__CHAR_BASE_BLOCK(0)
        orr r2, r2, #BG_CNT__SCREEN_BASE_BLOCK(30)
        orr r2, r2, #BG_CNT__PRIORITY(0)
        strh r2, [r0, #BG0CNT]

        mov r0, #IO_REG
        mov r2, #0x0
        orr r2, r2, #DISPCNT__BG0
        orr r2, r2, #DISPCNT__BG1
        orr r2, r2, #DISPCNT__BG_MODE_0
        strh r2, [r0, #DISPCNT]

        /*
        interrupts
        */
        ldr r0, =#IWRAM_USER_ISR
        ldr r2, =_user_isr
        str r2, [r0]

        mov r0, #IO_REG
        mov r1, #TM1CNT_L
        ldr r2, =#-4096
        strh r2, [r0, r1]

        ldr r1, =#TM1CNT_H
        mov r2, #0
        orr r2, r2, #TM_CNT_H__ENABLE
        orr r2, r2, #TM_CNT_H__INT_ENABLE
        orr r2, r2, #TM_CNT_H__PRESCALAR_1024
        strh r2, [r0, r1]

        ldr r1, =#KEYCNT
        mov r2, #0
        orr r2, r2, #KEYCNT_INPUT__RIGHT
        orr r2, r2, #KEYCNT_INPUT__LEFT
        orr r2, r2, #KEYCNT_INPUT__UP
        orr r2, r2, #KEYCNT_INPUT__DOWN
        orr r2, r2, #KEYCNT__INT_ENABLE
        strh r2, [r0, r1]

        mov r0, #IO_REG
        mov r1, #IE
        mov r2, #0
        orr r2, r2, #IE__TIMER_1
        orr r2, r2, #IE__KEY
        strh r2, [r0, r1]

        ldr r1, =#IF
        mov r2, #0
        add r2, r2, #-1
        strh r2, [r0, r1]

        mov r0, #IO_REG
        mov r1, #IME
        mov r2, #IME__INT_MASTER_ENABLE
        strh r2, [r0, r1]

_forever:
        mov r0, #IO_REG
        ldr r1, =#HALTCNT
        mov r2, #0
        /*strb r2, [r0, r1]*/
        b _forever

_user_isr:
        mov r0, #IO_REG
        mov r1, #IME
        mov r2, #0
        strh r2, [r0, r1]

        mov r12, lr

        /*
        input poll
        */
        bl input$poll /* return r1: dir */
        mov r3, r1

        mov r0, #IO_REG
        ldr r1, =#IF
        ldrh r2, [r0, r1]
        tst r2, #IE__KEY
        bne _update_dir

_update:
        /*
        update
        */
        /* r11: grid base address */
        /* r1 dir */
        mov r0, r11
        mov r1, r3
        /*bl snake$update*/

        b _isr_return

_update_dir:
        mov r0, r11
        mov r1, r3
        bl snake$update_dir

_isr_return:
        mov r0, #IO_REG
        ldr r1, =#IF
        mov r2, #0
        orr r2, #IE__KEY
        orr r2, #IE__TIMER_1
        strh r2, [r0, r1]

        /*
        render
        */
        mov r0, r11
        ldr r1, =#SCREEN_BASE_BLOCK(29)
        add r1, r1, #VRAM
        bl snake$render

        /* r0 dest, r1 src, r2 length */
        ldr r0, =#SCREEN_BASE_BLOCK(30)
        add r0, r0, #VRAM
        ldr r1, =#SCREEN_BASE_BLOCK(29)
        add r1, r1, #VRAM
        mov r2, #(SCREEN_BASE_BLOCK_LENGTH / 4)
        bl dma0$transfer

        mov lr, r12

        mov r0, #IO_REG
        mov r1, #IME
        mov r2, #IME__INT_MASTER_ENABLE
        strh r2, [r0, r1]

        bx lr
