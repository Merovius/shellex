CFLAGS+="-Wall"
LDFLAGS+="-ldl"

all: shellex_preload.so

shellex_preload.so: main.c
	$(CC) $(CFLAGS) $(LDFLAGS) -fPIC -shared -o shellex_preload.so main.c -ldl
