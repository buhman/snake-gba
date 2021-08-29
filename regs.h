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
#define BG_CNT__COLOR_256 (1 << 7)
#define BG_CNT__SCREEN_BASE_BLOCK(n) (n << 8)
#define BG_CNT__SCREEN_SIZE(n) (n << 14)

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
