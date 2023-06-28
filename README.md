# STARS 2023 Design Final Project

## Outel
* Aidan
* Adrian
* Andrew
* Thomas
* Spencer

## 6502-like chip
The Outel 8227 is a multi-cycle, single core processor that supports the full instruction set architecture (ISA) of Intel's 6502 processor chip. The architecture of the 8227 is directly inspired by the original design of the 6502; however, several parts of the 6502 have been implemented in different ways to ensure that the 8227 is able to be manufactured by modern technology. It should be noted that the original 6502 chip was created in 1975, so the 8227 uses a unique accumulator based design unlike modern processors that use a register file and MIPS architecture. Due to technological advances since the creation of the 6502, a significant amount of reverse engineering was necessary to understand its operation well enough to devise a new version of it. Some examples of changes between the two designs include reducing the number of clock domains from two to one and merging pairs of D-latches into D-flip-flop equivalents. Aside from the functions of some RTL blocks changing, both devices look the same at a high level of abstraction. The 8227 can be split into two parts: control and datapath. Control is a large amount of combinational logic plus a state machine. It is responsible for interpreting instruction inputs and maipulating a large amount of control flags that enable the flow of data between different registers. The datapath is a collection of registers and combinational circuits intended to do calculations. Flags from the control side of the processor control how data moves and is operated on in the datapath. Datapath and control work together to execute programs stored in memory. Oprating on this principle, the 8227 is able to run popular arcade games** and other basic programs that would be feasible on a home computer from the 80s and 90s.

**The Outel 8227 is a processor chip alone. It must be used in connection with other devices such as memory and displays to be able to interact with the world around it. Therefore, truly playing a game is an endeavor that is left up to the user.

Here are reference materials that support the Outel 8227 Design:

- http://www.cs.columbia.edu/~sedwards/classes/2013/4840/reports/6502.pdf
- This is a project completed by students at Columbia University. They implemented a 6502 processor on an FPGA. Thier account of the project gave us helpful information and advice to reference while going through a similar process.

- https://www.princeton.edu/~mae412/HANDOUTS/Datasheets/6502.pdf
- This is the datasheet for the 6502 processor from Princeton University. It countains useful information about how instructions pass through the datapath of the processor. It also has useful introductions to many concepts such as addressing modes.

- https://www.masswerk.at/6502/6502_instruction_set.html#CMP
- This is a page that fully describes the 6502 ISA. The processor is built around handling the ISA described on this site.

## Pin Layout
- Data I/O Bus: 8 I/O pins reserved for data I/O to/from the processor

- Address Bus Low Out: 8 O pins reserved for the low byte of the desired memory address

- Address Bus High Out: 8 O pins reserved for the high byte of the desired memory address

- ~NMI: 1 I pin (active low) reserved for non maskable interrupts

- ~IRQ: 1 I pin (active low) reserved for normal interrupts (most interactions with interrupt will be internal to the processor, external interrupts are more useful when there are more asynchronous input devices)

- ~RES: 1 I pin (active low) reserved for resetting the processor to a known state

- Ready: 1 I pin reserved for enabling further processor operation. If ready goes low and the processor is not writing, then the processor will be frozen in its current state.

- Read/~Write: 1 O pin reserved for showing whether the processor is currently reading or writing information

- Set Overflow: 1 I pin reserved for directly setting the overflow flag in the process status register

## Supporting Equipment
With the Outel 8227 alone, it is difficult to see many of the fascinating applications of a processor. It is recommended that users have supporting equipment to interface with the processor. The standard and tested configuration for external hardware is given by Ben Eater** in his video series regarding the 6502 processor. Ideally, the 8227 will be able to access external RAM, ROM, and some form of display. The parts list for this capability is as follows:

- RAM - AS6C62256 from Alliance
- EEPROM - AT28C64B from Amtel
- Interface Adapter - WD65C22 from Wester Design Center
- NAND - 74hc00 Quad NAND
- 16x2 LCD Display capable of interfacing with with the WD65C22

**Ben Eaters videos provide all instruction necessary to put together the listed parts and interact witha 6502-like chip. 

- Eater's website: https://eater.net/6502
- Eater's instruction videos: https://www.youtube.com/watch?v=LnzuMJLZRdU&list=PLowKtXNTBypFbtuVMUVXNR0z1mu7dp7eH

The basic function of the suggested peripheral setup is as follows: The processor's addressing power is mapped between RAM and ROM, the address bus determines the location of a read or write. The interface adapter can see the outputs from memory and choose to output them to the ASCII display.

## RTL Diagrams
All referenced diagrams are available at the given link. Additional diagrams of various parts of the design are also present at the link.

## Some Legal Statement
From Purdue that I haven't figured out yet, maybe some stuff about Dr. J, the program, and other instructors
