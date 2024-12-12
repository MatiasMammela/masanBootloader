bits 16
extern g_gdt
extern g_gdt_limit
extern entryXD
section .data
g_gdt_pointer:      ; GDT_ptr (6 bytes)
    dw 0            ; Limit 2 bytes
    dd 0            ; Base 4 bytes


section .entry
jmp _start

section .early


_start:
xor ax , ax 
mov ds , ax 
mov es , ax 
mov fs , ax 
mov gs , ax 
mov ss , ax 

pushad
;Enable A20
mov ax , 0x2401
int 0x15
popad
xor ax ,ax


;Load and Enable GDT

lea si, [g_gdt_pointer]     
mov ax, g_gdt_limit         
mov [si], ax                
add si, 2                   
mov eax, g_gdt              
mov [si], eax               


; Load the GDT using the lgdt instruction
lgdt [g_gdt_pointer]        ; Load the GDT pointer structure into the GDT register

mov eax , cr0
or eax , 1 
mov cr0 , eax 


jmp 0x18:entry_protected






bits 32
entry_protected:



    mov eax, 0x20                          
    mov ds, eax
    mov ss, eax
    mov es, eax
    mov fs, eax
    mov gs, eax

    mov bp, sp



    jmp entryXD
