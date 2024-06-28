#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <unistd.h>

#define N 10

pthread_t w[N];
int d[N];

int licznik = 0;

void *f(void *arg) {
	int X = *(int *)arg;
	//printf("Watek numer %d\n", X);
	//sleep(1);
	for (int i = 0; i<X; i++) {
		pthread_mutex_lock(&zamek);
		licznik++;
		pthread_mutex_unlock(&zamek);
	}
	pthread_exit(NULL);
}

int main() {
	for(int i=0; i<N; i++) {
		d[i] = 1000;
		pthread_create(w+i, NULL, f, (void *)(d+i));
	}
	printf("Watki utworzone\n");
	for(int i = 0; i<N; i++) {
		pthread_join(w[i], NULL);
	}
	printf("Watki utworzone\n");
	exit(0);
}
