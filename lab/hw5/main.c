#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>

#define THREADS 5  // liczba watkow (+2 dla watkow A i B)
pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;
pthread_cond_t cond = PTHREAD_COND_INITIALIZER;
int counter = 0;

// symulacja nieokreslonej ilosci watkow
void *thread_function(void *arg) {
    int id = *(int*)arg;
    
    // kod watku...
    
    printf("kod%d przed punktem spotkania\n", id);
    
    // kod, wpolny dla kazdego realizowanego watku
    // punkt spotkania
    pthread_mutex_lock(&mutex);
    counter++;
    if (counter < THREADS) {
        pthread_cond_wait(&cond, &mutex);
    } else {
        pthread_cond_broadcast(&cond);
    }
    pthread_mutex_unlock(&mutex);
    
    printf("kod%d po punkcie spotkania\n", id);
    
    // dalszy ciag watku...
    
    free(arg);
    return NULL;
}

void *kodA_func(void *arg) {
    printf("kodA przed punktem spotkania.\n");
    
    pthread_mutex_lock(&mutex);
    counter++;
    if (counter < THREADS) {
        pthread_cond_wait(&cond, &mutex);
    } else {
        pthread_cond_broadcast(&cond);
    }
    pthread_mutex_unlock(&mutex);
    
    printf("kodA po punkcie spotkania.\n");
    return NULL;
}

void *kodB_func(void *arg) {
    printf("kodB przed punktem spotkania.\n");
    
    pthread_mutex_lock(&mutex);
    counter++;
    if (counter < THREADS) {
        pthread_cond_wait(&cond, &mutex);
    } else {
        pthread_cond_broadcast(&cond);
    }
    pthread_mutex_unlock(&mutex);
    
    printf("kodB po punkcie spotkania.\n");
    return NULL;
}

int main(int argc, const char * argv[]) {
    pthread_t kodA, kodB;
    pthread_t threads[THREADS-2];
    
    pthread_create(&kodA, NULL, kodA_func, NULL);
    pthread_create(&kodB, NULL, kodB_func, NULL);
    for (int i = 0; i < THREADS-2; i++) {
        int *id = malloc(sizeof(int));
        *id = i;
        pthread_create(&threads[i], NULL, thread_function, id);
    }
    
    pthread_join(kodA, NULL);
    pthread_join(kodB, NULL);
    for (int i = 0; i < THREADS-2; i++) {
        pthread_join(threads[i], NULL);
    }
    
    pthread_mutex_destroy(&mutex);
    pthread_cond_destroy(&cond);
    
    return 0;
}
