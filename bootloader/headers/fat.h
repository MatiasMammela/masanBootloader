#ifndef FAT_H
#define FAT_H
#include <stdint.h>
struct BPB // Bios Parameter block 1. Sector
{
    uint16_t BS_jmpBoot_low;  // 2 bytes 16 bits
    uint8_t BS_jmpBoot_Hight; // 1 byte 8 bits
    uint64_t BS_OEMName;      // 8
    uint16_t BPB_BytsPerSec;  // 2
    uint8_t BPB_SecPerClus;   // 1
    uint16_t BPB_RsvdSecCnt;  // 2
    uint8_t BPB_NumFATs;      // 1
    uint16_t BPB_RootEntCnt;  // 2
    uint16_t BPB_TotSec16;    // 2
    uint8_t BPB_Media;        // 1
    uint16_t BPB_FATSz16;     // 2
    uint16_t BPB_SecPerTrk;   // 2
    uint16_t BPB_NumHeads;    // 2
    uint32_t BPB_HiddSec;     // 4
    uint32_t BPB_TotSec32;    // 4
};

#endif // FAT_H