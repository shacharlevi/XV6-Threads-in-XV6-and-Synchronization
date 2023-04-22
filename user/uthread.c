#include "uthread.h"
#include <stdio.h>
static int next_tid = 0; // initialize thread ID counter
struct uthread uthreads_arr[MAX_UTHREADS];
struct uthread *curr_thread;

int uthread_create(void (*start_func)(), enum sched_priority priority) {
    int i;
    
    // Find a free thread entry in the table
    for (i = 0; i < MAX_UTHREADS; i++) {
        if (uthreads_arr[i].state == FREE) {
            curr_thread = &uthreads_arr[i];
            break;
        }
    }

    // If no free entry is found, return -1
    if (i >= MAX_UTHREADS) {
        return -1;
    }

    // Initialize the thread's fields
    curr_thread->id = next_tid++; 
    curr_thread->priority = priority;
    curr_thread->context.ra = (uint64) start_func;
    curr_thread->context.sp = (uint64) &curr_thread->ustack[STACK_SIZE];
    curr_thread->ustack[STACK_SIZE - 1] = (uint64) uthread_exit; // Return address to uthread_exit
    curr_thread->state = RUNNABLE;
 printf("Created thread with ID: %d and prior:%d\n", curr_thread->id,curr_thread->priority);
     return 0;
}

// void uthread_yield(){
//     struct uthread *next;
//     // intr_on();
//     struct uthread *next_thread=curr_thread;
//     enum sched_priority highest=curr_thread->priority;
//     for(next=uthreads_arr; next< &uthreads_arr[MAX_UTHREADS]; next++){
//         if(next->state==RUNNABLE && next->priority>=highest){
//             highest=next->priority;
//             next_thread=next;
//         }
//     }
//         // printf("111");
//     if(next_thread !=curr_thread){
//             curr_thread->state=RUNNABLE;
//             next_thread->state=RUNNING;
//             uswtch(&curr_thread->context, &next_thread->context);
//     }
//     //    printf("222");

// }

void uthread_yield() {
    // Find the highest priority RUNNABLE thread
    struct uthread *next_thread = NULL;
    enum sched_priority max_priority = LOW;
    int count=0;
    for (int i = curr_thread->id+1; count<MAX_UTHREADS; count++, i=(i+1)%MAX_UTHREADS) {
        if (uthreads_arr[i].state == RUNNABLE &&
            uthreads_arr[i].priority > max_priority) {
            next_thread = &uthreads_arr[i];
            max_priority = uthreads_arr[i].priority;
        }
    }
     printf("before switch thread with ID: %d and prior:%d\n", curr_thread->id,curr_thread->priority);

    // If no runnable threads are found, return to the current thread
    if (next_thread == NULL) {
        return;
    }

    // Save the current thread's context and switch to the next thread's context
    struct context *curr_context = &curr_thread->context;
    struct context *next_context = &next_thread->context;
    curr_thread->state = RUNNABLE;
    next_thread->state = RUNNING;
    curr_thread = next_thread;
    uswtch(curr_context, next_context);
         printf("after switch thread with ID: %d and prior:%d\n", curr_thread->id,curr_thread->priority);

}

void uthread_exit(){

}