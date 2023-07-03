# Outel 8227 User Manual

# Select the Outel 8227
- Select the Outel 8227 project in the manner specified by the general manual

# Program the EEPROM
- Use an EEPROM programmer to put the desired executable file into the recommended EEPROM chip
- The online compiler "vasm" can be used to generate raw binary files from 6502 assembly language
- It is recommended that the user use prexisting 6502 programs to compile and run on the 8227

# Wire the 8227 to recommended peripherals
- This will involve a breadboard, wires, and recommended external chips provided in the project README

# Reset the processor
- After the processor is hooked up to all necessary inputs, momentarily drive the reset pin low. 

# Let Processor Run
- After being properly wired up and reset, the 8227 should begin to run whatever program is in the EEPROM.

# Regarding the operation of the 8227 processor
- The following is a description of a sucessful use of the 8227.

1. The user has wired up the chip so that it can sucessfully interact with memory. The 

2. The user drives reset low briefly

3. The reset is lifted and the processor enters a seven cycle boot up sequence. Registers are transferred to know states and control of the program is given the the OS contained in the highest memory addresses available. From there, the OS directs the program to the start of executable code.

4. From this point onward, the processor simply does what it is directed to by the program. Depending on the type of output display interfaced with the processor, the user will be able to see program outputs.


# Things that are good to know about the 8227 processor

1. There are two signals in the chip used to handle timing, the regular clock, and slow pulse. Slow pulse makes it easier to interface with slow outside memory devices, and it is run at a third of the original clock speed of 10 MHz. Both timing signals have a corresponding output pin.

2. There are external input pins for maskable and non-maskable interrupts. These can be used to interface other sorts of peripherals with the 8227.

3. As a catch all, read the programming manual and datasheet for the original MOS 6502. The 8227 is close enough to the original that most things in the sheets still apply. 

Programming Manual: http://archive.6502.org/books/mcs6500_family_programming_manual.pdf
Datasheet: https://www.princeton.edu/~mae412/HANDOUTS/Datasheets/6502.pdf