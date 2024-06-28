#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/stat.h>

int exit_flag = 1;

void *read_fifo(void *arg) {
    char *fifo_path = (char*) arg;
    int fd = open(fifo_path, O_RDONLY | O_NONBLOCK);
    if (fd < 0) {
        fprintf(stderr, "error opening %s for reading\n", fifo_path);
        return NULL;
    }
    printf("opened %s for reading\n", fifo_path);
    
    char buffer[1000];
    ssize_t num_bytes;
    while (exit_flag) {
        num_bytes = read(fd, buffer, sizeof(buffer) - 1);
        if (num_bytes > 0) {
            buffer[num_bytes] = '\0';
            buffer[strcspn(buffer, "\n")] = 0;
            printf("%s\n", buffer);
            
            if (strcmp(buffer, "exit") == 0) {
                exit_flag = 0;
                printf("exiting, enter any symbol to exit\n");
                break;
            }
        } else if (num_bytes == 0) {
            sleep(1);
        }
    }
    close(fd);
    return NULL;
}

void *write_fifo(void *arg) {
    char *fifo_path = (char*) arg;
    int fd = open(fifo_path, O_WRONLY);
    if (fd < 0) {
        fprintf(stderr, "error opening %s for writing\n", fifo_path);
        return NULL;
    }
    printf("opened %s for writing\n", fifo_path);
    
    char buffer[1000];
    printf("ready to send, type 'exit' to quit\n");
    
    while (fgets(buffer, sizeof(buffer), stdin) != NULL) {
        if (!exit_flag) break;
        
        buffer[strcspn(buffer, "\n")] = 0;
        if (write(fd, buffer, strlen(buffer)) < 0) {
            fprintf(stderr, "write error %s\n", fifo_path);
            break;
        }
        if (strcmp(buffer, "exit") == 0) {
            exit_flag = 0;
            break;
        }
    }
    close(fd);
    return NULL;
}

int main(int argc, char *argv[]) {
    if (argc != 3) {
        fprintf(stderr, "argv: %s <read_fifo> <write_fifo>\n", argv[0]);
        return 1;
    }
    
    const char *read_fifo_path = argv[1];
    const char *write_fifo_path = argv[2];
    mkfifo(read_fifo_path, 0666);
    mkfifo(write_fifo_path, 0666);
    
    pthread_t read_thread, write_thread;
    pthread_create(&read_thread, NULL, read_fifo, (void *)read_fifo_path);
    pthread_create(&write_thread, NULL, write_fifo, (void *)write_fifo_path);
    pthread_join(read_thread, NULL);
    pthread_join(write_thread, NULL);
    
    unlink(read_fifo_path);
    unlink(write_fifo_path);
    return 0;
}
