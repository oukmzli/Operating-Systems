#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Using: %s <file_name>\n", argv[0]);
        return 1;
    }

    int fd = open(argv[1], O_RDONLY);
    if (fd == -1) {
        perror("Error with opening file");
        return 1;
    }

    if (lseek(fd, -20, SEEK_END) == (off_t) -1) {
        perror("Error with positioning in file\n");
        close(fd);
        return 1;
    }

    unsigned char buffer[20];
    ssize_t bytesRead = read(fd, buffer, sizeof(buffer));
    if (bytesRead < 0) {
        perror("Error with reading file");
        close(fd);
        return 1;
    }

    if (bytesRead < 20) {
        printf("There is less than 20 bytes. There are these bytes:\n");
    } else {
        printf("The last 20 bytes\n");
    }


    for (ssize_t i = 0; i < bytesRead; ++i) {
        printf("%02x ", buffer[i]);
    }
    printf("\n");

    close(fd);
    return 0;
}

