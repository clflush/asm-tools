	.macro ___dig_save
	mov     %rax, ___dig_rax
	mov     %rbx, ___dig_rbx
	mov     %rcx, ___dig_rcx
	mov     %rdx, ___dig_rdx
	mov     %rsi, ___dig_rsi
	mov     %rdi, ___dig_rdi
	mov     %r8,  ___dig_r8
	mov     %r9,  ___dig_r9
	mov     %r10, ___dig_r10
	mov     %r11, ___dig_r11
	mov     %r12, ___dig_r12
	mov     %r13, ___dig_r13
	mov     %r14, ___dig_r14
	mov     %r15, ___dig_r15
	.endm
	.macro ___dig_restore
	mov     ___dig_r15, %r15
	mov     ___dig_r14, %r14
	mov     ___dig_r13, %r13
	mov     ___dig_r12, %r12
	mov     ___dig_r11, %r11
	mov     ___dig_r10, %r10
	mov     ___dig_r9,  %r9
	mov     ___dig_r8,  %r8
	mov     ___dig_rdi, %rdi
	mov     ___dig_rsi, %rsi
	mov     ___dig_rdx, %rdx
	mov     ___dig_rcx, %rcx
	mov     ___dig_rbx, %rbx
	mov     ___dig_rax, %rax
	.endm
        .macro ___dig_printer name
        ## Register printing routine
        ## -------------------------
        ## adapted from Frank Kotler's post
        ## http://forum.nasm.us/index.php?topic=1371.0
        ##
        ## variables
        ## ---------
        ## rax --- the original value
        ## rbx --- holds the divisor
        ## rcx --- temporary storage
        ## rdx --- division remainder
	mov     \name, %rax    # put the value to write in rax
        mov     $10, %rbx      # divisor
### divide by 10, push remainder into buffer
push_digit_\@:
        ## divide off the largest power of ten
        xor     %rdx, %rdx      # clear rdx
        idiv    %rbx            # rdx:rax/rbx -> rax quotient, rdx remainder
        mov     %rax, %rcx      # temporarily save the quotient into rcx
        ## print the remainder
        add     $48, %rdx       # convert remainder to ascii (by adding '0')
        mov     %rdx, %rax      # move the remainder to rax (really ral) for printing
        ## stos   %al,%es:(%rdi)
        stosb                   # push the byte into the buffer
        ## conditional loop
        mov     %rcx, %rax      # restore the quotient
        or      %rax, %rax      # is quotient zero?
        jnz     push_digit_\@   # if not then repeat
        mov     $32, %rax       # place a space before the number
        stosb
        ## return
        .endm
	.macro ___dig_print_registers name
        ___dig_save
        ## byte storage setup
        std                    # set direction flag to count backwards
        mov     $___dig_buffer, %rdi # buffer start
        add     $512, %rdi           #        \->end in rdx
        ## queue up register values
        ___dig_printer ___dig_r15
        ___dig_printer ___dig_r14
        ___dig_printer ___dig_r13
        ___dig_printer ___dig_r12
        ___dig_printer ___dig_r11
        ___dig_printer ___dig_r10
        ___dig_printer ___dig_r9
        ___dig_printer ___dig_r8
        ___dig_printer ___dig_rdi
        ___dig_printer ___dig_rsi
	___dig_printer ___dig_rdx
	___dig_printer ___dig_rcx
        ___dig_printer ___dig_rbx
        ___dig_printer ___dig_rax
        ## include label name
        add     $1, %rdi        # pointer to beginning of text
        sub     $___dig_length_\name, %rdi # make room for label
        mov     $___dig_\name, %rsi        # label string source
        cld                   # switch string direction back to foward
        mov     $___dig_length_\name, %rcx # number of bytes to move
        rep     movsb
        ## print the accumulated buffer
        sub     $___dig_length_\name, %rdi # reposition to before label
        mov     %rdi, %rsi      # beginning of entire string to print
        mov     $1, %rax        # write system call
	mov     $___dig_buffer, %rdx # buffer start
        add     $512, %rdx           #        \->end in rdx
        sub     %rdi, %rdx      # subtract buffer start -> buffer length in rdx
        add     $1, %rdx        # with an extra one for the space
        mov     $1, %rdi        # STDOUT file descriptor
        syscall                 # print buffer contents
        ___dig_restore
        .endm
	.section        .data
___dig_rax:     .quad 0
___dig_rbx:     .quad 0
___dig_rcx:     .quad 0
___dig_rdx:     .quad 0
___dig_rsi:     .quad 0
___dig_rdi:     .quad 0
___dig_r8:      .quad 0
___dig_r9:      .quad 0
___dig_r10:     .quad 0
___dig_r11:     .quad 0
___dig_r12:     .quad 0
___dig_r13:     .quad 0
___dig_r14:     .quad 0
___dig_r15:     .quad 0
___dig_buffer:  .skip 512
.text
.global main
main:
        mov     $0, %rax
        mov     $1, %rbx
        mov     $2, %rcx
        mov     $3, %rdx
        ___dig_print_registers main
        mov     $60, %rax
        mov     $0, %rdi
        syscall
        .section .rodata
___dig_main:
        .ascii  "main:"
        .set    ___dig_length_main, .-___dig_main
