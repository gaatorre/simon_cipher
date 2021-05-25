OBJ = simon.o simon-test.o
CC = clang
CFLAGS = -Wextra -Wall -Werror -Wpedantic
EXEC = simon-test

all: $(OBJ)
	$(CC) $(OBJ) -o $(EXEC) $(CFLAGS)

debug: CFLAGS += -g
debug: all

%.o: %.c
	$(CC) $< -c $(CFLAGS)

clean:
	rm -f $(OBJ) $(EXEC)
