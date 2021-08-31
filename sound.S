#include "base.h"
#include "regs.h"

        .section .text
        .global sound
sound:
        /* sound */
        mov r1, #SOUNDCNT_X
        mov r2, #0
        orr r2, r2, #SOUNDCNT_X__ENABLE
        orr r2, r2, #SOUNDCNT_X__ENABLE_1
        orr r2, r2, #SOUNDCNT_X__ENABLE_2
        strh r2, [r0, r1]

        mov r1, #SOUNDCNT_L
        mov r2, #0
        orr r2, r2, #SOUNDCNT_L__OUTPUT_1_L
        orr r2, r2, #SOUNDCNT_L__OUTPUT_1_R
        orr r2, r2, #SOUNDCNT_L__OUTPUT_2_L
        orr r2, r2, #SOUNDCNT_L__OUTPUT_2_R
        orr r2, r2, #SOUNDCNT_L__OUTPUT_LEVEL_L(7)
        orr r2, r2, #SOUNDCNT_L__OUTPUT_LEVEL_R(7)
        strh r2, [r0, r1]

        mov r1, #SOUNDCNT_H
        mov r2, #0
        orr r2, r2, #SOUNDCNT_H__OUTPUT_RATIO_FULL
        strh r2, [r0, r1]

        mov r1, #SOUND1_CNT_L
        mov r2, #0
        orr r2, r2, #SOUND1_CNT_L__SWEEP_TIME(0)
        orr r2, r2, #SOUND1_CNT_L__SWEEP_DECREASE
        orr r2, r2, #SOUND1_CNT_L__SWEEP_SHIFTS(0)
        strh r2, [r0, r1]

        /* enable timer */

        mov r1, #TM1CNT_L
        ldr r2, =#-1024
        strh r2, [r0, r1]

        ldr r1, =#TM1CNT_H
        mov r2, #0
        orr r2, r2, #TM_CNT_H__ENABLE
        orr r2, r2, #TM_CNT_H__INT_ENABLE
        orr r2, r2, #TM_CNT_H__PRESCALAR_1024
        strh r2, [r0, r1]

        ldr r10, =_korobeniki_voice1_start
        ldr r11, =_korobeniki_voice1_end
        mov r9, #0
        ldr r7, =_korobeniki_voice2_start
        ldr r8, =_korobeniki_voice2_end
        mov r6, #0
_stop:
        b _stop

        /* sound isr */

        .global sound_isr
sound_isr:
        mov r0, #IO_REG
        mov r1, #(IF - 2)
        add r1, r1, #2
        mov r2, #IE__TIMER_1
        strh r2, [r0, r1]

_voice1:
        ldrh r1, [r10]
        mov r2, #(0x7ff + 1)
        add r2, r2, #-1
        and r5, r1, r2  /* r5: frequency */
        lsr r4, r1, #11 /* r4: duration */

        mov r1, r9 /* r1: original state */
        add r9, r9, #1
        cmp r1, r4
        addeq r10, r10, #2 /* next note on next isr */
        moveq r9, #0
        cmp r10, r11
        ldreq r10, =_korobeniki_voice1_start

        mov r2, #0
        cmp r1, r2
        bne _voice2

        mov r1, #SOUND1_CNT_H
        mov r3, #0
        cmp r5, r2 /* no sound for value 0 */
        orrne r3, r3, #SOUND1_CNT_H__ENVELOPE_VALUE(12)
        orr r3, r3, #SOUND1_CNT_H__ENVELOPE_STEPS(3)
        orr r3, r3, #SOUND1_CNT_H__DUTY_CYCLE(2)
        /*orr r3, r3, #SOUND1_CNT_H__SOUND_LENGTH(40)*/
        strh r3, [r0, r1]

        mov r1, #SOUND1_CNT_X
        mov r2, r5
        /*ldr r2, =#SOUND1_CNT_X__FREQUENCY_DATA(1750) /* 440Hz */
        /*orr r2, r2, #SOUND1_CNT_X__SOUND_LENGTH*/
        orr r2, r2, #SOUND1_CNT_X__RESTART
        strh r2, [r0, r1]

_voice2:
        ldrh r1, [r7]
        mov r2, #(0x7ff + 1)
        add r2, r2, #-1
        and r5, r1, r2  /* r5: frequency */
        lsr r4, r1, #11 /* r4: duration */

        mov r1, r6 /* r1: original state */
        add r6, r6, #1
        cmp r1, r4
        addeq r7, r7, #2 /* next note on next isr */
        moveq r6, #0
        cmp r7, r8
        ldreq r7, =_korobeniki_voice2_start

        mov r2, #0
        cmp r1, r2
        bne _end

        mov r1, #SOUND2_CNT_L
        mov r3, #0
        cmp r5, r2 /* no sound for value 0 */
        orrne r3, r3, #SOUND2_CNT_L__ENVELOPE_VALUE(12)
        orr r3, r3, #SOUND2_CNT_L__ENVELOPE_STEPS(1)
        orr r3, r3, #SOUND2_CNT_L__DUTY_CYCLE(0)
        /*orr r3, r3, #SOUND2_CNT_L__SOUND_LENGTH(63)*/
        strh r3, [r0, r1]

        mov r1, #SOUND2_CNT_H
        mov r3, r5
        /*ldr r2, =#SOUND2_CNT_H__FREQUENCY_DATA(1750) /* 440Hz */
        /*orreq r2, r2, #SOUND2_CNT_H__SOUND_LENGTH  /* no sound for rest */
        /*add r2, r2, #256*/
        orr r3, r3, #SOUND2_CNT_H__RESTART
        strh r3, [r0, r1]

_end:
        bx lr

        /* sound data */
        .include "korobeniki.s"
