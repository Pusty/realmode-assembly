# Realmode Assembly - Writing bootable stuff
## Part 1: Theory and Concepts

----------

## What is this?
This is going to be a walk-through in writing  Operation Systems in assembly which operate purely in Realmode.
Goal will be writing different kernels from a simple "Hello World" over small terminal programs to
graphically displayed games.

I decided to split this walk-through into small parts so those few who are interested in this have
enough time to read the necessary theory and references before getting code smashed in the face, 
I hope this prevents the parts from getting unnecessary long or confusing and it also gives
me the time to properly check the information and code I provide (although errors might sneak in
which makes reading the sources for reliable information the recommended way if you are really interested in how this works)

## Requirements
* Being patient enough to read through this badly written text before jumping into action

## Notes

* This information is the result of my research and own programming, everything said here might be wrong, correct me if you spot mistakes though!
* I will try to list my sources at the bottom but I can't guarantee that these are all of them.
* I'M NOT RESPONSIBLE IF YOU BREAK SOMETHING USING INFORMATION I PROVIDED HERE.

## Content of this Article
Before doing anything there is a bit of theory and things to be understood before starting.
So no code here only simple explanations of concepts and what we will do in the next articles.

----------

## What is Realmode?
Real mode is the operation mode all x86 compatible CPUs start in. Originally CPUs were only able to use real mode, later CPUs switched to protected mode (which is the main operation modes for modern Intel processors and allows for example Virtual Memory allocation and instruction set restriction through privilege levels) but starting in real mode was kept in for legacy reasons.

It doesn't supply fancy stuff like virtual addresses so all addresses used are actual physical addresses also we won't be able to access 64-bit instructions as they are only accessible in Long mode (the mode x86-64 mainly operate in).

It provides unlimited direct access to memory, I/O and peripheral hardware which means we have control over almost everything. We will only have 1MiB of accessible memory (actually less) but that will be enough as we won't write too long code. The BIOS provides lots of handy interrupts to interact with I/O and peripherals. 

It also provides drivers for devices so we don't need to worry about our mouse or keyboard not working (except you have some weird hardware). 
Also important to know is that the default CPU operation length is 16bit so we rarely going to use 32bit registers or operations.

```plain
|------------------------------------------------------------------------------------------------------|
|                                     CPU Mode Flow Chart                                              |
|                                                                                                      |
|                                            |----------------|-----------------------|                |
|                              ------------> | [64-bit mode] <-> [Compatibility mode] | # Long mode    |
|                              |             |----------------|-----------------------|                |
|  |---------------------------|----------|                                  /\                        |
|  | [Real Mode] ------> [Protected Mode] | # Legacy mode                    Long Mode is for          |
|  |--------------------------------------|                                  64bit CPUs to get         |
|       /\                            /\                                     Access to 64bit           |
|       The CPU start in this mode    This is the mode 32bit CPUs mainly     instructions              |
|       We will stay here             use.                                                             |
|                                                                                                      |
|------------------------------------------------------------------------------------------------------|
```

## BIOS
The BIOS(Basic Input/Output System) is the system that's responsible for initializing hardware on startup of the computer and responsible for providing generalized services for kernel and programs to easily interact with hardware (mouse, keyboard, display). It comes pre-installed on the motherboard and  is the first software run after power-on. All interrupts we will use will be directed to the BIOS so it will be a core component of our real mode assembly.

## Bootloader/MBR
The BIOS checks bootable devices for the boot signature in their first sector and writes this segment,
if the boot signature was found, to the physical address 0x0000:0x7c00 (0st segment at address 0x7c00).
This is the Master Boot Record, it's limited to 512 bytes and it's supposed to pick the hard drive and partition to boot from, write the bootloader of that partition into memory and jump to it so it can initialize the kernel loading.

That won't be necessary for our small Operation Systems as we won't have partitions or a proper file system or anything in that matter so we will just use the MBR to load in the kernel into RAM and to give control to it.

## Kernel
The kernel is the main part of an operation system. 
In the future code of this walk-through it will be responsible for everything, it will be the main place for our code. (I'm actually not sure if that technically counts as a kernel)

## So what's the plan?
First we will write a Master Boot Record, that copies the kernel from the hard drive to memory.
We will do that using BIOS Interrupt 0x13 which is responsible for reading and writing operations which involve drives.
	
After that we will load into out kernel and send our monitor a nice "Hello World" message using BIOS Interrupt 0x10 which will be our method of writing text and drawing pixels to the screen.

```plain
|----------------------------------------------------------------------|
|					1 MB Memory we have available                      |
|--------|--------|-------------------------|--------------------------|
| MBR    | Kernel | Free Space for us to use|  BIOS and Hardware Area  |
| 0x7c00 | 0x8000 |  ~640KB for us to use   |         ~360KB           |
|--------|--------|-------------------------|--------------------------| 
```

```plain
[BIOS] --Loads--> [Master Boot Record / Bootloader] --Loads--> [Kernel] --Prints--> [Display]
```

(If you are interested in understanding more modern boot sequences (after floppy disks) you can check the last source&reference link)

## Conclusion
This concludes the theory aspect, thank you for reading through this.
I hope this is all the information you need to proceed.
If I wrote something wrong just point it out and I will correct it also feedback is appreciated

### [Next Part](https://github.com/Pusty/realmode-assembly/tree/master/part2)

----------
## Sources and References
* http://wiki.osdev.org/Real_Mode
* http://wiki.osdev.org/Protected_Mode
* https://en.wikipedia.org/wiki/Long_mode
* https://en.wikipedia.org/wiki/BIOS
* http://wiki.osdev.org/MBR_(x86)
* http://wiki.osdev.org/Kernel
* http://wiki.osdev.org/Boot_Sequence
* http://stanislavs.org/helppc/int_13.html
* https://en.wikipedia.org/wiki/INT_10H
* http://duartes.org/gustavo/blog/post/how-computers-boot-up/	
* http://flint.cs.yale.edu/feng/cos/resources/BIOS/
* http://gec.di.uminho.pt/discip/MaisAC/HCW/09R03.pdf
* https://superuser.com/questions/660143/does-the-bios-have-some-sort-of-generic-drivers