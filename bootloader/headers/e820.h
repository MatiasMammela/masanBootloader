#ifndef E820_H
#define E820_H
#include <stdint.h>
#define E820_MAX_ENTRIES 512
#define E820_MAGIC 0x534D4150
#define E820_SIGNATURE 0xE820
typedef enum
{
    E820_MAP_TYPE_USABLE,
    E820_MAP_TYPE_RESERVED,
    E820_MAP_TYPE_ACPI_RECLAIMABLE,
    E820_MAP_TYPE_ACPI_NVS,
    E820_MAP_TYPE_BAD
} e820_map_type_t;

typedef struct
{
    uint64_t base;
    uint64_t length;
    e820_map_type_t type;
} e820_map_entry_t;
extern void read_bios_mem_map();
extern uint32_t entry_count;
extern e820_map_entry_t e820_map[E820_MAX_ENTRIES];

#endif // E820_H