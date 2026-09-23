/*
 * con2fbmap - lee o fija a que framebuffer esta mapeada una consola virtual.
 *
 * Uso:
 *   con2fbmap <consola>                  Imprime el indice de framebuffer actual.
 *   con2fbmap <consola> <framebuffer>    Remapea la consola a ese framebuffer.
 *
 * No forma parte de ningun paquete de Arch, asi que se compila e instala a
 * mano (ver system/tty-console-remap/tty-console-remap.service para el
 * despliegue). El indice de consola es 1-based (tty1 = consola 1).
 */

#include <fcntl.h>
#include <linux/fb.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/ioctl.h>
#include <unistd.h>

int main(int argc, char *argv[]) {
    if (argc != 2 && argc != 3) {
        fprintf(stderr, "uso: %s <consola> [framebuffer]\n", argv[0]);
        return 2;
    }

    struct fb_con2fbmap map = {0};
    map.console = (unsigned int)strtoul(argv[1], NULL, 10);

    int fd = open("/dev/fb0", O_RDWR);
    if (fd < 0) {
        perror("open /dev/fb0");
        return 1;
    }

    if (argc == 2) {
        if (ioctl(fd, FBIOGET_CON2FBMAP, &map) < 0) {
            perror("ioctl FBIOGET_CON2FBMAP");
            close(fd);
            return 1;
        }
        printf("%u\n", map.framebuffer);
    } else {
        map.framebuffer = (unsigned int)strtoul(argv[2], NULL, 10);
        if (ioctl(fd, FBIOPUT_CON2FBMAP, &map) < 0) {
            perror("ioctl FBIOPUT_CON2FBMAP");
            close(fd);
            return 1;
        }
    }

    close(fd);
    return 0;
}
