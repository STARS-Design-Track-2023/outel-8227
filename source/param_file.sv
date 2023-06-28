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
parameter NUMFLAGS = 128;
parameter SET_ADH_LOW = 0;
parameter SET_ADL_TO_DATA = 1;
parameter LOAD_ABL = 2;
parameter LOAD_ABH = 3;
parameter PC_INC = 4; //increments whatever is being loaded to PC
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
parameter ALU_R_SHIFT = 28;
parameter ALU_XOR = 29;
parameter ALU_OR = 30;
parameter ALU_AND = 31;
parameter SET_DB_HIGH = 32;
parameter SET_DB_TO_ACC = 33;
parameter SET_SB_TO_SP = 34;
parameter SET_PSR_CARRY_TO_ALU_CARRY_OUT = 35;
parameter LOAD_SP = 36;
parameter LOAD_CARRY_PSR_FLAG = 37; //Will load PSR_DATA_TO_LOAD into the PSR
parameter LOAD_INTERUPT_PSR_FLAG = 38; //Will load PSR_DATA_TO_LOAD into the PSR
parameter LOAD_DECIMAL_PSR_FLAG = 39; //Will load PSR_DATA_TO_LOAD into the PSR
parameter LOAD_OVERFLOW_PSR_FLAG = 40; //Will load 1 into the PSR's V (overflow) FlipFlop
parameter PSR_DATA_TO_LOAD = 41; //This is the data that will be loaded into the PSR by flags like LOAD_CARRY_PSR_FLAG,  LOAD_DECIMAL_PSR_FLAG, LOAD_INTERUPT_PSR_FLAG, LOAD_OVERFLOW_PSR_FLAG
parameter SET_WRITE_FLAG = 42;
parameter LOAD_DOR = 43;
parameter SET_ADL_TO_SP = 44;
parameter LOAD_PC = 45; //load from ADL else it just loads from itself
parameter SET_PSR_CARRY_TO_ALU_CARRY = 46;
parameter SET_PSR_OVERFLOW_TO_ALU_OVERFLOW = 47;
parameter WRITE_NEGATIVE_FLAG = 48;
parameter WRITE_ZERO_FLAG = 49;
parameter SET_ALU_DEC_TO_PSR_DEC = 50;
parameter SET_INPUT_B_TO_NOT_DB = 51;
parameter SET_INPUT_B_TO_ADL = 52;


parameter SET_PSR_TO_DB = 53;
parameter SET_PSR_C_TO_DB0 = 54; //Pushes the 0th bit on DB to the PSR's Carry Flag (ex: used in RTI)
parameter SET_PSR_Z_TO_DB1 = 55; //Pushes the 1st bit on DB to the PSR's Zero Flag (ex: used in RTI)
parameter SET_PSR_I_TO_DB2 = 56; //Pushes the 2nd bit on DB to the PSR's Interrupt Flag (ex: used in RTI)
parameter SET_PSR_D_TO_DB3 = 57; //Pushes the 3rd bit on DB to the PSR's Decimal Flag (ex: used in RTI)
parameter SET_PSR_V_TO_DB6 = 58; //Pushes the 4th bit on DB to the PSR's Overflow Flag (ex: used in RTI)
parameter SET_PSR_N_TO_DB7 = 59; //Pushes the 5th bit on DB to the PSR's Negative Flag (ex: used in RTI)
parameter SET_PSR_OUTPUT_BRK_HIGH = 60;
//Will set the BRK flag high on the output (both to DB and the control logic) for the current clock cycle
parameter SET_SB_HIGH = 61;
parameter SET_ADL_FF = 62;
parameter SET_ADL_FE = 63;
parameter SET_ADL_FD = 64;
parameter SET_ADL_FC = 65;
parameter SET_ADL_FB = 66;
parameter SET_ADL_FA = 67;
parameter SET_ADL_00 = 68;
parameter SET_ADH_FF = 69;


parameter SET_DB_TO_PCH = 70;
parameter SET_DB_TO_PSR = 71;
parameter SET_BREAK_LOW = 72;
parameter SET_DB_TO_PCL = 73;
parameter SET_BREAK_HIGH = 74;
parameter SET_NEGATIVE_FLAG_LOW = 75;
parameter SET_SB_TO_ADH = 76;
parameter SET_ADH_TO_ONE = 77;
<<<<<<< HEAD
parameter END_INSTRUCTION = 78;
parameter SET_FREE_CARRY_FLAG_TO_ALU = 79;
parameter SET_ALU_CARRY_TO_FREE_CARRY = 80;
parameter END_ADDRESSING = 81;
=======
parameter SET_FREE_CARRY_FLAG_TO_ALU = 79;
parameter SET_ALU_CARRY_TO_FREE_CARRY = 80;
parameter END_ADDRESSING = 81;
parameter END_INSTRUCTION = 78;
>>>>>>> 9f4aabda964631b18e0edb33bdaf4d63fdbf45c8

parameter A0 = 3'b00;
parameter A1 = 3'b01;
parameter A2 = 3'b10;
parameter A3 = 3'b11;

parameter T0 = 3'b000;
parameter T1 = 3'b001;
parameter T2 = 3'b010;
parameter T3 = 3'b011;
parameter T4 = 3'b100;
parameter T5 = 3'b101;
parameter T6 = 3'b110;

parameter ADC = 6'd1; // INSTRUCTION PARAMATERS
parameter AND = 6'd2;
parameter ASL = 6'd3;
parameter BCC = 6'd4;
parameter BCS = 6'd5;
parameter BEQ = 6'd6;
parameter BIT = 6'd7;
parameter BMI = 6'd8;
parameter BNE = 6'd9;
parameter BPL = 6'd10;
parameter BRK = 6'd11;
parameter BVC = 6'd12;
parameter BVS = 6'd13;
parameter CLC = 6'd14;
parameter CLD = 6'd15;
parameter CLI = 6'd16;
parameter CLV = 6'd17;
parameter CMP = 6'd18;
parameter CPX = 6'd19;
parameter CPY = 6'd20;
parameter DEC = 6'd21;
parameter DEX = 6'd22;
parameter DEY = 6'd23;
parameter EOR = 6'd24;
parameter INC = 6'd25;
parameter INX = 6'd26;
parameter INY = 6'd27;
parameter JMP = 6'd28;
parameter JSR = 6'd29;
parameter LDA = 6'd30;
parameter LDX = 6'd31;
parameter LDY = 6'd32;
parameter LSR = 6'd33;
parameter NOP = 6'd34;
parameter ORA = 6'd35;
parameter PHA = 6'd36;
parameter PHP = 6'd37;
parameter PLA = 6'd38;
parameter PLP = 6'd39;
parameter ROL = 6'd40;
parameter ROR = 6'd41;
parameter RTI = 6'd42;
parameter RTS = 6'd43;
parameter SBC = 6'd44;
parameter SEC = 6'd45;
parameter SED = 6'd46;
parameter SEI = 6'd47;
parameter STA = 6'd48;
parameter STO = 6'd49;
parameter STX = 6'd50;
parameter STY = 6'd51;
parameter TAX = 6'd52;
parameter TAY = 6'd53;
parameter TSX = 6'd54;
parameter TXA = 6'd55;
parameter TXS = 6'd56;
parameter ASLA =6'd57; // Start of instructions that were forgot
parameter ROLA = 6'd58;
parameter LSRA = 6'd59;
parameter RORA = 6'd60;
parameter TYA = 6'd61; // END OF INSTRUCTION PARAMETERS

parameter A = 4'd0;
parameter abs = 4'd1; // ADDRESSING PARAMETERS
parameter absX = 4'd2;
parameter absY = 4'd3;
parameter IMMEDIATE = 4'd4;
parameter impl = 4'd5;
parameter ind = 4'd6;
parameter Xind = 4'd7;
parameter indY= 4'd8;
parameter rel = 4'd9;
parameter zpg = 4'd10;
parameter zpgX = 4'd11;
parameter zpgY = 4'd12; // END OF ADDRESSING PARAMETERS

parameter INSTRUCTION = 1'b0;
parameter ADDRESS = 1'b1;
