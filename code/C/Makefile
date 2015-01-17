CC=gcc
CFLAGS=-std=c99 -c -Wall -g
LDFLAGS= -lm

all: kaverages kkmeans txtMatrixToBinary

kaverages : kaverages.o utils.o
	$(CC) kaverages.o utils.o -o kaverages  $(LDFLAGS)

kkmeans : kkmeans.o utils.o
	$(CC) kkmeans.o utils.o -o kkmeans $(LDFLAGS) 

txtMatrixToBinary : txtMatrixToBinary.o utils.o
	$(CC) txtMatrixToBinary.o utils.o -o txtMatrixToBinary $(LDFLAGS)

.c.o:
	$(CC) $(CFLAGS) $< -o $@
