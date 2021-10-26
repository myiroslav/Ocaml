	.file	"fact.c"
	.text
	.globl	fact
	.type	fact, @function
fact:
	pushq	%rbp
	movq	%rsp, %rbp
	movl	%edi, -20(%rbp)
	movl	$1, -4(%rbp)
	jmp	.L2
.L3:
	movl	-4(%rbp), %eax
	imull	-20(%rbp), %eax
	movl	%eax, -4(%rbp)
	subl	$1, -20(%rbp)
.L2:
	cmpl	$0, -20(%rbp)
	jne	.L3
	movl	-4(%rbp), %eax
	popq	%rbp
	ret
	.size	fact, .-fact
	.section	.rodata
	.align 8
.LC0:
	.string	"Usage: ./fact <n>\ncalcule et affiche la factorielle de <n>.\n"
	.align 8
.LC1:
	.string	"Ah non, quand meme, un nombre positif ou nul, s'il-vous-plait...\n"
	.align 8
.LC2:
	.string	"La factorielle de %d vaut %d (en tout cas, modulo 2^32...).\n"
	.text
	.globl	main
	.type	main, @function
main:
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$32, %rsp
	movl	%edi, -20(%rbp)
	movq	%rsi, -32(%rbp)
	cmpl	$2, -20(%rbp)
	je	.L6
	movq	stderr(%rip), %rax
	movq	%rax, %rcx
	movl	$60, %edx
	movl	$1, %esi
	leaq	.LC0(%rip), %rdi
	call	fwrite@PLT
	movq	stderr(%rip), %rax
	movq	%rax, %rdi
	call	fflush@PLT
	movl	$10, %edi
	call	exit@PLT
.L6:
	movq	-32(%rbp), %rax
	addq	$8, %rax
	movq	(%rax), %rax
	movq	%rax, %rdi
	call	atoi@PLT
	movl	%eax, -8(%rbp)
	cmpl	$0, -8(%rbp)
	jns	.L7
	movq	stderr(%rip), %rax
	movq	%rax, %rcx
	movl	$65, %edx
	movl	$1, %esi
	leaq	.LC1(%rip), %rdi
	call	fwrite@PLT
	movq	stderr(%rip), %rax
	movq	%rax, %rdi
	call	fflush@PLT
	movl	$10, %edi
	call	exit@PLT
.L7:
	movl	-8(%rbp), %eax
	movl	%eax, %edi
	call	fact
	movl	%eax, -4(%rbp)
	movl	-4(%rbp), %edx
	movl	-8(%rbp), %eax
	movl	%eax, %esi
	leaq	.LC2(%rip), %rdi
	movl	$0, %eax
	call	printf@PLT
	movl	$0, %eax
	leave
	ret
	.size	main, .-main
	.ident	"GCC: (Ubuntu 7.4.0-1ubuntu1~18.04.1) 7.4.0"
	.section	.note.GNU-stack,"",@progbits
