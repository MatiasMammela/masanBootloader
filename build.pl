#!/usr/bin/perl

use strict;
use warnings;
use File::Basename;

#paths
my $bootloader_src = "bootloader/src";
my $bootloader_headers = "bootloader/headers";
my $kernel_src = "kernel/src";
my $kernel_headers = "kernel/headers";
my $build_dir = "build";
my $kernelbuild_dir = "kernelBuild";
#output files
my $mbr_bin = "build/mbr.bin";
my $entry_elf = "build/entry.elf";
my $kernel_elf = "build/kernel.elf";
system("rm -rf $build_dir");
system("mkdir build");
system("nasm -f bin $bootloader_src/mbr.asm -o $mbr_bin")==0 or die "Failed to assemble mbr: $! \n";

opendir(my $dh, $bootloader_src) || die "Can't open $bootloader_src: $!";
my @c_files = grep { /\.c$/ && -f "$bootloader_src/$_" } readdir($dh);
closedir($dh);

foreach my $c_file (@c_files) {
    my $obj_file = $build_dir . '/' . basename($c_file, '.c') . '.o';
    system("gcc -m32 -I $bootloader_headers -c $bootloader_src/$c_file -ffreestanding -o $obj_file");
    print("Compiled $c_file \n");
}

opendir(my $dh2, $bootloader_src) || die "Can't open $bootloader_src: $!";
my @asm_files = grep { /\.asm$/ && -f "$bootloader_src/$_" } readdir($dh2);
closedir($dh2);

my @object_files;

# Compile each assembly file into an object file
foreach my $asm_file (@asm_files) {
    next if $asm_file =~ /mbr\.asm$/;  # Skip MBR files
    my $obj_file = "$build_dir/" . $asm_file =~ s/\.asm$/.o/r;
    system("nasm -f elf32 $bootloader_src/$asm_file -o $obj_file") == 0
        or die "Failed to assemble $asm_file: $!";
    print("$asm_file compiled successfully.\n");
    push @object_files, $obj_file;
}
my $final_obj_file = "$build_dir/linkedBootloader.o";
system("ld -m elf_i386 -T linker.ld -o $final_obj_file $build_dir/*.o") == 0 or die "Failed to link the bootloader: $! \n";
system("objcopy -O binary $final_obj_file $entry_elf");


opendir(my $dh3, $kernel_src) || die "Can't open $kernel_src: $!";
my @c_files2 = grep { /\.c$/ && -f "$kernel_src/$_" } readdir($dh3);
closedir($dh3);

foreach my $c_file2 (@c_files2) {
    my $obj_file = $kernelbuild_dir . '/' . basename($c_file2, '.c') . '.o';
    system("gcc -I $kernel_headers -c $kernel_src/$c_file2 -ffreestanding -fno-pie -o $obj_file");
    print("Compiled $c_file2 \n");
}

my $kernel_object_files = join(' ', glob("$kernelbuild_dir/*.o"));
system("ld -m elf_x86_64 -T kernel_linker.ld -o $kernel_elf $kernel_object_files") == 0 or die "Failed to link kernel ELF: $!\n";
print("Kernel linked successfully: $kernel_elf\n");

system("mkimg");
print("Build completed successfully!");


# Define the QEMU flags
my @qemu_flags = (                  
    "-drive", "file=disk.img,format=raw",               # Use -hda to specify the disk image
    "-D", "log.txt",                  # Enable logging and write logs to log.txt
    "-d", "int",                      # Enable debug output for interrupts
    "-M", "smm=off",                  # Disable SMM (System Management Mode)
    "-no-reboot",                     # Do not reboot the VM on shutdown
    "-no-shutdown",                   # Do not power off the VM on shutdown
    "-serial", "file:/dev/stdout",    # Redirect serial output to standard output
    "-monitor", "stdio"               # Use standard input/output for the QEMU monitor
);

# Fork and run QEMU
my $pid = fork();
if ($pid == 0) {
    # Child process: Run QEMU
    exec("qemu-system-x86_64", @qemu_flags);
    exit(0);
}

# Handle Ctrl+C (SIGINT)
$SIG{'INT'} = sub {
    print "Killing QEMU...\n";
    kill 'TERM', $pid;  # Send terminate signal to QEMU
    waitpid($pid, 0);   # Wait for QEMU to exit
    exit(0);
};

# Parent process continues, waiting for QEMU
waitpid($pid, 0);
