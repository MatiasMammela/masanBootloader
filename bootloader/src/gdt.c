#include "gdt.h"
gdt_entry_t g_gdt[] = {
    NULL_GDT_ENTRY, // Null Descriptor
    {               // Code Segment 16-bit
     .low_limit = 0xFFFF,
     .low_base = 0x0000,
     .middle_base = 0x00,
     .access_byte = 0b10011010,
     .flags_upper_limit = 0b00001111,
     .high_base = 0x00},
    {// Data Segment 16-bit
     .low_limit = 0xFFFF,
     .low_base = 0x0000,
     .middle_base = 0x00,
     .access_byte = 0b10010010,
     .flags_upper_limit = 0b00001111,
     .high_base = 0x00},
    {// Code Segment 32-bit
     .low_limit = 0xFFFF,
     .low_base = 0x0000,
     .middle_base = 0x00,
     .access_byte = 0b10011010,
     .flags_upper_limit = 0b11001111,
     .high_base = 0x00},
    {// Data Segment 32-bit
     .low_limit = 0xFFFF,
     .low_base = 0x0000,
     .middle_base = 0x00,
     .access_byte = 0b10010010,
     .flags_upper_limit = 0b11001111,
     .high_base = 0x00},
    {// Code Segment 64-bit
     .low_limit = 0x0000,
     .low_base = 0x0000,
     .middle_base = 0x00,
     .access_byte = 0b10011010,
     .flags_upper_limit = 0b00100000,
     .high_base = 0x00},
    {// Data Segment 64-bit
     .low_limit = 0x0000,
     .low_base = 0x0000,
     .middle_base = 0x00,
     .access_byte = 0b10010010,
     .flags_upper_limit = 0x00,
     .high_base = 0x00}};

__attribute__((section(".early")))
uint16_t g_gdt_limit = sizeof(g_gdt) - 1;
