	.file "On_est_la.c " 
	.text
	.align 16
	.comm	x, 8, 8
	.globl	main
	.type	main, @function
main:
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$0, %rsp
	movq	$2, %rax
	movq	%rax, x(%rip)
	movq	x(%rip),%rax
	pushq	%rax
	jmp	.SF1
	.section	.rodata
.SD1:
	.string	"%d"
	.section	.text
.SF1:
	leaq	.SD1(%rip), %rax
	pushq	%rax
	popq	%rdi
	popq	%rsi
	movq	$0, %rax
	call	printf
	movslq	%eax, %rax
	leave
	ret
