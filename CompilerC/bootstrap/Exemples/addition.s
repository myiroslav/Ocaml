	.file "On_est_la.c " 
	.text
	.globl	main
	.type	main, @function
main:
	pushq	%rbp
	movq	%rsp, %rbp
	pushq	%rdi
	subq	$0, %rsp
	movq	$2, %rax
	pushq	%rax
	movq	$1, %rax
	popq	%rbx
	addq	%rbx, %rax
	leave
	ret
	addq	$0, %rsp
	leave
	ret
