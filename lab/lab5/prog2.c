#include <unistd.h>
#include <stdio.h>

int main(int argc, char *argv[]) {
    int status; pid_t pid_ls, pid_cat;

    if ((pid_ls = fork()) == 0) {
        execlp("ls", "ls", NULL);
    }
    if ((pid_cat = fork()) == 0) {
        execlp("cat", "cat", "file.txt", NULL);
    }
    
    waitpid(pid_ls, &status, 0);
    printf("Result of %i\n", status);
    waitpid(pid_cat, &status, 0);
    printf("Result of %i\n", status);

    return 0;
}