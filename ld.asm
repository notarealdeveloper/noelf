section .text
global _start

_start:
    ; Load argc and argv addresses
    mov rdi, [rsp]           ; rdi = argc
    lea rsi, [rsp + 8]      ; rsi = argv

    ; Check argc (at least 2)
    cmp rdi, 2
    jl  print_usage_and_exit

    ; Load argv[1] to filename
    mov rdx, [rsi + 8]      ; argv[1]
    mov [filename], rdx

    ; open(filename, O_RDONLY)
    mov rax, 2              ; sys_open
    mov rdi, [filename]
    xor rsi, rsi            ; O_RDONLY
    syscall
    mov [fd], eax

    ; lseek(fd, 0, SEEK_END)
    mov rax, 8              ; sys_lseek
    mov rdi, [fd]
    xor rsi, rsi            ; offset = 0
    mov rdx, 2              ; SEEK_END
    syscall
    mov [size], rax

    ; Reset offset to start of file
    mov rax, 8              ; sys_lseek
    mov rdi, [fd]
    xor rsi, rsi            ; offset = 0
    xor rdx, rdx            ; SEEK_SET
    syscall

    ; mmap(NULL, size, PROT_READ | PROT_WRITE | PROT_EXEC, MAP_PRIVATE, fd, 0)
    mov rax, 9              ; sys_mmap
    xor rdi, rdi            ; NULL
    mov rsi, [size]         ; size
    mov rdx, 7              ; PROT_READ | PROT_WRITE | PROT_EXEC
    mov r10, 2              ; MAP_PRIVATE
    mov r8, [fd]            ; fd
    xor r9, r9              ; offset = 0
    syscall
    mov [bin], rax
    cmp rax, -1             ; MAP_FAILED
    je  mmap_failed

    ; Close the file descriptor
    mov rax, 3              ; sys_close
    mov rdi, [fd]
    syscall

    ; Call the loaded binary
    mov rax, [bin]
    call rax

    ; munmap(bin, size)
    mov rax, 11             ; sys_munmap
    mov rdi, [bin]          ; bin
    mov rsi, [size]         ; size
    syscall

    ; Exit
    mov rax, 60             ; sys_exit
    xor rdi, rdi            ; status 0
    syscall

print_usage_and_exit:
    mov rax, 1              ; sys_write
    mov rdi, 1              ; stdout
    mov rsi, usageMessage
    mov rdx, 26             ; length of usageMessage
    syscall
    mov rax, 60             ; sys_exit
    mov rdi, 1              ; status 1
    syscall

mmap_failed:
    mov rax, 1              ; sys_write
    mov rdi, 1              ; stdout
    mov rsi, mmapFailedMessage
    mov rdx, 16             ; length of mmapFailedMessage
    syscall
    mov rax, 60             ; sys_exit
    mov rdi, 1              ; status 1
    syscall

section .data
    usageMessage db "usage: ld <raw-binary>", 10, 0
    mmapFailedMessage db "Failed to mmap", 10, 0

section .bss
    filename resq 1
    fd resd 1
    size resq 1
    bin resq 1
