	.file "On_est_la.c " 
	.text
	.globl	fact
	.type	fact, @function
fact:
	pushq	%rbp
	movq	%rsp, %rbp
	pushq	%rdi
	subq	$8, %rsp
	movq	$1, %rax
	movq	%rax, -16(%rsp)
.while1:
	movq	$0, %rax
	pushq	%rax
	movq	-8(%rsp),%rax
	popq	%rbx
	cmpq	%rax, %rbx
	je	.comp2
	movq	$0, %rax
	jmp	.suite2
.comp2:
	movq	$1, %rax
.suite2:
	cmpq	$0, %rax
	je	.if3
	movq	$0, %rax
	jmp	.suite3
.if3:
	movq	$1, %rax
.suite3:
	cmpq	$0, %rax
	je	.suite1
	subq	$0, %rsp
	movq	-8(%rsp),%rax
	pushq	%rax
	movq	-16(%rsp),%rax
	popq	%rbx
	imulq	%rbx, %rax
	movq	%rax, -16(%rsp)
	movq	-8(%rsp),%rax
	subq	$1, -8(%rsp)
	jmp	.while1
.suite1:
	movq	-16(%rsp),%rax
	leave
	ret
	leave
	ret
	.globl	main
	.type	main, @function
main:
	pushq	%rbp
	movq	%rsp, %rbp
	pushq	%rdi
	pushq	%rsi
	subq	$0, %rsp
	movq	$2, %rax
	pushq	%rax
	movq	-8(%rsp),%rax
	popq	%rbx
	cmpq	%rax, %rbx
	je	.comp4
	movq	$0, %rax
	jmp	.suite4
.comp4:
	movq	$1, %rax
.suite4:
	cmpq	$0, %rax
	je	.if5
	movq	$0, %rax
	jmp	.suite5
.if5:
	movq	$1, %rax
.suite5:
	cmpq	$0, %rax
	je	.else6
	subq	$0, %rsp
	jmp	.SF7
	.data
.SD7:
	.string	"Usage: ./fact <n>\ncalcule et affiche la factorielle de <n>.\n"
	.text
.SF7:
	movq	.SD7, %rax
	pushq	%rax
	popq	%rdi
	popq	%rsi
	movq	$0, %rax
	call	fprintf
	movslq	%eax, %rax
	movq	stderr(%rip),%rax
	pushq	%rax
	popq	%rdi
	movq	$0, %rax
	call	fflush
	movslq	%eax, %rax
	movq	$10, %rax
	pushq	%rax
	popq	%rdi
	movq	$0, %rax
	call	exit
	jmp	.suite6
.else6:
	subq	$0, %rsp
.suite6:
	subq	$16, %rsp
	movq	$1, %rax
	pushq	%rax
	movq	-16(%rsp),%rax
	popq	%rbx
	movq	(%rax, %rbx, 8), %rax
	pushq	%rax
	popq	%rdi
	movq	$0, %rax
	call	atoi
	movslq	%eax, %rax
	movq	%rax, -24(%rsp)
	movq	$0, %rax
	pushq	%rax
	movq	-24(%rsp),%rax
	popq	%rbx
	cmpq	%rax, %rbx
	jg	.comp8
	movq	$0, %rax
	jmp	.suite8
.comp8:
	movq	$1, %rax
.suite8:
	cmpq	$0, %rax
	je	.else9
	subq	$0, %rsp
	jmp	.SF10
	.data
.SD10:
	.string	"Ah non, quand meme, un nombre positif ou nul, s'il-vous-plait...\n"
	.text
.SF10:
	movq	.SD10, %rax
	pushq	%rax
	popq	%rdi
	popq	%rsi
	movq	$0, %rax
	call	fprintf
	movslq	%eax, %rax
	movq	stderr(%rip),%rax
	pushq	%rax
	popq	%rdi
	movq	$0, %rax
	call	fflush
	movslq	%eax, %rax
	movq	$10, %rax
	pushq	%rax
	popq	%rdi
	movq	$0, %rax
	call	exit
	jmp	.suite9
.else9:
	subq	$0, %rsp
.suite9:
	movq	-24(%rsp),%rax
	pushq	%rax
	popq	%rdi
	movq	$0, %rax
	call	fact
	movq	%rax, -32(%rsp)
	movq	-32(%rsp),%rax
	pushq	%rax
	popq	%rdi
	popq	%rsi
	popq	%rdx
	movq	$0, %rax
	call	printf
	movslq	%eax, %rax
	movq	$0, %rax
	leave
	ret
	leave
	ret
