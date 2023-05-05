#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "proc.h"
#include "defs.h"

extern struct proc proc[NPROC];
extern void forkret(void);


void kthreadinit(struct proc *p)
{
  initlock(&(p->alloc_lock),"aloc_thread");
  for (struct kthread *kt = p->kthread; kt < &p->kthread[NKT]; kt++)
  {
    initlock(&kt->t_lock, "thread_lock"); 
      kt->t_state = UNUSED_t;
      kt->process=p;
    // WARNING: Don't change this line!
    // get the pointer to the kernel stack of the kthread
    kt->kstack = KSTACK((int)((p - proc) * NKT + (kt - p->kthread)));
  }
}

struct kthread *mykthread()
{
  push_off();
  struct cpu *c = mycpu();
  struct kthread *kthread = c->kthread;
  pop_off();
  return kthread;
}

int alloctid(struct proc *p){
  int tid;
  acquire(&(p->alloc_lock));
  tid = p->p_counter;
  p->p_counter++;
  release(&(p->alloc_lock));
  return tid;
}

struct trapframe *get_kthread_trapframe(struct proc *p, struct kthread *kt)
{
  return p->base_trapframes + ((int)(kt - p->kthread));
}

struct kthread* allockthread(struct proc *p){
  struct kthread *kt;
  for (kt = p->kthread; kt < &p->kthread[NKT]; kt++)
    {
      acquire(&kt->t_lock);
      if(kt->t_state == UNUSED_t) {
        kt->tid = alloctid(p);
        kt->t_state = USED_t;
        kt->process=p;
        // Allocate a trapframe page. if failed- return
        kt->trapframe = get_kthread_trapframe(p,kt);
        // Set up new context to start executing at forkret,
        // which returns to user space.
        memset(&kt->context, 0, sizeof(kt->context));   
        kt->context.ra = (uint64)forkret;
        kt->context.sp = kt->kstack + PGSIZE;

        return kt;
      } 
      else {
        release(&kt->t_lock);
      }
  }
  return 0;
}

void
freethread(struct kthread *t){
  t->chan = 0;
  t->t_killed = 0;
  t->t_xstate = 0;
  t->t_state = UNUSED_t;
  t->tid=0;
  t->process=0;
  t->trapframe = 0;
  memset(&t->context,0,sizeof(&t->context));
  release(&t->t_lock);
}


// find UNUSED thread from the calling proc 
// set state to runnable , alloc stack(malloc)-4000 bytes(macro),
//set epc to start_func,sp to top of the stack
// return tid or -1 if no UNUSED thread found
int kthread_create(void *(*start_func)(), void *stack, uint stack_size){
  //struct proc* p = myproc();
  struct kthread *t = allockthread(myproc());
  //printf("pid in kthread_create: %d\n",t->tid);
  // *t = allockthread(p);
  if(t == 0){
   // printf("in kthread created:%d",t->tid);
    return -1;
  }
  t->trapframe->epc = (uint64)start_func;
  t->trapframe->sp = (uint64)(stack + stack_size);
  t->t_state = RUNNABLE_t;
  release(&t->t_lock);
  return t->tid;
}



int kthread_kill(int ktid){
  struct proc *p = myproc();
  struct kthread *kt;

  for(kt = p->kthread; kt < &p->kthread[NKT]; kt++){
    acquire(&kt->t_lock);
    if(kt->tid == ktid){
      kt->t_killed = 1;
      if(kt->t_state == SLEEPING_t){
        // Wake thread from sleep().
        kt->t_state = RUNNABLE_t;
      }
      release(&kt->t_lock);
      return 0;
    }
    release(&kt->t_lock);
  }
  return -1;
}


int
t_killed(struct kthread *t)
{
  int k;
  acquire(&t->t_lock);
  k = t->t_killed;
  release(&t->t_lock);
  return k;
}



//checks if kt  is the last thread of its process p.
//The function returns 1 if kt is the last thread and 0 otherwise.
int
if_last_thread(struct kthread *kt){
  struct kthread* t;
  struct proc *p = myproc();
  for(t = p->kthread; t < &p->kthread[NKT]; t++){
    if(t != kt){
      acquire(&t->t_lock);
      if(t->t_state != UNUSED_t && t->t_state != ZOMBIE_t){
        release(&t->t_lock);
        return 0;
      }
      release(&t->t_lock);
    }
  }
  return 1;
}

void
kthread_exit(int status){
  struct proc *p = myproc();
  struct kthread *t = mykthread();

  if(if_last_thread(t)){
    exit(status);
  }
  
  acquire(&t->t_lock);
  t->t_state = ZOMBIE_t;
  t->t_xstate = status;
  release(&t->t_lock);
  
  acquire(&p->lock); 
  wakeup(t);
  release(&p->lock);
  
  acquire(&t->t_lock);
  sched();
  panic("zombie exit");
}

int 
kthread_join(int ktid, int *status){
  struct kthread *t_search;
  struct kthread *t_by_ktid=0;
  struct proc *p = myproc();
  for(t_search = p->kthread; t_search < &p->kthread[NKT]; t_search++) {
    acquire(&t_search->t_lock);
    if (t_search->tid==ktid){
      t_by_ktid=t_search;
    }
    release(&t_search->t_lock);
 }
  if(t_by_ktid== 0){
      return -1;
  }

  acquire(&p->lock);
  for(;;){
    if(t_by_ktid->t_state == ZOMBIE_t){
      acquire(&t_by_ktid->t_lock);
      if(status != 0 && copyout(t_by_ktid->process->pagetable, (uint64) status, (char *)&t_by_ktid->t_xstate,
                                          sizeof(t_by_ktid->t_xstate)) < 0) {
        release(&t_by_ktid->t_lock);
        release(&p->lock);
        return -1;
      }

      freethread(t_by_ktid);
      release(&p->lock);
      return 0;
    }

    sleep(t_by_ktid, &p->lock);
  }
}




