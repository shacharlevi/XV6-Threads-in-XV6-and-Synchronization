#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "proc.h"
#include "defs.h"

extern struct proc proc[NPROC];

void kthreadinit(struct proc *p)
{
  initlock(&(p->alloc_lock),"aloc_thread");
  for (struct kthread *kt = p->kthread; kt < &p->kthread[NKT]; kt++)
  {
    initlock(&kt->t_lock, "thread_lock"); 
      kt->t_state = UNUSED;
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
  return c;
}

int alloctid(struct proc *p){
  int tid;
  acquire(&(p->alloc_lock));
  tid = p->p_counter;
  p->p_counter++;
  release(&(p->alloc_lock));
  return tid;
}

struct kthread* allockthread(struct proc *p){
  for (struct kthread *kt = p->kthread; kt < &p->kthread[NKT]; kt++)
    {
      acquire(&kt->t_lock);
      if(kt->t_state == UNUSED) {
        kt->tid = alloctid(p);
        kt->t_state = USED;
        // Allocate a trapframe page. if failed- return
        kt->trapframe = get_kthread_trapframe(&kt,&p);
        // Set up new context to start executing at forkret,
        // which returns to user space.
        memset(&kt->context, 0, sizeof(kt->context));
        kt->context.ra = (uint64)forkret();
        kt->context.sp = kt->kstack + PGSIZE;
        return p;
      } 
      else {
        release(&kt->t_lock);
      }
  }
}

static void
freethread(struct kthread *t){
  t->chan = 0;
  t->t_killed = 0;
  t->t_xstate = 0;
  t->t_state = UNUSED;
  t->tid=0;
  t->process=0;
  t->kstack=0;
  if(t->trapframe)
    kfree((void*)t->trapframe);
  t->trapframe = 0;
  memset(&t->context,0,sizeof(&t->context));
  release(&t->t_lock);
}


struct trapframe *get_kthread_trapframe(struct proc *p, struct kthread *kt)
{
  return p->base_trapframes + ((int)(kt - p->kthread));
}

