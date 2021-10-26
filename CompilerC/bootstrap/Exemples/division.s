	.file "On_est_la.c " 
	.text
	.globl	main
	.type	main, @function
main:
	pushq	%rbp
	movq	%rsp, %rbp
	pushq	%rdi
	subq	$0, %rsp
	movq	$3, %rax
	movq	%rax, %rbx
	movq	$4, %rax
	cqto
	idivq	%rbx
	movq	%rax, %rax
	leave
	ret
	addq	$0, %rsp
	leave
	ret
