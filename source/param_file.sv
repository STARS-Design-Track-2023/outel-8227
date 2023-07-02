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
`define NUMFLAGS 77
`define SET_ADH_LOW 0
`define SET_ADL_TO_DATA 1
`define LOAD_ABL 2
`define LOAD_ABH 3
`define PC_INC 4 //increments whatever is being loaded to PC
`define PC_DEC 5
`define SET_ADL_TO_PCL 6
`define SET_ADH_TO_PCH 7
`define SET_DB_TO_DATA 8
`define SET_INPUT_B_TO_DB 9
`define SET_SB_TO_DB 10
`define SET_ADL_TO_ALU 11
`define SET_ADH_TO_SB 12
`define SET_INPUT_A_TO_SB 13
`define SET_SB_TO_X 14
`define SET_SB_TO_Y 15
`define SET_SB_TO_ACC 16
`define SET_SB_TO_ALU 17
`define ALU_ADD 18
`define SET_INPUT_A_TO_LOW 19
`define SET_ALU_CARRY_HIGH 20
`define SET_ADH_TO_DATA 21
`define SET_ALU_CARRY_TO_PSR_CARRY 22
`define LOAD_ALU 23
`define LOAD_X 24
`define LOAD_Y 25
`define SET_DB_TO_SB 26
`define LOAD_ACC 27
`define ALU_R_SHIFT 28
`define ALU_XOR 29
`define ALU_OR 30
`define ALU_AND 31
`define SET_DB_HIGH 32
`define SET_DB_TO_ACC 33
`define SET_SB_TO_SP 34
`define SET_BRANCH_PAGE_CROSS_FLAGS 35
`define LOAD_SP 36
`define LOAD_CARRY_PSR_FLAG 37 //Will load PSR_DATA_TO_LOAD into the PSR
`define LOAD_INTERUPT_PSR_FLAG 38 //Will load PSR_DATA_TO_LOAD into the PSR
`define LOAD_DECIMAL_PSR_FLAG 39 //Will load PSR_DATA_TO_LOAD into the PSR
`define LOAD_OVERFLOW_PSR_FLAG 40 //Will load 1 into the PSR's V (overflow) FlipFlop
`define PSR_DATA_TO_LOAD 41 //This is the data that will be loaded into the PSR by flags like LOAD_CARRY_PSR_FLAG,  LOAD_DECIMAL_PSR_FLAG, LOAD_INTERUPT_PSR_FLAG, LOAD_OVERFLOW_PSR_FLAG
`define END_ADDRESSING 42
`define LOAD_DOR 43
`define SET_ADL_TO_SP 44
`define LOAD_PC 45 //load from ADL else it just loads from itself
`define SET_PSR_CARRY_TO_ALU_CARRY 46
`define SET_PSR_OVERFLOW_TO_ALU_OVERFLOW 47
`define SET_ALU_CARRY_TO_FREE_CARRY 48
`define WRITE_ZERO_FLAG 49
`define SET_ALU_DEC_TO_PSR_DEC 50
`define SET_INPUT_B_TO_NOT_DB 51
`define SET_INPUT_B_TO_ADL 52


`define SET_PSR_TO_DB 53
`define SET_PSR_C_TO_DB0 54 //Pushes the 0th bit on DB to the PSR's Carry Flag (ex: used in RTI)
`define SET_PSR_Z_TO_DB1 55 //Pushes the 1st bit on DB to the PSR's Zero Flag (ex: used in RTI)
`define SET_PSR_I_TO_DB2 56 //Pushes the 2nd bit on DB to the PSR's Interrupt Flag (ex: used in RTI)
`define SET_PSR_D_TO_DB3 57 //Pushes the 3rd bit on DB to the PSR's Decimal Flag (ex: used in RTI)
`define SET_PSR_V_TO_DB6 58 //Pushes the 4th bit on DB to the PSR's Overflow Flag (ex: used in RTI)
`define SET_PSR_N_TO_DB7 59 //Pushes the 5th bit on DB to the PSR's Negative Flag (ex: used in RTI)
`define SET_PSR_OUTPUT_BRK_HIGH 60
//Will set the BRK flag high on the output (both to DB and the control logic) for the current clock cycle
`define SET_SB_HIGH 61
`define SET_ADL_FF 62
`define SET_ADL_FE 63
`define SET_ADL_FD 64
`define SET_ADL_FC 65
`define SET_ADL_FB 66
`define SET_ADL_FA 67
`define SET_ADL_00 68
`define SET_ADH_FF 69
`define SET_DB_TO_PCH 70
`define SET_DB_TO_PSR 71
`define SET_FREE_CARRY_FLAG_TO_ALU 72
`define SET_DB_TO_PCL 73
`define SET_SB_TO_ADH 74
`define SET_ADH_TO_ONE 75
`define END_INSTRUCTION 76

`define A0 3'b00
`define A1 3'b01
`define A2 3'b10
`define A3 3'b11

`define T0 3'b000
`define T1 3'b001
`define T2 3'b010
`define T3 3'b011
`define T4 3'b100
`define T5 3'b101
`define T6 3'b110

`define ADC 6'd1 // INSTRUCTION PARAMATERS
`define AND 6'd2
`define ASL 6'd3
`define BCC 6'd4
`define BCS 6'd5
`define BEQ 6'd6
`define BIT 6'd7
`define BMI 6'd8
`define BNE 6'd9
`define BPL 6'd10
`define BRK 6'd11
`define BVC 6'd12
`define BVS 6'd13
`define CLC 6'd14
`define CLD 6'd15
`define CLI 6'd16
`define CLV 6'd17
`define CMP 6'd18
`define CPX 6'd19
`define CPY 6'd20
`define DEC 6'd21
`define DEX 6'd22
`define DEY 6'd23
`define EOR 6'd24
`define INC 6'd25
`define INX 6'd26
`define INY 6'd27
`define JMP 6'd28
`define JSR 6'd29
`define LDA 6'd30
`define LDX 6'd31
`define LDY 6'd32
`define LSR 6'd33
`define NOP 6'd34
`define ORA 6'd35
`define PHA 6'd36
`define PHP 6'd37
`define PLA 6'd38
`define PLP 6'd39
`define ROL 6'd40
`define ROR 6'd41
`define RTI 6'd42
`define RTS 6'd43
`define SBC 6'd44
`define SEC 6'd45
`define SED 6'd46
`define SEI 6'd47
`define STA 6'd48
`define STO 6'd49
`define STX 6'd50
`define STY 6'd51
`define TAX 6'd52
`define TAY 6'd53
`define TSX 6'd54
`define TXA 6'd55
`define TXS 6'd56
`define ASLA 6'd57 // Start of instructions that were forgot
`define ROLA 6'd58
`define LSRA 6'd59
`define RORA 6'd60
`define TYA 6'd61 // END OF INSTRUCTION PARAMETERS

`define A 4'd0
`define abs 4'd1 // ADDRESSING PARAMETERS
`define absX 4'd2
`define absY 4'd3
`define IMMEDIATE 4'd4
`define impl 4'd5
`define ind 4'd6
`define Xind 4'd7
`define indY 4'd8
`define rel 4'd9
`define zpg 4'd10
`define zpgX 4'd11
`define zpgY 4'd12 // END OF ADDRESSING PARAMETERS

`define INSTRUCTION 1'b0
`define ADDRESS 1'b1

`define DECODER_BASE_ADDRESS 16'H00 // for seven_seg_decoder
