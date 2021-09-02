#include "regs.h"
#include "base.h"

        .section .text
        .global minmin
minmin:
        /* palettes */
        mov r0, #PRAM_BG
        add r0, r0, #0 /* palette 0 */
        bl copy_palette

        /* tiles */
        mov r0, #VRAM
        add r0, r0, #0 /* tile base block 0 */
        bl copy_tiles

        /* screen */
        mov r0, #VRAM
        ldr r1, =#0xf800 /* screen base block 31 */
        add r0, r0, r1
        bl copy_screen

        /* BG0 */
        mov r0, #IO_REG
        mov r1, #0x0
        orr r1, r1, #BG_CNT__COLOR_16_16
        orr r1, r1, #BG_CNT__SCREEN_SIZE(0)
        orr r1, r1, #BG_CNT__CHAR_BASE_BLOCK(0)
        orr r1, r1, #BG_CNT__SCREEN_BASE_BLOCK(31)
        orr r1, r1, #BG_CNT__PRIORITY(1)
        strh r1, [r0, #BG0CNT]

        mov r0, #IO_REG
        mov r1, #0x0
        orr r1, r1, #DISPCNT__BG0
        orr r1, r1, #DISPCNT__BG_MODE_0
        strh r1, [r0, #DISPCNT]

        b minmin_ret
        b int
_m_stop:
        b _m_stop

copy_palette:
        /* arg r0: pram address */
        ldr r1, _ps
        ldr r3, _pe
_cp_loop:
        ldrh r2, [r1], #2
        strh r2, [r0], #2
        cmp r1, r3
        bne _cp_loop

        bx lr
_ps:
        .word __palette_start
_pe:
        .word __palette_end

copy_tiles:
        /* arg r0: vram address */
        ldr r1, _ms
        ldr r3, _me
_ct_loop:
        ldr r2, [r1], #4
        str r2, [r0], #4
        cmp r1, r3
        bne _ct_loop

        bx lr
_ms:
        .word __tiles_start
_me:
        .word __tiles_end

copy_screen:
        mov r1, #1024
        mov r2, #0
_cs_loop:
        /*orr r3, r2, #SCREEN_TEXT_PALETTE(1)*/
        strh r2, [r0], #2
        add r2, r2, #1
        cmp r2, r1
        bne _cs_loop

        bx lr

        /* data */
__palette_start:
        .include "minmin_palette.s"
__palette_end:

__tiles_start:
        .incbin "tiles.bin"
__tiles_end:
