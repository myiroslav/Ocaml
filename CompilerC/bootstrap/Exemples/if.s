	.file "On_est_la.c " 
	.text
	.globl	main
	.type	main, @function
main:
	pushq	%rbp
	movq	%rsp, %rbp
	pushq	%rdi
	subq	$0, %rsp
	movq	$1, %rax
	pushq	%rax
	movq	$2, %rax
	popq	%rbx
	cmpq	%rax, %rbx
	jg	.comp1
	movq	$0, %rax
	jmp	.suite1
.comp1:
	movq	$1, %rax
.suite1:
	cmpq	$0, %rax
	je	.else2
	subq	$0, %rsp
	movq	$2, %rax
	pushq	%rax
	movq	$1, %rax
	popq	%rbx
	addq	%rbx, %rax
	leave
	ret
	addq	$0, %rsp
	jmp	.suite2
.else2:
	subq	$0, %rsp
	addq	$0, %rsp
.suite2:
	movq	$3, %rax
	pushq	%rax
	movq	$2, %rax
	popq	%rbx
	imulq	%rbx, %rax
	leave
	ret
	addq	$0, %rsp
	leave
	ret
