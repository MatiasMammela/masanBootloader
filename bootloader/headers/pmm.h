#ifndef PMM_H
#define PMM_H
#include <stdint.h>
#define PMM_MAX_ENTRIES 512

typedef enum
{
    PMM_MAP_TYPE_USABLE,
    PMM_MAP_TYPE_RESERVED,
    PMM_MAP_TYPE_ACPI_RECLAIMABLE,
    PMM_MAP_TYPE_ACPI_NVS,
    PMM_MAP_TYPE_RESERVED,
    PMM_MAP_TYPE_BAD
} pmm_map_type_t;

typedef struct
{
    uint64_t base;
    uint64_t length;
    pmm_map_type_t type;
} pmm_map_entry_t;

extern pmm_map_entry_t pmm_map[PMM_MAX_ENTRIES];

#endif // PMM_H