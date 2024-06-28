#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdio.h>

int main (int argc, char *argv[]) {
	if (argc != 3) {
		printf("Bad arguments amount: copy file1 file2\n");
		return 1;
	}	


	int to_copy = open(argv[1], O_RDONLY);
	if (to_copy == -1) {
		printf("Error with opening file: %s\n", argv[1]);
		return 1;
	}

	if (to_copy != -1) {
		int write_copied = open(argv[2], O_WRONLY | O_CREAT | O_EXCL, 0644);
		if (write_copied == -1) {
			printf("File exists, do you want to overwrite it? (y/n)");
			char symbol;
			scanf("%c", &symbol);
			if (symbol == 'y') write_copied = open(argv[2], O_WRONLY | O_TRUNC);
			else {
				printf("Your file was not overwritten\n");
				return 0;
			}
		} 
		
		size_t bytes_read, bytes_write = 0;
		char buff[100];
		
		bytes_read = read(to_copy, buff, 100);
		
		while (bytes_read >= 100 || (bytes_write != -1)) {
			write(write_copied, buff, 100);
			bytes_read = read(to_copy, buff, 100);
		}
		if (bytes_read == -1) {
			printf("Error reading\n");
			return 1;
		}		
		bytes_write = write(write_copied, buff, bytes_read);
		if (bytes_write == -1) {
			printf("Error writing");
			return 1;
		}

		write(write_copied, buff, bytes_read);

		close(write_copied);
		close(to_copy);
		return 0;
	}
	return 1;
}
