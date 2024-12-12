#include "e820.h"
#include "int.h"

uint32_t entry_count = 0;
e820_map_entry_t e820_map[E820_MAX_ENTRIES];
void read_bios_mem_map()
{
    uint32_t ebx = 0; // Must be preserved between calls
    int_regs_t regs;  // Struct to hold register values for interrupt call
    entry_count = 0;

    do
    {

        // Set up the registers for the E820 call
        regs.eax = E820_SIGNATURE;                   // Set EAX to 0xE820
        regs.edx = E820_MAGIC;                       // Set EDX to 0x534D4150 "magic number"
        regs.ecx = sizeof(e820_map_entry_t);         // Set ECX to the size of a single entry
        regs.edi = (uint32_t)&e820_map[entry_count]; // ES:DI points to the current entry buffer
        regs.ebx = ebx;                              // Set EBX (must be preserved from previous call)

        // Call the interrupt
        int_exec(0x15, &regs);

        // If the call succeeded
        if (regs.eax != E820_MAGIC || (regs.eflags & 0x1))
        {
            break;
        }

        // Update EBX for the next call
        ebx = regs.ebx;

        // Increment the entry count
        entry_count++;

        // Stop if EBX is zero (no more entries)
    } while (ebx != 0 && entry_count < E820_MAX_ENTRIES);
}
