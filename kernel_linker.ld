OUTPUT_FORMAT(elf64-x86-64)
ENTRY(init)
PHDRS
{
    text    PT_LOAD FLAGS((1 << 0) | (1 << 2));
    data    PT_LOAD FLAGS((1 << 1) | (1 << 2));
    rodata  PT_LOAD FLAGS((1 << 2));
}


SECTIONS
{   
    . = 0xFFFFFFFF80000000;

    ld_kernel_start = .;


    .text : {
        *(.text .text.*)
    } :text

    .rodata : {
        *(.rodata .rodata.*)
    } :rodata

    .data : {
        *(.data .data.*)
    } :data

    .bss : {
        *(COMMON)
        *(.bss .bss.*)
    } :data
    ld_kernel_end = .;
}