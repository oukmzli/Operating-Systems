#include <fcntl.h>
#include <unistd.h>
#include <stdio.h>

void compare_files(const char *file1, const char *file2) {
    int fd1, fd2;
    fd1 = open(file1, O_RDONLY);
    fd2 = open(file2, O_RDONLY);

    if (fd1 < 0 || fd2 < 0) {
        perror("Blad otwarcia plikow");
        return;
    }

    char c1, c2;
    int pos = 1;
    int start_diff = 0;
    char buff1[4096], buff2[4096];
    int index1 = 0, index2 = 0;

    while ((read(fd1, &c1, 1) == 1) && (read(fd2, &c2, 1) == 1)) {
        if (c1 != c2) {
            if (start_diff == 0) {
                start_diff = pos;
            }
            buff1[index1++] = c1;
            buff2[index2++] = c2;
        } else {
            if (start_diff != 0) {
                buff1[index1] = '\0'; buff2[index2] = '\0';
                if (start_diff == pos-1)
                    printf("Pliki różnią się na pozycji %d\n", start_diff);
                else
                    printf("Pliki różnią się na pozycjach %d-%d\n", start_diff, pos-1);
                printf("%s: %s\n", file1, buff1);
                printf("%s: %s\n", file2, buff2);
                start_diff = 0;
                index1 = 0; index2 = 0;
            }
        }
        pos++;
    }

    if (start_diff != 0) {
        buff1[index1] = '\0'; buff2[index2] = '\0';
        if (start_diff == pos-1)
            printf("Pliki różnią się na pozycji %d\n", start_diff);
        else
            printf("Pliki różnią się na pozycjach %d-%d\n", start_diff, pos - 1);
        printf("%s: %s\n", file1, buff1);
        printf("%s: %s\n", file2, buff2);
    }

    close(fd1);
    close(fd2);
}

int main(int argc, char *argv[]) {
    if (argc < 3) {
        fprintf(stderr, "argv: %s <file1> <file2>\n", argv[0]);
        return 1;
    }
    compare_files(argv[1], argv[2]);
    return 0;
}
    
