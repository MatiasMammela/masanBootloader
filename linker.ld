SECTIONS
{   
    . = 0xA000;

    .text : {
        *(.entry)
        *(.early)
        *(.text)
    } :text

    .rodata : {
        *(.rodata)
    } :rodata

    .data : {
        *(.data)
    } :data

    .bss : {
        *(.bss)
        *(COMMON)
    } :data

}

PHDRS
{
    text PT_LOAD FLAGS(0x5);    /* Read + Execute */
    rodata PT_LOAD FLAGS(0x4); /* Read-only */
    data PT_LOAD FLAGS(0x6);   /* Read + Write */
}