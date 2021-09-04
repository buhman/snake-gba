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
        .endr
_init_loop:
        stmia r0!, {r1 - r8}
        cmp r0, r9
        bne _init_loop

        /* r0: head address */
        /*#(GRID_SIZE / 2)*/
        sub r2, r0, #(GRID_SIZE)
        add r2, r2, #300
        str r2, [r0]
        mov r1, #TYPE_SNAKE
        strb r1, [r2]
        /* r0: tail address */
        str r2, [r0, #4]

        /* xorshift state */
        mov r2, #0
        add r2, r2, #-1
        str r2, [r0, #8]

        /* snake_length */
        mov r2, #0
        str r2, [r0, #12]

        add r0, r0, #-GRID_SIZE
        b _place_food

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

        .global snake$update_dir
snake$update_dir:
        /* arg
          r0 : grid base address (const)
          r1 : input dir
        */

        mov r9, #(GRID_SIZE + 0)
        add r9, r0, r9

        ldr r8, [r9]   /* address <- address ptr */
        ldrb r7, [r8]  /* value <- address */
        mov r7, #TYPE_SNAKE
        orr r7, r7, r1, LSL #2
        strb r7, [r8]

        bx lr

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
          r2 : x / xorshift state value
          r3 : y
          r4 : next_head_offset
          r5 : next_head_value
          r6 : head_offset
          r7 :
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

        cmp r4, r6
        beq _collision_w /* collision with a wall */

        /* check for grid collision at r4 */
        ldrb r5, [r4, r0]
        and r5, r5, #0b11 /* cell type */
        cmp r5, #TYPE_SNAKE
        beq _collision_s /* collision with a another snake cell */

        /* currently free: r2, r3, r6 */

        /* update old_head->head */
        mov r7, #TYPE_SNAKE
        orr r7, r7, r1, LSL #2
        strb r7, [r8]

        /* create new head */
        /* meh: mask off palette bits from original r7 */
        mov r7, #TYPE_SNAKE
        and r1, r1, #3
        orr r7, r7, r1, LSL #2 /* head dir */
        add r4, r4, r0
        strb r7, [r4]
        str r4, [r9], #4

        /* currently free: r2, r3, r4, r5, r6, r7 */

        cmp r5, #TYPE_FOOD
        beq _place_food
        bxeq lr

        /*
        tail operations
        */

        /* load tail */
        /* r9 is now tail from str increment ^ */

        ldr r8, [r9]   /* address <- address ptr */
        ldrb r7, [r8]  /* value <- address */
        sub r6, r8, r0 /* offset <- */

        /* arg r0(grid base address), r1(dir), r6(offset) */
        /* clobber r1-r4 */
        /* return r1(next dir) r2(x), r3(y), r4(next head offset) */
        /* NONE follows the tail forward to the next element */
        mov r1, #DIR_NONE
        GET_NEXT_HEAD

        /* delete old tail */
        mov r7, #0
        strb r7, [r8]
        /* set new tail ptr to next head */
        add r4, r4, r0
        str r4, [r9]

        bx lr

_place_food:
        ldr r2, =#(GRID_SIZE + 12)
        ldrh r1, [r0, r2]
        add r1, r1, #1
        strh r1, [r0, r2]

        ldr r3, =#(GRID_SIZE + 8) /* xorshift state */
        ldr r2, [r0, r3]
        eor r2, r2, r2, LSR #13
        eor r2, r2, r2, LSL #17
        eor r2, r2, r2, LSR #5
        str r2, [r0, r3]

        /* start start searching for empty cell at r1 */

        lsr r2, r2, #22
        add r1, r2, r0

        ldr r3, =#((32 * 20) - 2) /* last cell */
        add r3, r0

        add r1, r1, #-1
_next_empty_cell:
        add r1, r1, #1
_next_empty_cell_ge:
        sub r8, r1, r0
        and r7, r8, #0x1f
        cmp r7, #30
        addge r1, r1, #2

        cmp r1, r3
        movge r1, r0
        addge r1, r1, r2, LSR #1
        bge _next_empty_cell_ge

        ldrb r4, [r1]
        and r4, r4, #0b11
        cmp r4, #TYPE_EMPTY
        bne _next_empty_cell

_found_empty:
        mov r2, #TYPE_FOOD
        strb r2, [r1]
        bx lr

_collision_w:
        b _collision_w
_collision_s:
        b _collision_s


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
        orreq r2, r2, #SCREEN_TEXT_V_FLIP

        cmp r5, #TYPE_EMPTY
        moveq r2, #0
        cmp r5, #TYPE_FOOD
        moveq r2, #2

        strh r2, [r1], #2
        cmp r0, r3
        bne _render_loop

        bx lr
