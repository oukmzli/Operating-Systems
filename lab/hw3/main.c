#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/wait.h>
#include <unistd.h>

#define MAX_CMDS 3
#define MAX_ARGS 10

char* trim(char* s) {
    while (isspace((unsigned char)*s)) s++;
    if (*s == 0) return s;

    char* end = s + strlen(s) - 1;
    while (end > s && isspace((unsigned char)*end)) end--;
    *(end + 1) = '\0';

    return s;
}

int parse(char* s, char* cmds[MAX_CMDS][MAX_ARGS]) {
    int cmdCnt = 0, argCnt = 0;

    while (*s != '\0' && cmdCnt < MAX_CMDS) {
        if (*s == '|') {
            if (argCnt > 0) {
                cmds[cmdCnt][argCnt] = NULL;
                cmdCnt++;
                argCnt = 0;
            }
            s++;
            continue;
        }

        while (*s == ' ' || *s == '\n') s++;

        char* start = s;

        while (*s != '\0' && *s != ' ' && *s != '|' && *s != '\n') s++;

        if (start < s) {
            cmds[cmdCnt][argCnt++] = trim(start);
            if (*s == ' ' || *s == '\n') {
                *s = '\0';
                s++;
            }
        }
    }

    if (argCnt > 0) {
        cmds[cmdCnt][argCnt] = NULL;
        cmdCnt++;
    }

    return cmdCnt;
}

void exec(char* cmd[], int inFD, int outFD) {
    if (fork() == 0) {
        if (inFD != STDIN_FILENO) {
            dup2(inFD, STDIN_FILENO);
            close(inFD);
        }
        if (outFD != STDOUT_FILENO) {
            dup2(outFD, STDOUT_FILENO);
            close(outFD);
        }
        execvp(cmd[0], cmd);
        perror("execvp");
        exit(EXIT_FAILURE);
    }
}

int main() {
    char buf[1024];
    char* cmds[MAX_CMDS][MAX_ARGS];

    printf("enter commands sequention with | (ls -l | tr a-z A-Z | cut -f1 -d ' ')\n");
    if (fgets(buf, sizeof(buf), stdin) == NULL) {
        perror("fgets");
        return EXIT_FAILURE;
    }

    int cmdCount = parse(buf, cmds);
    int fds[2], inFD = STDIN_FILENO;

    for (int i = 0; i < cmdCount; i++) {
        if (i < cmdCount - 1) {
            pipe(fds);
            exec(cmds[i], inFD, fds[1]);
            if (inFD != STDIN_FILENO) close(inFD);
            inFD = fds[0];
            close(fds[1]);
        }
        else {
            exec(cmds[i], inFD, STDOUT_FILENO);
            if (inFD != STDIN_FILENO) close(inFD);
        }
    }
    while (wait(NULL) > 0);

    return 0;
}
