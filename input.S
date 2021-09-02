#include "base.h"
#include "regs.h"
#include "input.h"

        .global input$poll
input$poll:
        /* return: r1 dir */
        mov r0, #IO_REG
        add r0, r0, #KEY_INPUT
        ldrh r2, [r0]
        mvn r2, r2

        mov r0, #0xf
        and r2, r0, r2, LSR #4 /* d-pad */

        mov r1, #DIR_NONE

        cmp r2, #INPUT_RIGHT_ONLY
        moveq r1, #DIR_RIGHT
        cmp r2, #INPUT_LEFT_ONLY
        moveq r1, #DIR_LEFT
        cmp r2, #INPUT_UP_ONLY
        moveq r1, #DIR_UP
        cmp r2, #INPUT_DOWN_ONLY
        moveq r1, #DIR_DOWN

        bx lr
