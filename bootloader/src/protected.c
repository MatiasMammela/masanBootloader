#include "list.h"
#include "lib.h"
#include "e820.h"
#include <cpuid.h>
#define MSR_EFER 0xC0000080 // MSR for Extended Feature Enable Register
#define EFER_NX (1 << 11)   // NX bit in the EFER
int is_nx_supported()
{
    unsigned int edx = 0, unused;
    if (__get_cpuid(0x80000001, &unused, &unused, &unused, &edx) != 0)
    {
        return (edx & (1 << 20)) != 0; // NX is bit 20 in the CPUID 0x80000001 EDX register
    }
    return 0; // NX not supported
}
void enable_nx()
{
    unsigned long efer;
    __asm__ __volatile__(
        "rdmsr"         // Read MSR
        : "=A"(efer)    // Output to efer
        : "c"(MSR_EFER) // Input MSR address
    );

    efer |= EFER_NX; // Set the NX bit
    __asm__ __volatile__(
        "wrmsr" // Write MSR
        :
        : "c"(MSR_EFER), "A"(efer) // Write the new EFER value
    );
}

__attribute((noreturn)) void entryXD()
{

    // Enable NX
    if (is_nx_supported)
    {
        enable_nx();
    }

    asm volatile(
        "movw $4, %%ax"
        :
        :
        : "ax");
    read_bios_mem_map();
    for (uint32_t i = 0; i < entry_count; i++)
    {
        e820_map_entry_t *entry = &e820_map[i];
        printf("%lx\n", entry->base);
        printf("%lx\n", entry->length);
        printf("%d\n", entry->type);
        printf("\n");
    }
    for (;;)
    {
        asm("hlt");
    }
    __builtin_unreachable();
}