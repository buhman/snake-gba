#define RGB15(r5, g5, b5) ((b5 << 10) | (g5 << 5) | (r5 << 0))

        .global _start
_start:
        .global palette$basic
palette$basic:
        /* arg r0: palette address at color index 0 */

        ldr r9, =__basic_first
        ldmia r9!, {r1 - r8}
        stmia r0!, {r1 - r8}

        bx lr

__basic_first:
        .short 0x0 /* hardcoded to transparent */
        .short RGB15(31, 31, 31) /* 1: white */
        .short RGB15(31,  0,  0) /* 2: red */
        .short RGB15(31, 31,  0) /* 3: yellow */
        .short RGB15( 0, 31,  0) /* 4: green */
        .short RGB15( 0, 31, 31) /* 5: cyan */
        .short RGB15( 0,  0, 31) /* 6: blue */
        .short RGB15(31,  0, 31) /* 7: magenta */

        .short RGB15( 0,  0,  0) /* 8: black */
        .short RGB15( 8,  8,  8) /* 9: grey */
        .short RGB15( 8,  0,  0) /* 10: dark red */
        .short RGB15( 8,  8,  0) /* 11: dark yellow */
        .short RGB15( 0,  8,  0) /* 12: dark green */
        .short RGB15( 0,  8,  8) /* 13: dark cyan */
        .short RGB15( 0,  0,  8) /* 14: dark blue */
        .short RGB15( 8,  0,  8) /* 15: dark magenta */
__basic_last:
