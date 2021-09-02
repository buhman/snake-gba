#define TYPE_EMPTY 0
#define TYPE_SNAKE 1
#define TYPE_FOOD  2

#define BEND_RIGHT 0
#define BEND_LEFT  1
#define BEND_UP    2
#define BEND_DOWN  3

#define GRID_COLS 32
#define GRID_ROWS 32
#define GRID_LENGTH (GRID_COLS * GRID_ROWS)
#define GRID_SIZE (GRID_LENGTH * 1)

#define GRID_MAX_X 29
#define GRID_MAX_Y 19

/*
  cell {
    type (2bit)
    head (3bit)
    tail (3bit)
  } (8bit)
*/
