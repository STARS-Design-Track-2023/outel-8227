/*STANDARDS
* ACC = Accumulator
* ADL = Internal Address bus low
* ADH = Internal Address bus high
* ABL = External Address bus low register
* ABH = External Address bus high register
* PC  = Program Counter
* PCL = Program Counter Low
* PCH = Program Counter High
* DB  = Internal Data Bus
* DATA= External Data Bus
* X   = Register X
* Y   = Register Y
* SB  = Stack Bus
* PSR = Processor Status Register
* Input_B and Input_A are ALU inputs
* PC_INC and PC_DEC increment and decrement
* A0-A3 are steps in the addressing states
* SET_"NAME"_TO_"THING" means that bus "NAME" is being driven by "THING"
* For example SET_ADL_TO_DATA means Internal Address bus low is set to External Data Bus
* LOAD_"REG" means load registor(source does not need to specified).
*/
parameter NUMFLAGS = 64;
parameter SET_ADH_LOW = 0;
parameter SET_ADL_TO_DATA = 1;
parameter LOAD_ABL = 2;
parameter LOAD_ABH = 3;
parameter PC_INC = 4;
parameter PC_DEC = 5;
parameter SET_ADL_TO_PCL = 6;
parameter SET_ADH_TO_PCH = 7;
parameter SET_DB_TO_DATA = 8;
parameter SET_INPUT_B_TO_DB = 9;
parameter SET_SB_TO_DB = 10;
parameter SET_ADL_TO_ALU = 11;
parameter SET_ADH_TO_SB = 12;
parameter SET_INPUT_A_TO_SB = 13;
parameter SET_SB_TO_X = 14;
parameter SET_SB_TO_Y = 15;
parameter SET_SB_TO_ACC = 16;
parameter SET_SB_TO_ALU = 17;
parameter ALU_ADD = 18;
parameter SET_INPUT_A_TO_LOW = 19;
parameter SET_ALU_CARRY_HIGH = 20;
parameter SET_ADH_TO_DATA = 21;
parameter SET_ALU_CARRY_TO_PSR_CARRY = 22;
parameter LOAD_ALU = 23;
parameter LOAD_X = 24;
parameter LOAD_Y = 25;
parameter SET_DB_TO_SB = 26;
parameter LOAD_ACC = 27;
parameter ALU_ROT = 28;
parameter ALU_XOR = 29;
parameter ALU_OR = 30;
parameter ALU_AND = 31;
parameter SET_DB_HIGH = 32;
parameter SET_DB_TO_ACC = 33;
parameter SET_SB_TO_SP = 34;
parameter SET_PSR_CARRY_TO_ALU_CARRY_OUT = 35;
parameter LOAD_SP = 36;
parameter LOAD_CARRY_PSR_FLAG = 37;
parameter LOAD_INTERUPT_PSR_FLAG = 38;
parameter LOAD_DECIMAL_PSR_FLAG = 39;
parameter LOAD_OVERFLOW_PSR_FLAG = 40;
parameter PSR_DATA_TO_LOAD = 41;
parameter SET_WRITE_FLAG = 42;
parameter FINAL_ADDRESSING = 43;


parameter A0 = 4'b000;
parameter A1 = 4'b001;
parameter A2 = 4'b010;
parameter A3 = 4'b011;