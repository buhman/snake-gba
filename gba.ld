OUTPUT_FORMAT("elf32-littlearm", "elf32-littlearm", "elf32-littlearm")
OUTPUT_ARCH(arm)

#include "base.h"

MEMORY
{
  gprom : ORIGIN = GPROM, LENGTH = 32M
  iwram : ORIGIN = IWRAM, LENGTH = 32K
  ewram : ORIGIN = EWRAM, LENGTH = 256K
}

SECTIONS
{
  .text : ALIGN(4)
  {
    _start = .;
    KEEP(*(.rom.start_addr))
    KEEP(*(.rom.nintendo_logo))
    KEEP(*(.rom.header))
    *(*.text)
  } > gprom
}
