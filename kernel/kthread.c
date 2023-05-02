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
  
  for (struct kthread *kt = p->kthread; kt < &p->kthread[NKT]; kt++)
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
  t->chan = 0;//
  t->t_killed = 0;//
  t->t_xstate = 0;//
  t->t_state = UNUSED_t;//
  t->tid=0;//
  t->process=0;//
  // t->kstack=0;
  // if(t->trapframe)
  //   kfree((void*)t->trapframe);
  t->trapframe = 0;//
  memset(&t->context,0,sizeof(&t->context));//
  release(&t->t_lock);
}

 
// void freethread(struct kthread* k){
//   if (k == 0)
//       return;
      
//   // acquire(&k->t_lock);
//   k->trapframe = 0;
//   k->t_state = UNUSED_t;
//   k->chan = 0;
//   k->t_killed = 0;
//   k->t_xstate = 0;
//   k->tid = 0;
//   // release(&k->t_lock);
// }


