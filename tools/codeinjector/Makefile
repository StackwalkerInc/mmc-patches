CC = gcc
CFLAGS = -O2 -Wall
LDFLAGS = -lbfd -liberty -lz

codeinjector: main.o supported_ecus.o
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

main.o: main.c supported_ecus.h
	$(CC) $(CFLAGS) -c -o $@ $<

supported_ecus.o: supported_ecus.c supported_ecus.h
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f *.o codeinjector
