.global _start
.intel_syntax noprefix

.section .text

_start:
	# rdi = argc
	# Requires at least 2 arguments
	pop rdi
	cmp rdi, 1
	jle exit_no_args

	# rdi = argv[1]
	# Parse for upper_bound
	pop rdi
	pop rdi
	call parse_num
	mov r12, rax

	# Print message
	lea rdi, [msg1]
	mov rsi, msg1_len
	call print

	# Print upper_bound
	mov rdi, r12
	xor esi, esi
	call print_num

	# Print message
	lea rdi, [msg2]
	mov rsi, msg2_len
	call print

	# Call sieve
	mov rdi, r12
	call sieve

	# exit(0)
	xor edi, edi
	call exit

sieve: # (long upper_bound)
	# Allocate memory for sieve
	# 1 bit per odd number
	mov r12, rdi
	shr rdi, 4
	inc rdi
	mov r15, rdi
	call alloc_mem

	cmp rax, 0
	jle alloc_failed

	# r14 = rax = memory address
	mov r14, rax

	# Only iterate up to the square root of the upper bound
	cvtsi2sd xmm0, r12
	sqrtsd xmm0, xmm0
	cvttsd2si r13, xmm0
	
	mov r8, 3
	.loop_sieve:
		# Exit loop if sqrt(upper_bound) is exceeded
		cmp r8, r13
		jg .loop_sieve_break

		# Check if number in r8 is prime
		# r10 is the byte index
		# rcx is the bit index
		# r11 is the bit mask
		mov r10, r8
		shr r10, 1
		mov rcx, r10
		shr r10, 3
		and rcx, 0x7
		mov r11b, 1
		shl r11b, cl

		mov sil, [r14 + r10]
		test sil, r11b
		jnz .loop_sieve_continue

		# Mark all multiples of r8 as not prime
		# rdx = r8 * 2
		# r9 = r8 * r8
		mov r9, r8
		imul r9, r9
		mov rdx, r8
		add rdx, rdx

		.loop_mark_sieve:
			# Exit loop if upper_bound is exceeded

			cmp r9, r12
			jg .loop_sieve_continue

			# r10 is the byte index
			# rcx is the bit index
			# r11 is the bit mask
			mov r10, r9
			shr r10, 1
			mov rcx, r10
			shr r10, 3
			and rcx, 0x7
			mov r11b, 1
			shl r11b, cl

			# Mark number as not prime
			mov sil, [r14 + r10]
			or sil, r11b
			mov [r14 + r10], sil

			add r9, rdx
			jmp .loop_mark_sieve

		.loop_sieve_continue:
			add r8, 2
			jmp .loop_sieve

	.loop_sieve_break:

	cmp r12, 2
	jl .end_sieve

	# 2 is prime but not odd
	mov rdi, 2
	mov rsi, 1
	call print_num

	mov r8, 3
	.loop_print_sieve:
		# Exit loop if upper_bound is exceeded
		cmp r8, r12
		jg .end_sieve

		# Check if number in r8 is prime
		# r10 is the byte index
		# rcx is the bit index
		# r11 is the bit mask
		mov r10, r8
		shr r10, 1
		mov rcx, r10
		shr r10, 3
		and rcx, 0x7
		mov r11b, 1
		shl r11b, cl

		mov sil, [r14 + r10]
		test sil, r11b
		jnz .loop_print_sieve_continue

		mov rdi, r8
		mov rsi, 1
		call print_num

		.loop_print_sieve_continue:
			add r8, 2
			jmp .loop_print_sieve

	.end_sieve:
		# Free memory
		mov rdi, r14
		mov rsi, r15
		call free_mem

		ret

alloc_failed:
	lea rdi, [alloc_failed_msg]
	mov rsi, alloc_failed_msg_len
	call print
	mov rdi, 1
	call exit

exit_no_args:
	# print(usage1, usage1_len)
	lea rdi, [usage1]
	mov rsi, usage1_len
	call print

	# print program name (pointer is on stack)
	pop rdi
	call str_len
	mov rsi, rax
	call print

	# print(usage2, usage2_len)
	lea rdi, [usage2]
	mov rsi, usage2_len
	call print

	# exit(1)
	mov edi, 1
	call exit

.section .data
usage1:
	.asciz "Usage: "
usage1_len: 
	.quad 7

usage2:
	.asciz " <upper_bound>\n"
usage2_len:
	.quad 15

msg1:
	.asciz "Primes up to "
msg1_len:
	.quad 13

msg2:
	.asciz ":\n"
msg2_len:
	.quad 2

alloc_failed_msg:
	.asciz "Failed to allocate memory\n"
alloc_failed_msg_len:
	.quad 26
