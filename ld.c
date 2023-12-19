#include <stdio.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <unistd.h>

int main(int argc, char *argv[]) {
    if (argc < 2) {
        printf("usage: ld <raw-binary>\n");
        exit(1);
    }

    char *filename = argv[1];
    int fd = open(filename, O_RDONLY);
    if (fd < 0) {
        perror("Failed to open file");
        return 1;
    }

    // get the size of the binary
    off_t size = lseek(fd, 0, SEEK_END);
    lseek(fd, 0, SEEK_SET);

    // allocate executable memory
    void *bin = mmap(NULL, size, PROT_READ | PROT_WRITE | PROT_EXEC, MAP_PRIVATE, fd, 0);
    if (bin == MAP_FAILED) {
        perror("Failed to mmap");
        close(fd);
        return 1;
    }

    close(fd);

    // cast the binary to a function pointer and call it
    void (*func)() = bin;
    func();

    // free the memory
    munmap(bin, size);

    return 0;
}
