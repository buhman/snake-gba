#include "base.h"
#include "regs.h"

        .global uart$init
uart$init:
        mov r0, #IO_REG
        mov r1, #RCNT
        mov r2, #0x0
        strh r2, [r0, r1]

        mov r1, #SIOCNT
        mov r2, #0x0
        orr r2, r2, #SIOCNT__UART_MODE
        orr r2, r2, #SIOCNT__UART_RECV_ENABLE
        orr r2, r2, #SIOCNT__UART_SEND_ENABLE
        orr r2, r2, #SIOCNT__UART_DATA_8BIT
        orr r2, r2, #SIOCNT__BAUD_RATE_9600
        strh r2, [r0, r1]

        bx lr

        .global uart$test
uart$test:
        mov r0, #IO_REG

        /*
        mov r1, #KEY_INPUT
        ldrh r2, [r0, r1]
        mov r1, #0b1111
        and r2, r2, r1
        */

        ldr r1, =#SIOCNT
        ldrh r2, [r0, r1]
        mov r3, #1
        and r4, r3, r2, LSR #SIOCNT__UART_RECV_EMPTY
        cmp r4, #1

        ldr r1, =#SIODATA8
        ldrh r2, [r0, r1]
        and r2, r2, #0xff
        strh r2, [r0, r1]
        bx lr

        mov r2, #0x61
        strh r2, [r0, r1]

        bx lr
