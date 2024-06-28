#include <unistd.h>
#include <stdio.h>
int main(int argc, char *argv[])
{
    int i = 715;
    if (fork() == 0) {
        // proces potomny
        printf("PID1 %I\n", getpid());
    } else {
        // proces macierzysty
        printf("PIDO:%I\n", getpid());
    }
    // wspolne dla obu procesow
    return 0;
}