#ifndef GDT_H
#define GDT_H
#include <stdint.h>
// GDT Entry Structure
typedef struct
{
    uint16_t low_limit;        // Limit [0:15]
    uint16_t low_base;         // Base [0:15]
    uint8_t middle_base;       // Base [16:23]
    uint8_t access_byte;       // Access Byte
    uint8_t flags_upper_limit; // Flags (4 bits) and Limit [16:19]
    uint8_t high_base;         // Base [24:31]
} __attribute__((packed)) gdt_entry_t;

// Null GDT Entry for clarity
#define NULL_GDT_ENTRY {0, 0, 0, 0, 0, 0}

extern gdt_entry_t g_gdt[];
extern uint16_t g_gdt_limit;
#endif // GDT_H