.intel_syntax noprefix

.global exit
.global print
.global print_num
.global parse_num
.global str_len
.global alloc_mem
.global free_mem

exit: #(int exit_code)
	mov rax, 60 # SYS_exit
	syscall

print: #(char *message, long length)
	mov rdx, rsi # length
	mov rsi, rdi # message
	mov rdi, 1 # stdout
	mov rax, 1 # SYS_write
	syscall
	ret

print_num: #(unsigned long num, bool new_line)
	enter 32, 0
	mov rax, rdi

	# rsi = 1 if new_line, 0 otherwise
	# this \n byte will be overwritten by the first digit if new_line is false
	mov byte ptr [rbp], '\n'
	neg rsi

	.loop_print_num:
		# rax = rdx = rdi / 10
		movabs rdx, 0xCCCCCCCCCCCCCCCD
		mul rdx
		shr rdx, 3
		mov rax, rdx

		# rdx = rax * 10
		lea rdx, [rdx + rdx * 4]
		add rdx, rdx

		# rdi = rdi % 10
		sub rdi, rdx

		# rdi = rdi to ascii and prepended to string
		add rdi, '0'
		mov byte ptr [rbp + rsi], dil
		dec rsi

		# rdi = rax and loop if rax != 0
		mov rdi, rax
		cmp rax, 0
		jne .loop_print_num

	mov rdi, rbp
	add rdi, rsi
	inc rdi
	neg rsi
	call print

	leave
	ret

parse_num: #(char *str) -> unsigned long
	xor eax, eax
	mov rdx, -1
	xor ecx, ecx

	.loop_parse_num:
		inc rdx

		# return at null terminator
		cmp byte ptr [rdi + rdx], 0
		je .end_parse_num

		# return at non-digit characters
		cmp byte ptr [rdi + rdx], '0'
		jl .end_parse_num
		cmp byte ptr [rdi + rdx], '9'
		jg .end_parse_num
		
		# rax = rax * 10
		lea rax, [rax + rax * 4]
		add rax, rax

		# rax = rax + digit
		mov cl, [rdi + rdx]
		add rax, rcx
		sub rax, '0'

		# loop
		jmp .loop_parse_num

	.end_parse_num:
		ret

str_len: #(char *str) -> unsigned long
	xor eax, eax
	
	.loop_str_len:
		# increment length (rax) if not null terminator
		cmp byte ptr [rdi + rax], 0
		je .end_str_len
		inc rax
		jmp .loop_str_len

	.end_str_len:
		ret

alloc_mem: #(unsigned long size) -> void *
	mov rax, 9 # SYS_mmap
	mov rsi, rdi # size
	xor edi, edi # addr
	mov rdx, 3 # PROT_READ | PROT_WRITE
	mov r10, 34 # MAP_PRIVATE | MAP_ANONYMOUS
	mov r8, -1 # fd
	mov r9, 0 # offset
	syscall
	ret

free_mem: #(void *addr, unsigned long size) -> void
	mov rax, 11 # SYS_munmap
	mov rdi, rdi # addr
	mov rsi, rsi # size
	syscall
	ret
