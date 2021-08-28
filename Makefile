ARCH = -mthumb-interwork -march=armv4t
override CFLAGS += -Wall -mtune=arm7tdmi -ffreestanding -nostdlib -g
ASFLAGS = -g

TARGET = arm-none-eabi-
CC = $(TARGET)gcc
AS = $(TARGET)as
LD = $(TARGET)ld
OBJCOPY = $(TARGET)objcopy
OBJDUMP = $(TARGET)objdump

all: snake.gba

%.o: %.S
	$(CC) $(ARCH) $(ASFLAGS) -c $< -o $@

%.o: %.s
	$(AS) $(ARCH) $(ASFLAGS) $< -o $@

%.o: %.c
	$(CC) $(ARCH) $(CFLAGS) $< -o $@

%.lds: %.ld
	$(CC) -E -P -x c $< -o $@

snake.elf: header.o gba.lds
	$(LD) -T gba.lds $< -o $@

snake.gba: snake.elf
	$(OBJCOPY) -O binary $< $@

dump:
	arm-none-eabi-objdump -D -j .text $(F)

a.out:
	$(LD) $^ -o $@

clean:
	rm -f *.o *.out *.hex *.elf

.SUFFIXES:
.INTERMEDIATE:
.PHONY: all clean dump
