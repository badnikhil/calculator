section .data
	msg_for_operator db "Enter Operator (+ , - , * or /) : " 
	msg_for_operator_len equ $ - msg_for_operator
	msg_for_integer_one db "Enter 1st Integer: " 
	msg_for_integer_one_len equ $ - msg_for_integer_one
	msg_for_integer_two  db "Enter 2nd Integer: "
	msg_for_integer_two_len equ $ - msg_for_integer_two
section .bss
	operator_buffer resb 2 ;input_buf -> label , resb -> reserver bytes , 50 -> reserve 50 bytes
	integer_one_buffer resb 2
	integer_two_buffer resb 2
	result_buffer resb 2
section .text
	global _start

_start:
	;print the message for operator
	mov rsi , msg_for_operator
	mov rdx , msg_for_operator_len
	call print
	;input operator
	mov rsi , operator_buffer
	mov rdx , 2
	call read
	;print the message for Integer 1
	mov rsi , msg_for_integer_one
	mov rdx , msg_for_integer_one_len
	call print
	;input 1st integer
	mov rsi , integer_one_buffer
	mov rdx , 2
	call read
	;convert it into Integer
	mov bl , byte [integer_one_buffer]
	sub bl , '0'
	mov byte[integer_one_buffer] , bl
	
	;print the message for Integer 2
	mov rsi , msg_for_integer_two
	mov rdx , msg_for_integer_two_len
	call print
	;input 2nd integer
	mov rsi , integer_two_buffer
	mov rdx , 2
	call read
	;convert it into Integer
	mov bl , byte [integer_two_buffer]
	sub bl , '0'
	mov byte[integer_two_buffer] , bl

	;check what is the operator and call the corresponding subroutine
	mov al, byte [operator_buffer]
	cmp al , '+'
	je addition
	cmp al , '*'
	je multiply
	cmp al , '/'
	je divide
	cmp al , '-'
	je subtract
	call exit






addition:
	mov al , byte [integer_one_buffer]
	mov bl , byte [integer_two_buffer] 
	add al , bl
	add al ,'0'
	mov byte [result_buffer] , al
	mov byte [result_buffer + 1] , 10
	mov rsi , result_buffer
	mov rdx , 2
	call print
	call exit

subtract:
	mov al , byte [integer_one_buffer]
	mov bl , byte [integer_two_buffer] 
	sub al , bl
	add al ,'0'
	mov byte [result_buffer] , al
	mov byte [result_buffer + 1] , 10
	mov rsi , result_buffer
	mov rdx , 2
	call print
	call exit

multiply:
;Not Implemented Yet


divide:
;Not implemented Yet


; whatever needs to be printed should be inside register ->rsi , 
; its length should be in register -> rdx
;this subroutine make syscalls via registers -> rax, rdi

print:
	mov rax , 1
	mov rdi , 1

	syscall
	ret

; the address where input is to be saved(input buffer) should be in register -> rsi
; the max bytes allocated for the buffer or max bytes of input allowed should be in register ->rdx
; this subroutine make syscalls via registers -> rax, rdi
; the number of bytes successfully read are supposed to be in register -> rax but if there is any failure register ->rax will have -1 or a negative value
read:
	mov rax , 0
	mov rdi , 0
	syscall
	ret
exit:
	mov rax , 60
	xor rdi , rdi
	syscall
