#include "uthread.h"
#include "kernel/types.h"
#include "user/user.h"


// static int next_tid = 0; // initialize thread ID counter
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
    curr_thread->id = i; 
    curr_thread->priority = priority;
    curr_thread->context.ra = (uint64) start_func;
    curr_thread->context.sp = (uint64) &curr_thread->ustack[STACK_SIZE];
    curr_thread->ustack[STACK_SIZE - 1] = (uint64) uthread_exit; // Return address to uthread_exit
    curr_thread->state = RUNNABLE;
     return 0;
}

void uthread_yield() {
    // Find the highest priority RUNNABLE thread
    struct uthread *next_thread = (struct uthread *) 1;
    enum sched_priority max_priority = LOW;
    int count=0;
    for (int i = curr_thread->id+1; count<MAX_UTHREADS; count++, i=(i+1)%MAX_UTHREADS) {
        if (uthreads_arr[i].state == RUNNABLE &&
            uthreads_arr[i].priority > max_priority) {
            next_thread = &uthreads_arr[i];
            max_priority = uthreads_arr[i].priority;
        }
    }

    // If no runnable threads are found, return to the current thread
    if (next_thread == (struct uthread *) 1) {
        return;
    }

    // Save the current thread's context and switch to the next thread's context
    struct context *curr_context = &curr_thread->context;
    struct context *next_context = &next_thread->context;
    curr_thread->state = RUNNABLE;
    next_thread->state = RUNNING;
    curr_thread = next_thread;
    uswtch(curr_context, next_context);

}

void uthread_exit(){
    // Change the state of the current thread to FREE
    curr_thread->state = FREE;
    // Find another runnable thread to switch to (make sure its not the current_thread)
    struct uthread *next_thread = (struct uthread *) 1;
    enum sched_priority max_priority = LOW;
    int count=0;
    for (int i = curr_thread->id+1; count<MAX_UTHREADS;  count++,i=(i+1)%MAX_UTHREADS) {
         
        if (uthreads_arr[i].state == RUNNABLE &&
            uthreads_arr[i].priority > max_priority) {
            next_thread = &uthreads_arr[i];
            max_priority = uthreads_arr[i].priority;
        }
    }
    if (next_thread == (struct uthread *) 1) {
        exit(0);  // Exit the process if there are no more runnable threads
    }
    // Switch to the next thread
    struct context *curr_context = &curr_thread->context;
    struct context *next_context = &next_thread->context;
    next_thread->state = RUNNING;
    curr_thread = next_thread;
    uswtch(curr_context, next_context);
}

enum sched_priority uthread_set_priority(enum sched_priority priority){
    enum sched_priority to_return =curr_thread->priority;
    curr_thread->priority=priority;
    return to_return;
}

enum sched_priority uthread_get_priority(){
    return curr_thread->priority;
}