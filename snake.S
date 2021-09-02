#include "snake.h"
#include "input.h"
#include "regs.h"

        .global snake$init
snake$init:
        /* arg r0: grid base address */

        mov r9, #GRID_SIZE
        add r9, r9, r0

        .irp i, 1, 2, 3, 4, 5, 6, 7, 8
        mov r\i, #0
        mov r\i, r1
        .endr
_init_loop:
        stmia r0!, {r1 - r8}
        cmp r0, r9
        bne _init_loop

        /* r0: head address */
        sub r2, r0, #(GRID_SIZE - 16)
        str r2, [r0], #4
        mov r1, #TYPE_SNAKE
        strb r1, [r2]
        /* r0: tail address */
        sub r2, r2, #15
        str r2, [r0], #4
        strb r1, [r2], #1
        strb r1, [r2], #1
        strb r1, [r2], #1
        strb r1, [r2], #1
        strb r1, [r2], #1
        strb r1, [r2], #1
        strb r1, [r2], #1
        strb r1, [r2], #1
        strb r1, [r2], #1
        strb r1, [r2], #1
        strb r1, [r2], #1
        strb r1, [r2], #1
        strb r1, [r2], #1
        strb r1, [r2], #1
        strb r1, [r2], #1

        mov r3, #4
        strb r3, [r1]

        bx lr


__get_next_head:
        .macro GET_NEXT_HEAD
        /* arg: r1 dir */
        /* arg: r2 alternate NONE dir */
        /* arg: r6 address */
        /* clobber: r1-r4 */
        and r2, r6, #0x1f
        lsr r3, r6, #5
        and r3, r3, #0x1f

        cmp r1, #DIR_NONE
        mov r4, #0x3
        andeq r1, r4, r7, LSR #2
        cmp r1, #DIR_RIGHT
        addeq r2, r2, #1
        cmp r1, #DIR_LEFT
        addeq r2, r2, #-1
        cmp r1, #DIR_UP
        addeq r3, r3, #-1
        cmp r1, #DIR_DOWN
        addeq r3, r3, #1

        cmp r2, #GRID_MAX_X
        movgt r2, #GRID_MAX_X
        cmp r2, #0
        movlt r2, #0
        cmp r3, #GRID_MAX_Y
        movgt r3, #GRID_MAX_Y
        cmp r3, #0
        movlt r3, #0

        /* r4: next head offset */
        add r4, r2, r3, LSL #5
        .endm

        .global snake$update
snake$update:
        /* register allocation:

        arg
          r0 : grid base address (const)
          r1 : input dir

        semi-const
          r9 : head/tail address ptr
          r8 : (old) head/tail address
          r7 : (old) head/tail value
          r6 : (old) head/tail offset

        temp
          r2 : x
          r3 : y

        */

        /*
        head operations
        */

        /* load head */
        mov r9, #(GRID_SIZE + 0)
        add r9, r0, r9

        ldr r8, [r9]   /* address <- address ptr */
        ldrb r7, [r8]  /* value <- address */
        sub r6, r8, r0 /* offset <- */

        /* arg r0(grid base address), r1(dir), r6(offset) */
        /* clobber r1-r4 */
        /* return r1(next dir) r2(x), r3(y), r4(next head offset) */
        GET_NEXT_HEAD

        /* FIXME: collision checking should happen with x/y here */
        cmp r4, r6
        bxeq lr /* early return if we did not move */
        /* currently free: r2, r3, r5, r6 */

        /* update old_head->head */
        mov r7, #TYPE_SNAKE
        orr r7, r7, r1, LSL #2
        strb r7, [r8]

        /* create new head */
        mov r7, #TYPE_SNAKE
        and r1, r1, #3
        orr r7, r7, r1, LSL #2 /* head dir */
        add r4, r4, r0
        strb r7, [r4]
        str r4, [r9], #4

        /*
        tail operations
        */

        /* load tail */
        /* r9 is now tail from str increment ^ */

        ldr r8, [r9]   /* address <- address ptr */
        ldrb r7, [r8]  /* value <- address */
        sub r6, r8, r0 /* offset <- */

        /* r1 is the current tail's head */
        mov r1, #DIR_NONE

        /* arg r0(grid base address), r1(dir), r6(offset) */
        /* clobber r1-r4 */
        /* return r1(next dir) r2(x), r3(y), r4(next head offset) */
        GET_NEXT_HEAD

        /* delete old tail */
        mov r7, #0
        strb r7, [r8]
        /* set new tail ptr to next head */
        add r4, r4, r0
        str r4, [r9]

        bx lr


        .global snake$render
snake$render:
        /* arg r0: grid base address */
        /* arg r1: screen base block address */

        mov r3, #GRID_SIZE
        add r3, r3, r0

        mov r4, #3 /* 2-bit mask */

_render_loop:
        /* could be faster */
        ldrb r2, [r0], #1

        and r5, r4, r2, LSR #0 /* type */
        and r6, r4, r2, LSR #2 /* head */

        cmp r6, #BEND_RIGHT
        moveq r2, #16
        orreq r2, r2, #SCREEN_TEXT_H_FLIP
        cmp r6, #BEND_LEFT
        moveq r2, #16
        cmp r6, #BEND_UP
        moveq r2, #17
        cmp r6, #BEND_DOWN
        moveq r2, #17
        beq _there
_here:
        orreq r2, r2, #SCREEN_TEXT_V_FLIP

        cmp r5, #0
        moveq r2, #0

        strh r2, [r1], #2
        cmp r0, r3
        bne _render_loop

        bx lr

_there:
        b _here
