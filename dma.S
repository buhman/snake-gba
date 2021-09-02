#include "base.h"
#include "regs.h"

        .global dma0$transfer
dma0$transfer:
        /* arg r0: dest */
        /* arg r1: src */
        /* arg r2: length */

        mov r3, #IO_REG
        mov r4, #DMA0_DAD_L
        str r0, [r3, r4]

        mov r4, #DMA0_SAD_L
        str r1, [r3, r4]

        mov r4, #DMA0_CNT_L
        strh r2, [r3, r4]

        mov r4, #DMA0_CNT_H
        mov r5, #0
        orr r5, r5, #DMA0_CNT_H__ENABLE
        orr r5, r5, #DMA0_CNT_H__INT_ENABLE
        /*orr r5, r5, #DMA0_CNT_H__START_IMMEDIATE*/
        orr r5, r5, #DMA0_CNT_H__START_V_BLANK
        orr r5, r5, #DMA0_CNT_H__WORD_32_BIT
        orr r5, r5, #DMA0_CNT_H__SRC_INCREMENT
        orr r5, r5, #DMA0_CNT_H__DST_INCREMENT
        strh r5, [r3, r4]

        bx lr
