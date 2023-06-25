`include "timing_generator.sv" 

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
parameter zpgY = 4'd12; 
parameter implied = 4'd13; // END OF ADDRESSING PARAMETERS

parameter NUMFLAGS = 127; // taken from Thomas

module setFlags(
input logic [5:0] instructionCode,
input logic [3:0] addressingCode,
input logic [2:0] addressTimingCode, opTimingCode,
input logic rst, clk,
output logic [NUMFLAGS - 1:0] outFlags
);

logic  [NUMFLAGS - 1:0] outputListAddressing [13:0] ;
logic  [NUMFLAGS - 1:0] outputListInstruction [61:0];
logic [2:0] currentTime;
logic isAddressing;
logic IS_STORE_ACC_INSTRUCT;
logic IS_STORE_X_INSTRUCT;
logic IS_STORE_Y_INSTRUCT;
logic passAddressing;

timing_generator u1(.timeOut(currentTime), .clk(clk), .addressTimingCode(addressTimingCode), .opTimingCode(opTimingCode), .rst(rst), .isAddressing(isAddressing), .passAddressing(passAddressing) );

always_comb begin : blockName
    
case(instructionCode) 
    STA: IS_STORE_ACC_INSTRUCT = 1'b1;
    STY: IS_STORE_X_INSTRUCT = 1'b1;
    STX: IS_STORE_Y_INSTRUCT = 1'b1;
    default: IS_STORE_ACC_INSTRUCT = 1'b0;
endcase

if(addressingCode == IMMEDIATE | addressingCode == implied | addressingCode == A) // bypasses Addressing
    passAddressing = 1'b1;
else
    passAddressing = 1'b0;


if(isAddressing & ~passAddressing) begin

case(addressingCode)
    abs: begin                                         // addressing instruction abs

            flags = 0;
            if(state == A0)begin
                //update address 
                outflags[PC_INC] = 1;
                outflags[SET_ADL_TO_PCL] = 1;
                outflags[LOAD_ABL] = 1;
                outflags[SET_ADH_TO_PCH] = 1;
                outflags[LOAD_ABH] = 1;
                //save lower address to ALU
                outflags[SET_DB_TO_DATA] = 1;
                outflags[SET_INPUT_B_TO_DB] = 1;
            end else if(state == A1)begin
                //set low address
                outflags[LOAD_ABL] = 1;
                outflags[SET_ADL_TO_ALU] = 1;
                //set high address
                outflags[SET_ADH_TO_DATA] = 1;
                outflags[LOAD_ABH] = 1;
                //funky store stuff
                outflags[SET_DB_TO_ACC] = IS_STORE_ACC_INSTRUCT;
                outflags[SET_DB_TO_SB] = IS_STORE_X_INSTRUCT | IS_STORE_Y_INSTRUCT;
                outflags[SET_SB_TO_X] = IS_STORE_X_INSTRUCT;
                outflags[SET_SB_TO_Y] = IS_STORE_Y_INSTRUCT;
                outflags[LOAD_DOR] = IS_STORE_ACC_INSTRUCT | IS_STORE_X_INSTRUCT | IS_STORE_Y_INSTRUCT;
            end

    end
    absX: begin                                        // addressing instruction absX

            flags = 0;
            if(state == A0)begin
                //Increment position
                outflags[PC_INC] = 1;
                outflags[LOAD_ABH] = 1;
                outflags[LOAD_ABL] = 1;
                outflags[SET_ADH_TO_PCH] = 1;
                outflags[SET_ADL_TO_PCL] = 1;
                //Add data to X
                outflags[LOAD_ALU] = 1;
                outflags[ALU_ADD] = 1;
                outflags[SET_DB_TO_DATA] = 1;
                outflags[SET_INPUT_B_TO_DB] = 1;
                outflags[SET_SB_TO_X] = 1;
                outflags[SET_INPUT_A_TO_SB] = 1;
            end else if(state == A1)begin
                //Move ALU output to ABL
                outflags[SET_ADL_TO_ALU] = 1;
                outflags[LOAD_ABL] = 1;
                //Add data to X
                outflags[LOAD_ALU] = 1;
                outflags[ALU_ADD] = 1;
                outflags[SET_DB_TO_DATA] = 1;
                outflags[SET_INPUT_B_TO_DB] = 1;
                outflags[SET_SB_TO_X] = 1;
                outflags[SET_INPUT_A_TO_SB] = 1;
            end else if(state == A2)begin
                //Move ALU output to ADL
                outflags[SET_SB_TO_ALU] = 1;
                outflags[SET_ADH_TO_SB] = 1;
                outflags[LOAD_ABH] = 1;
                //funky store stuff
                outflags[SET_DB_TO_ACC] = IS_STORE_ACC_INSTRUCT;
                outflags[LOAD_DOR] = IS_STORE_ACC_INSTRUCT;
            end 

    end
    absY: begin                                        // addressing instruction absY
    
            flags = 0;
            if(state == A0)begin
                //Increment position
                outflags[PC_INC] = 1;
                outflags[LOAD_ABH] = 1;
                outflags[LOAD_ABL] = 1;
                outflags[SET_ADH_TO_PCH] = 1;
                outflags[SET_ADL_TO_PCL] = 1;
                //Add data to X
                outflags[LOAD_ALU] = 1;
                outflags[ALU_ADD] = 1;
                outflags[SET_DB_TO_DATA] = 1;
                outflags[SET_INPUT_B_TO_DB] = 1;
                outflags[SET_SB_TO_Y] = 1;
                outflags[SET_INPUT_A_TO_SB] = 1;
            end else if(state == A1)begin
                //Move ALU output to ABL
                outflags[SET_ADL_TO_ALU] = 1;
                outflags[LOAD_ABL] = 1;
                //Add data to Y
                outflags[LOAD_ALU] = 1;
                outflags[ALU_ADD] = 1;
                outflags[SET_DB_TO_DATA] = 1;
                outflags[SET_INPUT_B_TO_DB] = 1;
                outflags[SET_SB_TO_Y] = 1;
                outflags[SET_INPUT_A_TO_SB] = 1;
            end else if(state == A2)begin
                //Move ALU output to ADL
                outflags[SET_SB_TO_ALU] = 1;
                outflags[SET_ADH_TO_SB] = 1;
                outflags[LOAD_ABH] = 1;
                //funky store stuff
                outflags[SET_DB_TO_ACC] = IS_STORE_ACC_INSTRUCT;
                outflags[LOAD_DOR] = IS_STORE_ACC_INSTRUCT;
            end

    end
    ind: begin                                         // addressing instruction ind
        outFlags = outputListAddressing[ind];
        addressTimingCode = T?;
    end
    Xind: begin                                        // addressing instruction Xind

            outflags = 0;
            if(state == A0)begin
                //Increment PC
                outflags[PC_INC] = 1;
                //Add data to X
                outflags[LOAD_ALU] = 1;
                outflags[ALU_ADD] = 1;
                outflags[SET_DB_TO_DATA] = 1;
                outflags[SET_INPUT_B_TO_DB] = 1;
                outflags[SET_SB_TO_X] = 1;
                outflags[SET_INPUT_A_TO_SB] = 1;
            end else if(state == A1)begin
                //Set Zero Page
                outflags[SET_ADH_LOW] = 1;
                outflags[LOAD_ABH] = 1;
                outflags[SET_ADL_TO_ALU] = 1;
                outflags[LOAD_ABL] = 1;
                //Increment position through ALU
                //bring ALU output to B
                outflags[SET_SB_TO_ALU] = 1;
                outflags[SET_DB_TO_SB] = 1;
                outflags[SET_INPUT_B_TO_DB] = 1;
                //Add B to 1
                outflags[SET_INPUT_A_TO_LOW] = 1;
                outflags[SET_ALU_CARRY_HIGH] = 1;
                outflags[ALU_ADD] = 1;
                outflags[LOAD_ALU] = 1;
            end else if(state == A2)begin
                //Set Zero Page
                outflags[SET_ADH_LOW] = 1;
                outflags[LOAD_ABH] = 1;
                outflags[SET_ADL_TO_ALU] = 1;
                outflags[LOAD_ABL] = 1;
                //Store data in ALU
                outflags[SET_DB_TO_DATA] = 1;
                outflags[SET_INPUT_B_TO_DB] = 1;
                outflags[SET_INPUT_A_TO_LOW] = 1;
                outflags[LOAD_ALU] = 1;
                outflags[ALU_ADD] = 1;
            end else if(state == A3)begin
                //Load read data values
                outflags[SET_ADH_TO_DATA] = 1;
                outflags[LOAD_ABH] = 1;
                outflags[SET_ADL_TO_ALU] = 1;
                outflags[LOAD_ABL] = 1;
                //funky store stuff
                outflags[SET_DB_TO_ACC] = IS_STORE_ACC_INSTRUCT;
                outflags[LOAD_DOR] = IS_STORE_ACC_INSTRUCT;
            end

    end
    indY: begin                                        // addressing instruction indY
 

            outflags = 0;
            if(state == A0)begin
                //Set Zero Page:00,Data0
                outFlags[SET_ADH_LOW] = 1;
                outFlags[LOAD_ABH] = 1;
                
                outFlags[SET_ADL_TO_DATA] = 1;
                outFlags[LOAD_ABL] = 1;
                //Increment position through ALU
                outFlags[SET_DB_TO_DATA] = 1;
                outFlags[SET_INPUT_B_TO_DB] = 1;

                outFlags[SET_INPUT_A_TO_LOW] = 1;
                outFlags[SET_ALU_CARRY_HIGH] = 1;

                outFlags[ALU_ADD] = 1;
                outFlags[LOAD_ALU] = 1;
            end else if(state == A1)begin
                //Set Zero Page:00,Data0+1
                outFlags[SET_ADH_LOW] = 1;
                outFlags[LOAD_ABH] = 1;
                
                outFlags[SET_ADL_TO_ALU] = 1;
                outFlags[LOAD_ABL] = 1;
                //Store data+Y in ALU
                outFlags[SET_DB_TO_DATA] = 1;
                outFlags[SET_INPUT_B_TO_DB] = 1;
                
                outFlags[SET_SB_TO_Y] = 1;
                outFlags[SET_INPUT_A_TO_SB] = 1;
                
                outFlags[LOAD_ALU] = 1;
                outFlags[ALU_ADD] = 1;
                outFlags[SET_FREE_CARRY_FLAG_TO_ALU] = 1;
            end else if(state == A2)begin
                //Set Zero Page:00,Data1+Y
                outFlags[SET_ADH_LOW] = 1;
                outFlags[LOAD_ABH] = 1;
                outFlags[SET_ADL_TO_ALU] = 1;
                outFlags[LOAD_ABL] = 1;
                
                //Add carry carry_to_high_op to current data(Data2)
                outFlags[SET_DB_TO_DATA] = 1;
                outFlags[SET_INPUT_B_TO_DB] = 1;
                
                outFlags[SET_INPUT_A_TO_LOW] = 1;
                outFlags[SET_ALU_CARRY_TO_FREE_CARRY] = 1;

                outFlags[LOAD_ALU] = 1;
                outFlags[ALU_ADD] = 1;
                
            end else if(state == A3)begin
                //Load data values:Data2+C,Data1+Y
                outFlags[SET_ADH_TO_DATA] = 1;
                outFlags[LOAD_ABH] = 1;
                outFlags[SET_ADL_TO_ALU] = 1;
                outFlags[LOAD_ABL] = 1;
                //funky store stuff
                outFlags[SET_DB_TO_ACC] = IS_STORE_ACC_INSTRUCT;
                outFlags[LOAD_DOR] = IS_STORE_ACC_INSTRUCT;
            end

    end
    zpg: begin                                         // addressing instruction zpg
            flags = 0;
            if(state == A0)begin
                //go to zero page
                outflags[SET_ADH_LOW] = 1;
                outflags[SET_ADL_TO_DATA] = 1;
                outflags[LOAD_ABH] = 1;
                outflags[LOAD_ABL] = 1;

                //funky store stuff
                outflags[SET_DB_TO_ACC] = IS_STORE_ACC_INSTRUCT;
                outflags[SET_DB_TO_SB] = IS_STORE_X_INSTRUCT | IS_STORE_Y_INSTRUCT;
                outflags[SET_SB_TO_X] = IS_STORE_X_INSTRUCT;
                outflags[SET_SB_TO_Y] = IS_STORE_Y_INSTRUCT;
                outflags[LOAD_DOR] = IS_STORE_ACC_INSTRUCT | IS_STORE_X_INSTRUCT | IS_STORE_Y_INSTRUCT;
            end
    end
    zpgX: begin                                        // addressing instruction zpgX

            outflags = 0;
            if(state == A0)begin
                //Add data to X
                outflags[LOAD_ALU] = 1;
                outflags[ALU_ADD] = 1;
                outflags[SET_DB_TO_DATA] = 1;
                outflags[SET_INPUT_B_TO_DB] = 1;
                outflags[SET_SB_TO_X] = 1;
                outflags[SET_INPUT_A_TO_SB] = 1;
            end else if(state == A1)begin
                //Set Zero Page
                outflags[SET_ADH_LOW] = 1;
                outflags[LOAD_ABH] = 1;
                outflags[SET_ADL_TO_ALU] = 1;
                outflags[LOAD_ABL] = 1;
                //funky store stuff
                outflags[SET_DB_TO_ACC] = IS_STORE_ACC_INSTRUCT;
                outflags[SET_DB_TO_SB] = IS_STORE_X_INSTRUCT | IS_STORE_Y_INSTRUCT;
                outflags[SET_SB_TO_X] = IS_STORE_X_INSTRUCT;
                outflags[SET_SB_TO_Y] = IS_STORE_Y_INSTRUCT;
                outflags[LOAD_DOR] = IS_STORE_ACC_INSTRUCT | IS_STORE_X_INSTRUCT | IS_STORE_Y_INSTRUCT;
            end

    end
    zpgY: begin                                        // addressing instruction zpgY

            flags = 0;
            if(state == A0)begin
                //Add data to Y
                outflags[LOAD_ALU] = 1;
                outflags[ALU_ADD] = 1;
                outflags[SET_DB_TO_DATA] = 1;
                outflags[SET_INPUT_B_TO_DB] = 1;
                outflags[SET_SB_TO_Y] = 1;
                outflags[SET_INPUT_A_TO_SB] = 1;
            end else if(state == A1)begin
                //Set Zero Page
                outflags[SET_ADH_LOW] = 1;
                outflags[LOAD_ABH] = 1;
                outflags[SET_ADL_TO_ALU] = 1;
                outflags[LOAD_ABL] = 1;
                //funky store stuff
                outflags[SET_DB_TO_ACC] = IS_STORE_ACC_INSTRUCT;
                outflags[SET_DB_TO_SB] = IS_STORE_X_INSTRUCT | IS_STORE_Y_INSTRUCT;
                outflags[SET_SB_TO_X] = IS_STORE_X_INSTRUCT;
                outflags[SET_SB_TO_Y] = IS_STORE_Y_INSTRUCT;
                outflags[LOAD_DOR] = IS_STORE_ACC_INSTRUCT | IS_STORE_X_INSTRUCT | IS_STORE_Y_INSTRUCT;
            end 

    end
    default: outFlags = 'bX;                           // code default
endcase

end
else begin

case(instructionCode)
    ADC: begin                                         // code ADC
    end
    AND: begin                                          // code AND
    end
    ASL: begin                                          // code ASL
    end
    BCC, BCS, BEQ, BMI, BNE, BPL, BVC, BVS: begin                                          // code BCC                  BRANCH CHECKING ONE THAT IS HARD
    
    case (state)
        T0: begin
            //Increment PC
            flags[PC_INC] = 1;

            //set ABH and ABL to PC
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;

            //Set B=PCL
            flags[SET_INPUT_B_TO_ADL] = 1;
            
            //Set A=Data
            flags[SET_DB_TO_DATA] = 1;
            flags[SET_SB_TO_DB] = 1;
            flags[SET_INPUT_A_TO_SB] = 1;
            
            //A+B=PCL+Data
            flags[ALU_ADD] = 1;
            flags[LOAD_ALU] = 1;
        end
        T1: begin
            if(JUMP) begin
                //Increment PC
                flags[PC_INC] = 1;

                //Move ALU to ABL/PCL
                flags[SET_ADL_TO_ALU] = 1;
                flags[SET_ADH_TO_PCH] = 1;
                flags[LOAD_ABL] = 1;
                flags[LOAD_PC] = 1;

                //ADD carry and ADH
                flags[SET_SB_TO_ADH] = 1;
                flags[SET_DB_TO_SB] = 1;
                flags[SET_INPUT_A_TO_LOW] = 1;
                flags[SET_INPUT_B_TO_DB] = 1;
                flags[SET_ALU_CARRY_TO_FREE_CARRY] = 1;
            end else begin
                //Increment PC
                flags[PC_INC] = 1;

                //set ABH and ABL to PC
                flags[SET_ADH_TO_PCH] = 1;
                flags[LOAD_ABH] = 1;
                flags[SET_ADL_TO_PCL] = 1;
                flags[LOAD_ABL] = 1;

                //Get ready to read next instruction
                flag[LOAD_INSTRUCT] = 1;
            end
        end
        T2: begin
            if(free_carry) begin
                //Increment PC
                flags[PC_INC] = 1;

                //Move ALU to ABH/PCH
                flags[SET_SB_TO_ALU] = 1;
                flags[SET_ADH_TO_SB] = 1;
                flags[SET_ADL_TO_PCL] = 1;
                flags[LOAD_PC] = 1;

            end else begin
                //Increment PC
                flags[PC_INC] = 1;

                //set ABH and ABL to PC
                flags[SET_ADH_TO_PCH] = 1;
                flags[LOAD_ABH] = 1;
                flags[SET_ADL_TO_PCL] = 1;
                flags[LOAD_ABL] = 1;

                //Get ready to read next instruction
                flag[LOAD_INSTRUCT] = 1;
            end
        end
        T3: begin
            //Increment PC
            flags[PC_INC] = 1;

            //set ABH and ABL to PC
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;

            //Get ready to read next instruction
            flag[LOAD_INSTRUCT] = 1;
        end
        default: flags = 0;
    endcase

    end
    BIT: begin                                          // code BIT
    end
    BRK: begin                                          // code BRK
    end
    CLC: begin                                          // code CLC
    end
    CLD: begin                                          // code CLD
    end
    CLI: begin                                          // code CLI
    end
    CLV: begin                                          // code CLV
    end
    CMP: begin                                          // code CMP
    end
    CPX: begin                                          // code CPX
    end
    CPY: begin                                          // code CPY
    end
    DEC: begin                                          // code DEC
    end
    DEX: begin                                          // code DEX
    end
    DEY: begin                                          // code DEY
    end
    EOR: begin                                          // code EOR
    end
    INC: begin                                          // code INC
    end
    INX: begin                                          // code INX
    end
    INY: begin                                          // code INY
    end
    JMP: begin                                          // code JMP
    end
    JSR: begin                                          // code JSR
    end
    LDA: begin                                          // code LDA
    end
    LDX: begin                                          // code LDX
    end
    LDY: begin                                          // code LDY
    end
    LSR: begin                                          // code LSR
    end
    NOP: begin                                          // code NOP
    end
    ORA: begin                                          // code ORA
    end
    PHA: begin                                          // code PHA
    end
    PHP: begin                                          // code PHP
    end
    PLA: begin                                          // code PLA
    end
    PLP: begin                                          // code PLP
    end
    ROL: begin                                          // code ROL
    end
    ROR: begin                                          // code ROR
    end
    RTI: begin                                          // code RTI
    end
    RTS: begin                                          // code RTS
    end
    SBC: begin                                          // code SBC
    end
    SEC: begin                                          // code SEC
    end
    SED: begin                                          // code SED
    end
    SEI: begin                                          // code SEI
    end
    STA: begin                                          // code STA
    end
    STX: begin                                          // code STX
    end
    STY: begin                                          // code STY
    end
    TAX: begin                                          // code TAX
    end
    TAY: begin                                          // code TAY
    end
    TSX: begin                                          // code TSX
    end
    TXA: begin                                          // code TXA
    end
    TXS: begin                                          // code TXS
    end
    ASLA: begin                                          // code ASLA
    end
    ROLA: begin                                          // code ROLA
    end
    LSRA: begin                                          // code LSRA
    end
    RORA: begin                                          // code RORA
    end
    TYA: begin                                          // code TYA
    end
endcase

end

end

endmodule
