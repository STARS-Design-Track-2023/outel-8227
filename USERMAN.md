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
