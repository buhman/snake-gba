/* 4 LCD Status */
#define DISPSTAT 0x004
#define DISPSTAT__V_BLANK_INT_ENABLE (1 << 3)
#define VCOUNT 0x006

/* 5 Image System */
#define DISPCNT 0x000
#define DISPCNT__BG0 (1 << 8)
#define DISPCNT__BG1 (1 << 9)
#define DISPCNT__BG2 (1 << 10)
#define DISPCNT__BG3 (1 << 11)
#define DISPCNT__OBJ (1 << 12)
#define DISPCNT__BG_MODE_0 0
#define DISPCNT__BG_MODE_1 1
#define DISPCNT__BG_MODE_2 2
#define DISPCNT__BG_MODE_3 3
#define DISPCNT__BG_MODE_4 4
#define DISPCNT__BG_MODE_5 5

/* 6 Rendering Functions */
#define BG0CNT 0x008
#define BG1CNT 0x00a
#define BG2CNT 0x00c
#define BG3CNT 0x00e

#define BG_CNT__CHAR_BASE_BLOCK(n) (n << 2)
#define BG_CNT__MOSAIC (1 << 6)
#define BG_CNT__COLOR_16_16 0
#define BG_CNT__COLOR_256 (1 << 7)
#define BG_CNT__SCREEN_BASE_BLOCK(n) (n << 8)
#define BG_CNT__SCREEN_SIZE(n) (n << 14)
#define BG_CNT__PRIORITY(n) (n << 0)

#define MOSAIC 0x04c

/* 6.1.7 BG Rotation and Scaling Features */
#define BG2PA 0x020
#define BG2PB 0x022
#define BG2PC 0x024
#define BG2PD 0x026
#define BG3PA 0x030
#define BG3PB 0x032
#define BG3PC 0x034
#define BG3PD 0x036

/* 6.1.8 BG Scrolling */
#define BG0HOFS 0x010
#define BG0VOFS 0x012
#define BG1HOFS 0x014
#define BG1VOFS 0x016
#define BG2HOFS 0x018
#define BG2VOFS 0x01a
#define BG3HOFS 0x01c
#define BG3VOFS 0x01e

/* 14 Key Input */
#define KEY_INPUT 0x130
#define KEY_INPUT__A   0
#define KEY_INPUT__B   1
#define KEY_INPUT__SL  2
#define KEY_INPUT__ST  3
#define KEY_INPUT__RIGHT 4
#define KEY_INPUT__LEFT  5
#define KEY_INPUT__UP    6
#define KEY_INPUT__DOWN  7
#define KEY_INPUT__L   8
#define KEY_INPUT__R   9

#define KEYCNT 0x132
#define KEYCNT__INT_ENABLE (1 << 14)

/* 15 Interrupt Control */
#define IME 0x208
#define IME__INT_MASTER_ENABLE (1 << 0)

#define IE  0x200
#define IE__RENDER_BLANK_V  (1 << 0)
#define IE__RENDER_BLANK_H  (1 << 1)
#define IE__V_COUNTER_MATCH (1 << 2)
#define IE__TIMER_0         (1 << 3)
#define IE__TIMER_1         (1 << 4)
#define IE__TIMER_2         (1 << 5)
#define IE__TIMER_3         (1 << 6)
#define IE__SERIAL          (1 << 7)
#define IE__DMA_0           (1 << 8)
#define IE__DMA_1           (1 << 9)
#define IE__DMA_2           (1 << 10)
#define IE__DMA_3           (1 << 11)
#define IE__KEY             (1 << 12)
#define IE__GAME_PAK        (1 << 13)

#define IF  0x202
