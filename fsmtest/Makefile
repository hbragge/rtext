all: fsmtest

fsm.c: fsmgen.rb
	ruby fsmgen.rb

fsmtest: fsmtest.c fsm.c fsm.h
	gcc -Wall -Werror -o fsmtest fsmtest.c fsm.c

clean:
	rm -f fsmtest fsm.c

.PHONY: all clean
