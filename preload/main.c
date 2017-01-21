/*
 * shellex - shell based launcher
 *   This is a small LD_PRELOAD library to work around some issues
 * © 2013 Axel Wagner and contributors (see also: LICENSE)
 */
#define _GNU_SOURCE
#include <dlfcn.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

/* We can not take this from <sys/ioctl.h>, because it would define the
 * ioctl-function itself
 */
struct winsize {
    unsigned short ws_row;
    unsigned short ws_col;
    unsigned short ws_xpixel;
    unsigned short ws_ypixel;
};

int ioctl(int d, int request, char *argp) {
    static int (*orig_ioctl)(int, int, char *);
    if (orig_ioctl == NULL) {
        orig_ioctl = dlsym(RTLD_NEXT, "ioctl");
    }

    /* We only care for TIOCGWINSZ ioctls */
    if (request != 0x5413) {
        return orig_ioctl(d, request, argp);
    }

    static int max_rows = -1;

    /* ioctl gets called once before the perl module had the time to determine
     * the right size! Leave max_rows negative to indicat that it still needs to
     * be read from the SHELLEX_SIZE_FILE */

    if (max_rows < 0) {

        char *fname = getenv("SHELLEX_SIZE_FILE");
        if (fname != NULL && fname[0] != '\0') {
            FILE *stream = fopen(fname, "r");
            char str[5] = "-500";
            if (stream != NULL) {
                char *ret = fgets(str, 5, stream);
                fclose(stream);
                if (ret != NULL) {
                    /* this may be -500 */
                    max_rows = atoi(str);
                    if (max_rows > 0) {
                        unlink(fname);
                    }
                }
            }
        }
    }

    int retval = orig_ioctl(d, request, (char *)argp);
    struct winsize *ws = (struct winsize *)argp;

    /* max_rows is still negative at first invocation */
    int fheight = ws->ws_ypixel / ws->ws_row;
    ws->ws_row = (max_rows > 0) ? max_rows : 25;
    ws->ws_ypixel = ws->ws_row * fheight;

    return retval;
}
