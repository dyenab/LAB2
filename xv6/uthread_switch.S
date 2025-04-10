	.text

	/*
         * save the old thread's registers,
         * restore the new thread's registers.
         */

	.globl thread_switch

	pushal				//current thread 저장
	
	movl current_thread, %eax	//Load addr of current thread
  movl %esp, (%eax)		// save esp reg in sp of thread
		
	movl next_thread, %eax		//load addr of nextthread
	movl (%eax), %esp		//load sp of thread in esp reg

	movl %eax, current_thread	//next thread -> current thread

	movl $0x0, next_thread		//next_thread = 0

	popal				//restore reg from stack

	ret    /* return to ra */