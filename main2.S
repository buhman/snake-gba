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
        ldr r2, =#-8192
        strh r2, [r0, r1]

        ldr r1, =#TM1CNT_H
        mov r2, #0
        orr r2, r2, #TM_CNT_H__ENABLE
        orr r2, r2, #TM_CNT_H__INT_ENABLE
        orr r2, r2, #TM_CNT_H__PRESCALAR_1024
        strh r2, [r0, r1]

        mov r0, #IO_REG
        mov r1, #IE
        mov r2, #IE__TIMER_1
        strh r2, [r0, r1]

        mov r0, #IO_REG
        mov r1, #IME
        mov r2, #IME__INT_MASTER_ENABLE
        strh r2, [r0, r1]

        /* allocate (GRID_SIZE + head + tail) from sp */
        ldr r1, =#-(GRID_SIZE + 4 + 4)
        add sp, sp, r1
        mov r0, sp
        bl snake$init
        mov r11, sp

_forever:
        mov r0, #IO_REG
        ldr r1, =#HALTCNT
        mov r2, #0
        strb r2, [r0, r1]
        b _forever

_user_isr:
        mov r0, #IO_REG
        ldr r1, =#IF
        mov r2, #IE__TIMER_1
        strh r2, [r0, r1]

        mov r12, lr

        /* r11: grid base address */

        /*
        input poll
        */
        bl input$poll /* return r1: dir */

        /*
        update
        */
        mov r0, r11
        /* r1 dir */
        bl snake$update

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
        bx lr
