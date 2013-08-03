#define _GNU_SOURCE
#include <dlfcn.h>
#include <stdlib.h>

/* We can not take this from <sys/ioctl.h>, because it would define the
 * ioctl-function itself
 */
struct winsize {
    unsigned short ws_row;
    unsigned short ws_col;
    unsigned short ws_xpixel;
    unsigned short ws_ypixel;
};

int ioctl (int d, int request, char *argp) {
    static int (*orig_ioctl)(int, int, char *);
    if (orig_ioctl == NULL) {
        orig_ioctl = dlsym(RTLD_NEXT, "ioctl");
    }
    static int max_rows = -1;
    if (max_rows < 0 ) {
        char *str = getenv("SHELLEX_MAX_ROWS");
        if (str != NULL) {
            max_rows = atoi(str);
        }
    }

    // We only care for TIOCSWINSZ ioctls
    if (request != 0x5414) {
        return orig_ioctl(d, request, argp);
    }

    struct winsize ws = *((struct winsize *)argp);
    int fheight = ws.ws_ypixel / ws.ws_row;
    if (max_rows < 0) {
        ws.ws_row = 80;
        ws.ws_ypixel += 80 * fheight;
    } else {
        ws.ws_row = max_rows;
        ws.ws_ypixel += max_rows * fheight;
    }

    return orig_ioctl(d, request, (char *)&ws);
}
