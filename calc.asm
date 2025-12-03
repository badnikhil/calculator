

section .data
	msg_for_operator db "Enter Operator (+ - * or /) : " 
	msg_for_operator_len equ $ - msg_for_operator
	msg_for_integer_one db "Enter 1st Integer: " 
	msg_for_integer_one_len equ $ - msg_for_integer_one
	msg_for_integer_two  db "Enter 2nd Integer: "
	msg_for_integer_two_len equ $ - msg_for_integer_two

section .bss
	operator_buffer resb 2
	integer_one_buffer resb 10
	integer_two_buffer resb 10
	int_1 resq 1
	int_2 resq 1
	result resq 1
	result_buffer resb 10
	result_len_buffer resq 1

section .text
	global _start

_start:
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
	mov rdx , 10
	call read
	;convert it into Integer
	mov rsi , integer_one_buffer
	mov rdx , rax
	call convert_string_into_integer
	mov [int_1] , rax 
	
	;print the message for Integer 2
	mov rsi , msg_for_integer_two
	mov rdx , msg_for_integer_two_len
	call print
	;input 2nd integer
	mov rsi , integer_two_buffer
	mov rdx , 10
	call read
	;convert it into Integer
	mov rsi , integer_two_buffer
	mov rdx , rax 
	call convert_string_into_integer
	mov [int_2], rax
	;check what is the operator and call the corresponding subroutine
	mov al, byte [operator_buffer]
	cmp al , '+'
	je addition
	cmp al , '-'
	je subtract
	cmp al , '/'
	je divide
	cmp al , '*'
	je multiply


evaluation_done:

	;convert result into string
	mov rsi , result
	mov rdi , result_buffer
	mov r10 , result_len_buffer
	call convert_integer_to_string
	mov rsi , result_buffer
	mov rdx , [r10]
	mov byte[result_buffer + rdx] , 10
	inc rdx
	call print

	call exit




; the address of string to be converted should be in register ->rsi 
; the length of string should be in register -> rdx

; Uses register -> rcx as pointer of bytes , rax to return 
convert_string_into_integer:
	;initialise registers
	dec rdx
	xor rcx , rcx
	xor rax , rax
	;loop starts
	.loop:
	;compare
	cmp rcx , rdx
	jge .return

	movzx rbx , byte [rsi + rcx]
	sub rbx , '0'
	imul rax , rax , 10
	add rax , rbx
	inc rcx 
	jmp .loop
	.return:
	ret


; the address of integer to be converted should be in register -> rsi 
; the address of the string where it will be stored should be in register -> rdi
; adresss to store length of result string should be in register -> r10
; Uses register -> rcx as pointer of bytes =
convert_integer_to_string:
    xor rcx , rcx
    mov rax , [rsi]
    mov  r9 , 0

.loop:
    inc r9
    xor rdx , rdx
    mov rbx , 10
    div rbx
    add rdx , '0'
    mov byte [rdi + rcx] , dl
    inc rcx
    cmp rax , 0
    jne .loop

;Reverse the string
	mov qword [r10] , r9
	mov rcx , 0
	dec r9
.reverse:
	mov al, byte [rdi + r9]
	mov bl , byte [rdi + rcx]
	mov byte [rdi + r9] , bl
	mov byte [rdi + rcx ] , al
	inc rcx
	dec r9
	cmp rcx , r9
	jl .reverse
    ret

addition:
	mov rax , [int_1]
	add rax , [int_2]
	mov [result] , rax
	jmp evaluation_done

subtract:
	mov rax , [int_1]
	sub rax , [int_2]
	mov [result] , rax
	jmp evaluation_done



multiply:
mov rax , [int_1]
mul qword [int_2]
mov [result] , rax
jmp evaluation_done

;higher part of dividend should be in register -> rdx
;lower part of dividend should be in register -> rax
;the divisor should be in register -> rbx
;the return values are in registers -> rax (the quotient) and register -> rdx (Remainder)
divide:
xor rdx , rdx
mov rax , [int_1]
mov rbx , [int_2]
div rbx
mov [result] , rax
jmp evaluation_done



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

;you can directly call the exit command 
exit:
	mov rax , 60
	xor rdi , rdi
	syscall

