; mkdir.asm
BITS 64

%define stdin           0
%define stdout          1
%define stderr          2

%define sys_write       1
%define sys_open        2
%define sys_close       3
%define sys_fork        57
%define sys_exit        60
%define sys_mkdir       83
%define sys_rmdir       84
%define sys_creat       85
%define sys_unlink      87

section .text
global _start

_start:
    mov rax, sys_mkdir        ; sys_mkdir system call number for Linux x86_64
    lea rdi, [rel dirname]    ; first argument: pointer to the directory path
    mov rsi, 0o755            ; second argument: directory permissions
    syscall                   ; perform the system call

    mov     rdx, message_len    ; write string length
    lea     rsi, [rel message]  ; where to start writing
    mov     rdi, stdout         ; file descriptor
    mov     rax, sys_write      ; sys_write kernel opcode in x86_64
    syscall

    mov rax, sys_exit         ; sys_exit system call number
    xor rdi, rdi              ; Exit code 0
    syscall                   ; Exit the program

section .data

dirname:    db "boop", 0x00

message:    db "created directory", 0x0A, 0x00
message_len equ $-message

