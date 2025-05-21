# Makefile for myebookreader

CC = gcc
CFLAGS = -Wall -O2
TARGET = myebookreader
SRC = myebookreader.c

.PHONY: all clean

all: $(TARGET)

$(TARGET): $(SRC)
	$(CC) $(CFLAGS) -o $(TARGET) $(SRC)

clean:
	rm -f $(TARGET)
