org 0x7C00
bits 16               
%define ENDL 0x0D , 0x0A

BOOTLOADER2_BUFFER equ 0xA000
BUFFER equ 0x7C00 + 1024
DAP equ 0x7C00 + 512 

jmp short _start
nop

;Cluster -> sector -> bytes

; volume_label: dq 0xe7279993d46ce54                      ; Volume label
; dq 0x9a098d5b
; dq 0x3e25be80f
volume_label: db "Moi     "
lba_low: dd 0
lba_high: dd 0
number_of_entries: dd 0
partition_entry_size: dd 0  ;double word = 4 bytes

_start:
	jmp 0:.jee
	.jee:
	call reset_segment_regs
	
	mov sp, 0x7C00
	mov [bootdrive] , dl ;Drive index 

	;Read the GPT entry array
	mov ebx , 1
	mov ebp , BUFFER
	call read_disk

	mov eax , dword [BUFFER+0x48] ;EAX=00000002
	mov [lba_low],eax

	mov eax , dword [BUFFER+0x4C] ;EAX=00000000
	mov [lba_high],eax

	mov eax , dword [BUFFER+0x54] ;EAX=00000080
	mov [partition_entry_size],eax

	mov eax , dword [BUFFER+0x50] ;EAX=00000080
	mov [number_of_entries],eax

	mov ebx,[lba_low] ;Read the sector where GUID will be
	mov ebp , BUFFER
	call read_disk

	xor ax, ax
    mov es, ax  	
	mov ebx , BUFFER
	mov eax ,partition_entry_size
.loop:
	push ecx ;loop instruction uses ecx to keep track of the count so we need to push it to stack so it doesnt interfere with rebe cmpsb
	mov ecx , 16 ;lenght of compared bytes needed by rebe cmpsb
	mov esi , ebx
	mov edi , volume_label
	repe cmpsb
	pop ecx
	jz .found
	add ebx,eax ;move the buffer ptr by eax value

	loop .loop
	jmp .not_found


.found:
    mov si, success_msg
    call qemu_serial_print


	xor ecx , ecx ; 0 ecx
	mov ebx ,BUFFER
	mov ecx , dword [ebx + 0x28] ;Take the end of  lower lba (32 + 8) 

	sub ecx , dword [ebx + 0x20] ;Substract it with the start of lower lba (32)
	;We have the sector count in ecx
	inc ecx ; increment ecx to get 32 from 31 
	;Get the starting sector to edi
    mov edi, dword [ebx + 0x20] ; LBA low       

	add ecx ,edi
	mov ebx ,edi

	mov ebp , BOOTLOADER2_BUFFER
	.loop2: ;Loop uses ecx as the counter
	call read_disk
	add ebp , 512

	inc ebx
	cmp ecx , ebx
	je .second_stage
	jmp .loop2

	.second_stage:
	jmp BOOTLOADER2_BUFFER
	cli 
	hlt


.not_found:
    mov si, error_msg
    call qemu_serial_print
    cli
    hlt



	; mov ax , [BUFFER+510]
	; call qemu_serial_print_hex

    mov si, END
	call qemu_serial_print
	cli
	hlt






.halt:
	jmp .halt

read_disk:
	pushad
    mov ah, 42h            		; BIOS function read drive parameters

	mov si , DAP

	mov [DAP], word 10h
	mov [DAP+2], word 1
	mov [DAP + 4] ,ebp
	mov [DAP + 6], word 0	
	mov [DAP + 8], ebx
	mov [DAP + 12], dword 0

	int 0x13               		; Call BIOS interrupt
    jc error               		; If error jump to it
	

	popad
	ret



error:
	mov si , error_msg
	call qemu_serial_print
	hlt

reset_segment_regs:
	xor ax , ax
	mov es,  ax
	mov ds , ax 
	mov ss , ax
	ret


qemu_serial_print:
    push dx  
	push ax      
    mov dx, 0x03F8       

.loop:
	mov al , [si]
	inc si         
    or al, al             
    jz .done     
	 
    out dx, al           
    jmp .loop           

.done:
	pop ax
    pop dx              
    ret                  

qemu_serial_print_hex:
    push ax
    push bx
    push cx
    push dx
    mov cx, 4          
    mov dx, 0x03F8     

.loop:
    rol ax, 4           
    mov bl, al          
    and bl, 0x0F       
    cmp bl, 0x0A       
    jl .digit
    add bl, 'A' - 10    
    jmp .output
.digit:
    add bl, '0'        
.output:
    mov al, bl
    out dx, al         
    loop .loop
	mov si ,endl
	call qemu_serial_print
    pop dx
    pop cx
    pop bx
    pop ax
    ret



bootdrive: db 0


endl: db ' ' , ENDL , 0
END: db 'END', ENDL,0  
error_msg: db 'Error', ENDL,0
success_msg: db "GUID Found!", ENDL, 0

times 440-($-$$) db 0