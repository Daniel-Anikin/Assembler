FASM = fasm
CC = gcc
CFLAGS = -Wall -Wextra -O2
LDFLAGS = -no-pie
LDLIBS = -lncurses -ltinfo

all: lab_6

lab_6: lab_6.o
	$(CC) $(LDFLAGS) -o $@ $^ $(LDLIBS)

lab_6.o: lab_6.asm
	$(FASM) $< $@

run: lab_6
	./lab_6

clean:
	rm -f lab_6 lab_6.o

.PHONY: all run clean
