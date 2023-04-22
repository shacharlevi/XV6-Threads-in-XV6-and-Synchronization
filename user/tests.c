
#include "uthread.h"
#include "kernel/types.h"
#include "user/user.h"
void* thread_func(void* arg) {
    int* arg_ptr = (int*) arg;
    int arg_val = *arg_ptr;
    printf("Thread %d started\n", arg_val);
    // uthread_exit();
    // printf("Thread %d resumed\n", arg_val);
    return (void*) 0;

}

int main() {
    int arg1 = 1;
    int arg2 = 2;
    if (uthread_create((void (*)()) thread_func, arg1) == -1 ||
        uthread_create((void (*)()) thread_func, arg2) == -1) {
        printf("Error creating thread\n");
        exit(1);
    }
    uthread_start_all();
    printf("Main thread resumed\n");
    return 0;
}