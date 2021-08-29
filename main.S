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

        /* fill top-left 240x160 region with red */
        mov r0, #VRAM
        add r1, r0, #0x12c00
        mov r2, #0x1f
_fill_loop:
        strh r2, [r0], #2
        cmp r0, r1
        bne _fill_loop

        /* rotation */
        /*
        mov r0, #IO_REG
        mov r1, #120
        strh r1, [r0, #BG2PA]
        mov r1, #80
        strh r1, [r0, #BG2PC]
        */

        /* bg palette */
        mov r0, #PRAM_BG
        mov r1, #0x1f
        strh r1, [r0], #2
        mov r1, r1, LSL #5
        strh r1, [r0], #2
        mov r1, r1, LSL #5
        strh r1, [r0], #2

        /* tile 0 */
        /* 8x8 tile * 1 byte per px = 64 bytes / tile */
        mov r0, #VRAM
        mov r1, #64
        mov r2, #0x1
        orr r2, r2, LSL #8
_tile_0:
        strh r2, [r0], #2
        subs r1, r1, #2
        bne _tile_0

        /* tile 1 */
        /* 8x8 tile * 1 byte per px = 64 bytes / tile */
        mov r0, #VRAM
        add r0, #64
        mov r1, #64
        mov r2, #0x2
        orr r2, r2, LSL #8
_tile_1:
        strh r2, [r0], #2
        subs r1, r1, #2
        bne _tile_1

        /* tile 2 */
        /* 8x8 tile * 1 byte per px = 64 bytes / tile */
        mov r0, #VRAM
        add r0, #128
        mov r1, #64
        mov r2, #0x0
        orr r2, r2, LSL #8
_tile_2:
        strh r2, [r0], #2
        subs r1, r1, #2
        bne _tile_2

        /* screen */
        mov r0, #VRAM
        add r0, r0, #0x4000
        mov r1, #0
        strh r1, [r0], #2
        mov r1, #1
        strh r1, [r0], #2
        mov r1, #2
        strh r1, [r0], #2

        mov r0, #VRAM
        add r0, r0, #0x4000
        add r0, r0, #0x40
        mov r1, #1
        strh r1, [r0], #2

        mov r0, #VRAM
        add r0, r0, #0x4000
        add r0, r0, #0x3a
        mov r1, #1
        strh r1, [r0], #2


        /* set text mode */
        mov r0, #IO_REG
        mov r1, #0x0
        orr r1, r1, #BG_CNT__COLOR_256
        orr r1, r1, #BG_CNT__SCREEN_SIZE(0)
        orr r1, r1, #BG_CNT__CHAR_BASE_BLOCK(0)
        orr r1, r1, #BG_CNT__SCREEN_BASE_BLOCK(8)
        /*orr r1, r1, #BG_CNT__MOSAIC*/
        strh r1, [r0, #BG0CNT]

        /* mosaic size */
        mov r1, #0
        strh r1, [r0, #MOSAIC]

        /* */
        mov r0, #IO_REG
        mov r1, #0x0
        orr r1, r1, #DISPCNT__BG0
        orr r1, r1, #DISPCNT__BG_MODE_0
        strh r1, [r0, #DISPCNT]

_stop:
        b _stop
