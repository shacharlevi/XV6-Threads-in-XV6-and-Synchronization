#include <stdio.h>
#include "uthread.h"

void thread1() {
    printf("This is thread 1\n");
}

void thread2() {
    printf("This is thread 2\n");
}

int main() {
    int t1 = uthread_create(thread1, LOW);
    int t2 = uthread_create(thread2, HIGH);
    if (t1 < 0 || t2 < 0) {
        printf("Error: failed to create user threads\n");
        return 1;
    }
    uthread_yield();
    printf("Switched to thread 1\n");
    uthread_yield();
    printf("Switched to thread 2\n");
     uthread_yield();
    printf("Switched back to thread 1\n");
    uthread_exit();
    uthread_yield();
    printf("Switched to thread 2\n");
    uthread_exit();
    if (uthread_create(thread1, HIGH) >= 0 || uthread_create(thread2,LOW) >= 0) {
        printf("Error: user threads were not properly terminated\n");
        return 1;
    }
    printf("All user threads terminated successfully\n");
    return 0;
}
