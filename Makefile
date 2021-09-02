ARCH = -mthumb-interwork -march=armv4t
override CFLAGS += -Wall -mtune=arm7tdmi -ffreestanding -nostdlib -g
ASFLAGS = -g

TARGET = arm-none-eabi-
CC = $(TARGET)gcc
AS = $(TARGET)as
LD = $(TARGET)ld
OBJCOPY = $(TARGET)objcopy
OBJDUMP = $(TARGET)objdump

OBJS = header.o main.o glyph.o minmin.o text.o sound.o
#OBJS += ../aoc2020-gba/day1/day1.a

OBJS2 = header.o main2.o tile.o palette.o screen.o dma.o snake.o input.o arrow.o

all: snake.gba

glyph.o: font.s

%.o: %.S
	$(CC) $(ARCH) $(ASFLAGS) -c $< -o $@

%.o: %.s
	$(AS) $(ARCH) $(ASFLAGS) $< -o $@

%.o: %.c
	$(CC) $(ARCH) $(CFLAGS) -c $< -o $@

%.lds: %.ld
	$(CC) -E -P -x c $< -o $@

%.elf: %.o
	$(LD) $< -o $@

snake2.elf: $(OBJS2) | gba.lds
	$(LD) -T gba.lds $^ -o $@

snake.elf: $(OBJS) | gba.lds
	$(LD) -T gba.lds $^ -o $@

%.gba: %.elf
	$(OBJCOPY) -O binary $< $@

dump:
	arm-none-eabi-objdump -D -j .text $(F)

clean:
	rm -f *.o *.out *.hex *.elf

deploy: snake2.gba
	mount /dev/sdc1 /mnt
	cp $< /mnt/00.gba
	umount /mnt
	sync

.SUFFIXES:
.INTERMEDIATE:
.PHONY: all clean dump
