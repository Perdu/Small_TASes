CC ?= cc
CFLAGS ?= -O3 -std=c11 -Wall -Wextra -Wpedantic
all: bruteforce
bruteforce: bruteforce.c
	$(CC) $(CFLAGS) -o $@ $<
clean:
	rm -f bruteforce
