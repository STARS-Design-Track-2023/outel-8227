`ifndef NUMFLAGS
`include "source/param_file.sv"
`endif
module demux(
    input logic [5:0] preFFInstructionCode,
    input logic [3:0] preFFAddressingCode,
    input logic nrst, clk, nmi, irq, reset, PSR_C, PSR_N, PSR_V, PSR_Z,
    input logic getInstructionPostInjection,
    output logic getInstructionPreInjection,
    output logic [`NUMFLAGS - 1:0] outflags,
    output logic load_psr_I, psr_data_to_load,
    input logic setInterruptFlag,
    input logic enableFFs,
    input logic branchForwardFF, branchBackwardFF,
    output logic readNotWrite
);

logic [2:0] state;
logic isAddressing;
logic IS_STORE_ACC_INSTRUCT;
logic IS_STORE_X_INSTRUCT;
logic IS_STORE_Y_INSTRUCT;
logic passAddressing;
logic jump; // to be fixed later // was kind of fixed later
logic [5:0] instructionCode;
logic [3:0] addressingCode;

assign getInstructionPreInjection = outflags[`END_INSTRUCTION]; // output flag to handle reset injection

assign jump = ((instructionCode == `BCC) & (!PSR_C)) | // eww
              ((instructionCode == `BCS) & (PSR_C))  |
              ((instructionCode == `BEQ) & (PSR_Z))  |
              ((instructionCode == `BMI) & (PSR_N))  |
              ((instructionCode == `BNE) & (!PSR_Z)) |
              ((instructionCode == `BPL) & (!PSR_N)) |
              ((instructionCode == `BVC) & (!PSR_V)) |
              ((instructionCode == `BVS) & (PSR_V));


state_machine state_machine(
    .clk(clk),
    .nrst(nrst),
    .enableFFs(enableFFs),
    .noAddressing(passAddressing),
    .getInstruction(getInstructionPostInjection),
    .endAddressing(outflags[`END_ADDRESSING]),
    .decodedInstruction(preFFInstructionCode),
    .decodedAddress(preFFAddressingCode),
    .currentInstruction(instructionCode),
    .currentAddress(addressingCode),
    .timeState(state),
    .mode(isAddressing)
);

always_comb begin : passAddressingAssignment
    if(addressingCode == `IMMEDIATE | addressingCode == `impl | addressingCode == `rel | addressingCode == `A) // bypasses Addressing (impl from param_file)
        passAddressing = 1'b1;
    else
        passAddressing = 1'b0;
end

always_comb begin : blockName
    IS_STORE_ACC_INSTRUCT = 1'b0;
    IS_STORE_X_INSTRUCT = 1'b0;
    IS_STORE_Y_INSTRUCT = 1'b0;
    load_psr_I = 1'b0;
    psr_data_to_load = 1'b0;

    case(instructionCode) 
        `STA: IS_STORE_ACC_INSTRUCT = 1'b1;
        `STX: IS_STORE_X_INSTRUCT = 1'b1;
        `STY: IS_STORE_Y_INSTRUCT = 1'b1;
        default: IS_STORE_ACC_INSTRUCT = 1'b0;
    endcase

    outflags = 0;
    if(isAddressing & ~passAddressing) begin

        case(addressingCode)
            `abs: begin                                         // addressing instruction kbs

                    outflags = 0;
                    if(state == `A0)begin
                        //update address 
                        outflags[`PC_INC] = 1;
                        outflags[`SET_ADL_TO_PCL] = 1;
                        outflags[`LOAD_ABL] = 1;
                        outflags[`SET_ADH_TO_PCH] = 1;
                        outflags[`LOAD_ABH] = 1;
                        //save lower address to ALU
                        outflags[`SET_DB_TO_DATA] = 1;
                        outflags[`SET_INPUT_B_TO_DB] = 1;
                        //DATA+0 = ALU'
                        outflags[`SET_INPUT_A_TO_LOW] = 1;
                        outflags[`ALU_ADD] = 1;
                        outflags[`LOAD_ALU] = 1;
                    end else if(state == `A1)begin
                        //set low address
                        if(instructionCode == `JMP) begin
                            outflags[`LOAD_PC] = 1;
                            outflags[`PC_INC] = 1;
                        end else begin
                            outflags[`LOAD_PC] = 0;
                            outflags[`PC_INC] = 0;
                        end
                        outflags[`LOAD_ABL] = 1;
                        outflags[`SET_ADL_TO_ALU] = 1;
                        //set high address
                        outflags[`SET_ADH_TO_DATA] = 1;
                        outflags[`LOAD_ABH] = 1;
                        //funky store stuff
                        outflags[`SET_DB_TO_ACC] = IS_STORE_ACC_INSTRUCT;
                        outflags[`SET_DB_TO_SB] = IS_STORE_X_INSTRUCT | IS_STORE_Y_INSTRUCT;
                        outflags[`SET_SB_TO_X] = IS_STORE_X_INSTRUCT;
                        outflags[`SET_SB_TO_Y] = IS_STORE_Y_INSTRUCT;
                        outflags[`LOAD_DOR] = IS_STORE_ACC_INSTRUCT | IS_STORE_X_INSTRUCT | IS_STORE_Y_INSTRUCT;
                        outflags[`END_ADDRESSING] = 1'b1;

                    end

            end
            `absX: begin                                        // addressing instruction absX

                    outflags = 0;
                    if(state == `A0)begin
                        //Increment position
                        outflags[`PC_INC] = 1;
                        outflags[`LOAD_ABH] = 1;
                        outflags[`LOAD_ABL] = 1;
                        outflags[`SET_ADH_TO_PCH] = 1;
                        outflags[`SET_ADL_TO_PCL] = 1;
                        //Add data to X
                        outflags[`LOAD_ALU] = 1;
                        outflags[`ALU_ADD] = 1;
                        outflags[`SET_DB_TO_DATA] = 1;
                        outflags[`SET_INPUT_B_TO_DB] = 1;
                        outflags[`SET_SB_TO_X] = 1;
                        outflags[`SET_INPUT_A_TO_SB] = 1;
                        outflags[`SET_FREE_CARRY_FLAG_TO_ALU] = 1;
                    end else if(state == `A1)begin
                        //Move ALU output to ABL
                        outflags[`SET_ADL_TO_ALU] = 1;
                        outflags[`LOAD_ABL] = 1;
                        //Add data to X
                        outflags[`LOAD_ALU] = 1;
                        outflags[`ALU_ADD] = 1;
                        outflags[`SET_DB_TO_DATA] = 1;
                        outflags[`SET_INPUT_B_TO_DB] = 1;
                        outflags[`SET_INPUT_A_TO_LOW] = 1;
                        outflags[`SET_ALU_CARRY_TO_FREE_CARRY] = 1;
                    end else if(state == `A2)begin
                        //Move ALU output to ADL
                        outflags[`SET_SB_TO_ALU] = 1;
                        outflags[`SET_ADH_TO_SB] = 1;
                        outflags[`LOAD_ABH] = 1;
                        //funky store stuff
                        outflags[`SET_DB_TO_ACC] = IS_STORE_ACC_INSTRUCT;
                        outflags[`LOAD_DOR] = IS_STORE_ACC_INSTRUCT;

                        outflags[`END_ADDRESSING] = 1'b1; // signal to end addressing
                    end 

            end
            `absY: begin                                        // addressing instruction absY
            
                    outflags = 0;
                    if(state == `A0)begin
                        //Increment position
                        outflags[`PC_INC] = 1;
                        outflags[`LOAD_ABH] = 1;
                        outflags[`LOAD_ABL] = 1;
                        outflags[`SET_ADH_TO_PCH] = 1;
                        outflags[`SET_ADL_TO_PCL] = 1;
                        //Add data to X
                        outflags[`LOAD_ALU] = 1;
                        outflags[`ALU_ADD] = 1;
                        outflags[`SET_DB_TO_DATA] = 1;
                        outflags[`SET_INPUT_B_TO_DB] = 1;
                        outflags[`SET_SB_TO_Y] = 1;
                        outflags[`SET_INPUT_A_TO_SB] = 1;
                        outflags[`SET_FREE_CARRY_FLAG_TO_ALU] = 1;
                    end else if(state == `A1)begin
                        //Move ALU output to ABL
                        outflags[`SET_ADL_TO_ALU] = 1;
                        outflags[`LOAD_ABL] = 1;
                        //Add data to Y
                        outflags[`LOAD_ALU] = 1;
                        outflags[`ALU_ADD] = 1;
                        outflags[`SET_DB_TO_DATA] = 1;
                        outflags[`SET_INPUT_B_TO_DB] = 1;
                        outflags[`SET_INPUT_A_TO_LOW] = 1;
                        outflags[`SET_ALU_CARRY_TO_FREE_CARRY] = 1;
                    end else if(state == `A2)begin
                        //Move ALU output to ADL
                        outflags[`SET_SB_TO_ALU] = 1;
                        outflags[`SET_ADH_TO_SB] = 1;
                        outflags[`LOAD_ABH] = 1;
                        //funky store stuff
                        outflags[`SET_DB_TO_ACC] = IS_STORE_ACC_INSTRUCT;
                        outflags[`LOAD_DOR] = IS_STORE_ACC_INSTRUCT;

                        outflags[`END_ADDRESSING] = 1'b1; // signal to end addressing
                    end

            end
            `ind: begin                                         // addressing instruction ind
            
                    outflags = 0;
                    if(state == `A0)begin
                        //Increment PC
                        outflags[`PC_INC] = 1;
                        //Load PC into Address Bus
                        outflags[`LOAD_ABH] = 1;
                        outflags[`LOAD_ABL] = 1;
                        outflags[`SET_ADH_TO_PCH] = 1;
                        outflags[`SET_ADL_TO_PCL] = 1;
                        //load data into ALU B
                        outflags[`LOAD_ALU] = 1;
                        outflags[`ALU_ADD] = 1;
                        outflags[`SET_DB_TO_DATA] = 1;
                        outflags[`SET_INPUT_B_TO_DB] = 1;
                        outflags[`SET_INPUT_A_TO_LOW] = 1;
                    end else if(state == `A1)begin
                        //Increment PC
                        outflags[`PC_INC] = 1;
                        outflags[`LOAD_PC] = 1;
                        //Set ABH to DATA
                        outflags[`SET_ADH_TO_DATA] = 1;
                        outflags[`LOAD_ABH] = 1;
                        //load ABL with ALU
                        outflags[`SET_ADL_TO_ALU] = 1;
                        outflags[`LOAD_ABL] = 1;

                    end else if(state == `A2)begin
                        //Increment PC
                        outflags[`PC_INC] = 1;
                        //Load PC into Address Bus
                        outflags[`LOAD_ABH] = 1;
                        outflags[`LOAD_ABL] = 1;
                        outflags[`SET_ADH_TO_PCH] = 1;
                        outflags[`SET_ADL_TO_PCL] = 1;
                        //load data into ALU B
                        outflags[`LOAD_ALU] = 1;
                        outflags[`ALU_ADD] = 1;
                        outflags[`SET_DB_TO_DATA] = 1;
                        outflags[`SET_INPUT_B_TO_DB] = 1;
                        outflags[`SET_INPUT_A_TO_LOW] = 1;

                    end else if(state == `A3)begin
                        //Increment PC
                        outflags[`PC_INC] = 1;
                        outflags[`LOAD_PC] = 1;
                        //Set ABH to DATA
                        outflags[`SET_ADH_TO_DATA] = 1;
                        outflags[`LOAD_ABH] = 1;
                        //load ABL with ALU
                        outflags[`SET_ADL_TO_ALU] = 1;
                        outflags[`LOAD_ABL] = 1;

                        outflags[`END_ADDRESSING] = 1'b1; // signal to end addressing
                    end

            end
            `Xind: begin                                        // addressing instruction Xind

                    outflags = 0;
                    if(state == `A0)begin
                        //Add data to X
                        outflags[`LOAD_ALU] = 1;
                        outflags[`ALU_ADD] = 1;
                        outflags[`SET_DB_TO_DATA] = 1;
                        outflags[`SET_INPUT_B_TO_DB] = 1;
                        outflags[`SET_SB_TO_X] = 1;
                        outflags[`SET_INPUT_A_TO_SB] = 1;
                    end else if(state == `A1)begin
                        //Set Zero Page
                        outflags[`SET_ADH_LOW] = 1;
                        outflags[`LOAD_ABH] = 1;
                        outflags[`SET_ADL_TO_ALU] = 1;
                        outflags[`LOAD_ABL] = 1;
                        //Increment position through ALU
                        //bring ALU output to B
                        outflags[`SET_SB_TO_ALU] = 1;
                        outflags[`SET_DB_TO_SB] = 1;
                        outflags[`SET_INPUT_B_TO_DB] = 1;
                        //Add B to 1
                        outflags[`SET_INPUT_A_TO_LOW] = 1;
                        outflags[`SET_ALU_CARRY_HIGH] = 1;
                        outflags[`ALU_ADD] = 1;
                        outflags[`LOAD_ALU] = 1;
                    end else if(state == `A2)begin
                        //Set Zero Page
                        outflags[`SET_ADH_LOW] = 1;
                        outflags[`LOAD_ABH] = 1;
                        outflags[`SET_ADL_TO_ALU] = 1;
                        outflags[`LOAD_ABL] = 1;
                        //Store data in ALU
                        outflags[`SET_DB_TO_DATA] = 1;
                        outflags[`SET_INPUT_B_TO_DB] = 1;
                        outflags[`SET_INPUT_A_TO_LOW] = 1;
                        outflags[`LOAD_ALU] = 1;
                        outflags[`ALU_ADD] = 1;
                    end else if(state == `A3)begin
                        //Load read data values
                        outflags[`SET_ADH_TO_DATA] = 1;
                        outflags[`LOAD_ABH] = 1;
                        outflags[`SET_ADL_TO_ALU] = 1;
                        outflags[`LOAD_ABL] = 1;
                        //funky store stuff
                        outflags[`SET_DB_TO_ACC] = IS_STORE_ACC_INSTRUCT;
                        outflags[`LOAD_DOR] = IS_STORE_ACC_INSTRUCT;

                        outflags[`END_ADDRESSING] = 1'b1; // signal to end addressing
                    end

            end
            `indY: begin                                        // addressing instruction indY
        

                    outflags = 0;
                    if(state == `A0)begin
                        //Set Zero Page:00,Data0
                        outflags[`SET_ADH_LOW] = 1;
                        outflags[`LOAD_ABH] = 1;
                        
                        outflags[`SET_ADL_TO_DATA] = 1;
                        outflags[`LOAD_ABL] = 1;
                        //Increment position through ALU
                        outflags[`SET_DB_TO_DATA] = 1;
                        outflags[`SET_INPUT_B_TO_DB] = 1;

                        outflags[`SET_INPUT_A_TO_LOW] = 1;
                        outflags[`SET_ALU_CARRY_HIGH] = 1;

                        outflags[`ALU_ADD] = 1;
                        outflags[`LOAD_ALU] = 1;
                    end else if(state == `A1)begin
                        //Set Zero Page:00,Data0+1
                        outflags[`SET_ADH_LOW] = 1;
                        outflags[`LOAD_ABH] = 1;
                        
                        outflags[`SET_ADL_TO_ALU] = 1;
                        outflags[`LOAD_ABL] = 1;
                        //Store data+Y in ALU
                        outflags[`SET_DB_TO_DATA] = 1;
                        outflags[`SET_INPUT_B_TO_DB] = 1;
                        
                        outflags[`SET_SB_TO_Y] = 1;
                        outflags[`SET_INPUT_A_TO_SB] = 1;
                        
                        outflags[`LOAD_ALU] = 1;
                        outflags[`ALU_ADD] = 1;
                        outflags[`SET_FREE_CARRY_FLAG_TO_ALU] = 1;
                    end else if(state == `A2)begin
                        //Set Zero Page:00,Data1+Y
                        outflags[`SET_ADH_LOW] = 1;
                        outflags[`LOAD_ABH] = 1;
                        outflags[`SET_ADL_TO_ALU] = 1;
                        outflags[`LOAD_ABL] = 1;
                        
                        //Add carry carry_to_high_op to current data(Data2)
                        outflags[`SET_DB_TO_DATA] = 1;
                        outflags[`SET_INPUT_B_TO_DB] = 1;
                        
                        outflags[`SET_INPUT_A_TO_LOW] = 1;
                        outflags[`SET_ALU_CARRY_TO_FREE_CARRY] = 1;

                        outflags[`LOAD_ALU] = 1;
                        outflags[`ALU_ADD] = 1;
                        
                    end else if(state == `A3)begin
                        //Load data values:Data2+C,Data1+Y

                        outflags[`SET_SB_TO_ALU] = 1;
                        outflags[`SET_ADH_TO_SB] = 1;
                        outflags[`LOAD_ABH] = 1;

                        // outflags[`SET_ADH_TO_DATA] = 1;
                        // outflags[`LOAD_ABH] = 1;
                        // outflags[`SET_ADL_TO_ALU] = 1;
                        // outflags[`LOAD_ABL] = 1;
                        //funky store stuff
                        outflags[`SET_DB_TO_ACC] = IS_STORE_ACC_INSTRUCT;
                        outflags[`LOAD_DOR] = IS_STORE_ACC_INSTRUCT;

                        outflags[`END_ADDRESSING] = 1'b1; // signal to end addressing
                    end

            end
            `zpg: begin                                         // addressing instruction zpg
                    outflags = 0;
                    if(state == `A0)begin
                        //go to zero page
                        outflags[`SET_ADH_LOW] = 1;
                        outflags[`SET_ADL_TO_DATA] = 1;
                        outflags[`LOAD_ABH] = 1;
                        outflags[`LOAD_ABL] = 1;

                        //funky store stuff
                        outflags[`SET_DB_TO_ACC] = IS_STORE_ACC_INSTRUCT;
                        outflags[`SET_DB_TO_SB] = IS_STORE_X_INSTRUCT | IS_STORE_Y_INSTRUCT;
                        outflags[`SET_SB_TO_X] = IS_STORE_X_INSTRUCT;
                        outflags[`SET_SB_TO_Y] = IS_STORE_Y_INSTRUCT;
                        outflags[`LOAD_DOR] = IS_STORE_ACC_INSTRUCT | IS_STORE_X_INSTRUCT | IS_STORE_Y_INSTRUCT;

                        outflags[`END_ADDRESSING] = 1'b1; // signal to end addressing
                    end
            end
            `zpgX: begin                                        // addressing instruction zpgX

                    outflags = 0;
                    if(state == `A0)begin
                        //Add data to X
                        outflags[`LOAD_ALU] = 1;
                        outflags[`ALU_ADD] = 1;
                        outflags[`SET_DB_TO_DATA] = 1;
                        outflags[`SET_INPUT_B_TO_DB] = 1;
                        outflags[`SET_SB_TO_X] = 1;
                        outflags[`SET_INPUT_A_TO_SB] = 1;
                    end else if(state == `A1)begin
                        //Set Zero Page
                        outflags[`SET_ADH_LOW] = 1;
                        outflags[`LOAD_ABH] = 1;
                        outflags[`SET_ADL_TO_ALU] = 1;
                        outflags[`LOAD_ABL] = 1;
                        //funky store stuff
                        outflags[`SET_DB_TO_ACC] = IS_STORE_ACC_INSTRUCT;
                        outflags[`SET_DB_TO_SB] = IS_STORE_X_INSTRUCT | IS_STORE_Y_INSTRUCT;
                        outflags[`SET_SB_TO_X] = IS_STORE_X_INSTRUCT;
                        outflags[`SET_SB_TO_Y] = IS_STORE_Y_INSTRUCT;
                        outflags[`LOAD_DOR] = IS_STORE_ACC_INSTRUCT | IS_STORE_X_INSTRUCT | IS_STORE_Y_INSTRUCT;

                        outflags[`END_ADDRESSING] = 1'b1; // signal to end addressing
                    end

            end
            `zpgY: begin                                        // addressing instruction zpgY

                    outflags = 0;
                    if(state == `A0)begin
                        //Add data to Y
                        outflags[`LOAD_ALU] = 1;
                        outflags[`ALU_ADD] = 1;
                        outflags[`SET_DB_TO_DATA] = 1;
                        outflags[`SET_INPUT_B_TO_DB] = 1;
                        outflags[`SET_SB_TO_Y] = 1;
                        outflags[`SET_INPUT_A_TO_SB] = 1;
                    end else if(state == `A1)begin
                        //Set Zero Page
                        outflags[`SET_ADH_LOW] = 1;
                        outflags[`LOAD_ABH] = 1;
                        outflags[`SET_ADL_TO_ALU] = 1;
                        outflags[`LOAD_ABL] = 1;
                        //funky store stuff
                        outflags[`SET_DB_TO_ACC] = IS_STORE_ACC_INSTRUCT;
                        outflags[`SET_DB_TO_SB] = IS_STORE_X_INSTRUCT | IS_STORE_Y_INSTRUCT;
                        outflags[`SET_SB_TO_X] = IS_STORE_X_INSTRUCT;
                        outflags[`SET_SB_TO_Y] = IS_STORE_Y_INSTRUCT;
                        outflags[`LOAD_DOR] = IS_STORE_ACC_INSTRUCT | IS_STORE_X_INSTRUCT | IS_STORE_Y_INSTRUCT;

                        outflags[`END_ADDRESSING] = 1'b1; // signal to end addressing
                    end 

            end
            default: outflags = 0;
        endcase

    end
    else 
    begin

        case(instructionCode)
            `ADC: begin                                         // code ADC
            
            outflags = 0;
            case (state)
                `T0: begin
                    //Increment PC
                    outflags[`PC_INC] = 1;

                    //set ABH and ABL to PC
                    outflags[`SET_ADH_TO_PCH] = 1;
                    outflags[`LOAD_ABH] = 1;
                    outflags[`SET_ADL_TO_PCL] = 1;
                    outflags[`LOAD_ABL] = 1;

                    //Set input b
                    outflags[`SET_DB_TO_DATA] = 1;
                    outflags[`SET_INPUT_B_TO_DB] = 1;

                    //set carry
                    outflags[`SET_ALU_CARRY_TO_PSR_CARRY] = 1;
                    outflags[`SET_ALU_DEC_TO_PSR_DEC] = 1;

                    //set input a
                    outflags[`SET_SB_TO_ACC] = 1;
                    outflags[`SET_INPUT_A_TO_SB] = 1;

                    //add ACC+C+DATA
                    outflags[`ALU_ADD] = 1;
                    outflags[`LOAD_ALU] = 1;
                    outflags[`SET_PSR_CARRY_TO_ALU_CARRY] = 1;
                    outflags[`SET_PSR_OVERFLOW_TO_ALU_OVERFLOW] = 1;
                
                end
                `T1: begin
                    //Increment PC
                    outflags[`PC_INC] = 1;

                    //set ABH and ABL to PC
                    outflags[`SET_ADH_TO_PCH] = 1;
                    outflags[`LOAD_ABH] = 1;
                    outflags[`SET_ADL_TO_PCL] = 1;
                    outflags[`LOAD_ABL] = 1;

                    //Move ALU to ACC
                    outflags[`SET_SB_TO_ALU] = 1;
                    outflags[`SET_DB_TO_SB] = 1;
                    outflags[`LOAD_ACC] = 1;

                    // //Set PSR from ALU outflags
                    
                    outflags[`WRITE_ZERO_FLAG] = 1;
                    outflags[`SET_PSR_N_TO_DB7] = 1;
                    outflags[`END_INSTRUCTION] = 1'b1; // signal to end the instruction
                end
                default: outflags = 0;
            endcase

            end
            `AND: begin                                          // code AND

            outflags = 0;
            case (state)
                `T0: begin
                    //Increment PC
                    outflags[`PC_INC] = 1;

                    //set ABH and ABL to PC
                    outflags[`SET_ADH_TO_PCH] = 1;
                    outflags[`LOAD_ABH] = 1;
                    outflags[`SET_ADL_TO_PCL] = 1;
                    outflags[`LOAD_ABL] = 1;

                    //Set input b
                    outflags[`SET_DB_TO_DATA] = 1;
                    outflags[`SET_INPUT_B_TO_DB] = 1;

                    //set input a
                    outflags[`SET_SB_TO_ACC] = 1;
                    outflags[`SET_INPUT_A_TO_SB] = 1;

                    //add ACC+C+DATA
                    outflags[`ALU_AND] = 1;
                    outflags[`LOAD_ALU] = 1;
                
                end
                `T1: begin
                    //Increment PC
                    outflags[`PC_INC] = 1;

                    //set ABH and ABL to PC
                    outflags[`SET_ADH_TO_PCH] = 1;
                    outflags[`LOAD_ABH] = 1;
                    outflags[`SET_ADL_TO_PCL] = 1;
                    outflags[`LOAD_ABL] = 1;

                    //Move ALU to ACC
                    outflags[`SET_SB_TO_ALU] = 1;
                    outflags[`SET_DB_TO_SB] = 1;
                    outflags[`LOAD_ACC] = 1;

                    //Set PSR from ALU outflags
                    
                    outflags[`WRITE_ZERO_FLAG] = 1;
                    outflags[`SET_PSR_N_TO_DB7] = 1;
                    outflags[`END_INSTRUCTION] = 1'b1; // signal to end the instruction
                end
                default: outflags = 0;
            endcase

            end
            `ASL: begin                                          // code ASL

            outflags = 0;
            case (state)
                `T0:  begin
                    //Set B and A to input data
                    outflags[`SET_DB_TO_DATA] = 1;
                    outflags[`SET_SB_TO_DB] = 1;
                    outflags[`SET_INPUT_A_TO_SB] = 1;
                    outflags[`SET_INPUT_B_TO_DB] = 1;
                    
                    //Add them together
                    outflags[`ALU_ADD] = 1;
                    outflags[`LOAD_ALU] = 1;
                    
                    //SET outflags
                    outflags[`SET_PSR_CARRY_TO_ALU_CARRY] = 1;
                end
                `T1: begin
                    //Move ALU to DOR
                    outflags[`SET_SB_TO_ALU] = 1;
                    outflags[`SET_DB_TO_SB] = 1;
                    outflags[`LOAD_DOR] = 1;

                    //Set PSR outflags
                    outflags[`WRITE_ZERO_FLAG] = 1;
                    outflags[`SET_PSR_N_TO_DB7] = 1;
                end
                `T2: begin
                    //Increment PC
                    outflags[`PC_INC] = 1;

                    //set ABH and ABL to PC
                    outflags[`SET_ADH_TO_PCH] = 1;
                    outflags[`LOAD_ABH] = 1;
                    outflags[`SET_ADL_TO_PCL] = 1;
                    outflags[`LOAD_ABL] = 1;
                end
                `T3: begin
                    //Increment PC
                    outflags[`PC_INC] = 1;

                    //set ABH and ABL to PC
                    outflags[`SET_ADH_TO_PCH] = 1;
                    outflags[`LOAD_ABH] = 1;
                    outflags[`SET_ADL_TO_PCL] = 1;
                    outflags[`LOAD_ABL] = 1;

                    outflags[`END_INSTRUCTION] = 1'b1; // signal to end the instruction
                end
                default: outflags = 0;
            endcase

            end
            `BCC, `BCS, `BEQ, `BMI, `BNE, `BPL, `BVC, `BVS: begin       // code BCC                  BRANCH CHECKING ONE THAT IS HARD
            
            outflags = 0;
            case (state)
                `T0: begin
                    //Increment PC
                    outflags[`PC_INC] = 1;

                    //set ABH and ABL to PC
                    outflags[`SET_ADH_TO_PCH] = 1;
                    outflags[`LOAD_ABH] = 1;
                    outflags[`SET_ADL_TO_PCL] = 1;
                    outflags[`LOAD_ABL] = 1;

                    //Set B=PCL
                    outflags[`SET_INPUT_B_TO_ADL] = 1;
                    
                    //Set A=Data
                    outflags[`SET_DB_TO_DATA] = 1;
                    outflags[`SET_SB_TO_DB] = 1;
                    outflags[`SET_INPUT_A_TO_SB] = 1;
                    
                    //A+B=PCL+Data
                    outflags[`ALU_ADD] = 1;
                    outflags[`LOAD_ALU] = 1;
                    outflags[`SET_FREE_CARRY_FLAG_TO_ALU] = 1;

                    //Update the jump forward/backward flip flops
                    outflags[`SET_BRANCH_PAGE_CROSS_FLAGS] = 1;
                end
                `T1: begin
                    if(jump) begin
                        //Increment PC if there is not a page crossing
                        if(~branchForwardFF & ~branchBackwardFF)
                            outflags[`PC_INC] = 1;

                        //Move ALU to ABL/PCL
                        outflags[`SET_ADL_TO_ALU] = 1;
                        outflags[`SET_ADH_TO_PCH] = 1;
                        outflags[`LOAD_ABL] = 1;
                        outflags[`LOAD_PC] = 1;

                        //ADD carry
                        // outflags[`SET_DB_TO_PCH] = 1;
                        // outflags[`SET_INPUT_A_TO_LOW] = 1;
                        // outflags[`SET_INPUT_B_TO_DB] = 1;
                        // outflags[`SET_ALU_CARRY_TO_FREE_CARRY] = 1;

                        //If branchForwardFF, incrementPCH
                        if(branchForwardFF) begin
                            outflags[`SET_DB_TO_PCH] = 1;
                            outflags[`SET_INPUT_A_TO_LOW] = 1;
                            outflags[`SET_INPUT_B_TO_DB] = 1;
                            outflags[`SET_ALU_CARRY_HIGH] = 1;
                        end

                        //If branchBackwardFF, decrementPCH
                        if(branchBackwardFF) begin
                            outflags[`SET_SB_TO_ADH] = 1;//ADH has PCH
                            outflags[`SET_INPUT_A_TO_SB] = 1;//Put PCH on the ALU A input
                            outflags[`SET_DB_HIGH] = 1; //SET the DB to FF
                            outflags[`SET_INPUT_B_TO_DB] = 1; //Put FF on the ALU
                        end

                        //A+B=PCH+C
                        outflags[`ALU_ADD] = 1;
                        outflags[`LOAD_ALU] = 1;
                    end else begin
                        //Increment PC
                        outflags[`PC_INC] = 1;

                        //set ABH and ABL to PC
                        outflags[`SET_ADH_TO_PCH] = 1;
                        outflags[`LOAD_ABH] = 1;
                        outflags[`SET_ADL_TO_PCL] = 1;
                        outflags[`LOAD_ABL] = 1;

                        outflags[`END_INSTRUCTION] = 1'b1; // signal to end the instruction
                    end
                end
                `T2: begin
                    if(branchBackwardFF | branchForwardFF) begin
                        
                        outflags[`PC_INC] = 1;
                        //Move ALU to ABH/PCH
                        outflags[`SET_SB_TO_ALU] = 1;
                        outflags[`SET_ADH_TO_SB] = 1;
                        outflags[`SET_ADL_TO_PCL] = 1;
                        outflags[`LOAD_PC] = 1;
                        outflags[`LOAD_ABH] = 1;
                        outflags[`LOAD_ABL] = 1;


                    end else begin
                        //Increment PC
                        outflags[`PC_INC] = 1;

                        //set ABH and ABL to PC
                        outflags[`SET_ADH_TO_PCH] = 1;
                        outflags[`LOAD_ABH] = 1;
                        outflags[`SET_ADL_TO_PCL] = 1;
                        outflags[`LOAD_ABL] = 1;
                        outflags[`END_INSTRUCTION] = 1'b1; // signal to end the instruction
                    end
                end
                `T3: begin
                    //Increment PC
                    outflags[`PC_INC] = 1;

                    //set ABH and ABL to PC
                    outflags[`SET_ADH_TO_PCH] = 1;
                    outflags[`LOAD_ABH] = 1;
                    outflags[`SET_ADL_TO_PCL] = 1;
                    outflags[`LOAD_ABL] = 1;


                    outflags[`END_INSTRUCTION] = 1'b1; // signal to end the instruction
                end
                default: outflags = 0;
            endcase

            end
            `BIT: begin                                          // code BIT
            
            outflags = 0;
            case (state)
                `T0: begin
                    //Increment PC
                    outflags[`PC_INC] = 1;

                    //set ABH and ABL to PC
                    outflags[`SET_ADH_TO_PCH] = 1;
                    outflags[`LOAD_ABH] = 1;
                    outflags[`SET_ADL_TO_PCL] = 1;
                    outflags[`LOAD_ABL] = 1;

                    //Set input b
                    outflags[`SET_DB_TO_DATA] = 1;
                    outflags[`SET_INPUT_B_TO_DB] = 1;

                    //set input a
                    outflags[`SET_SB_TO_ACC] = 1;
                    outflags[`SET_INPUT_A_TO_SB] = 1;

                    //And ACC&M
                    outflags[`ALU_AND] = 1;
                    outflags[`LOAD_ALU] = 1;

                    //Set flags dependent on memory being tested
                    outflags[`SET_PSR_N_TO_DB7] = 1;
                    outflags[`SET_PSR_V_TO_DB6] = 1;
                
                end
                `T1: begin
                    //Increment PC
                    outflags[`PC_INC] = 1;

                    //set ABH and ABL to PC
                    outflags[`SET_ADH_TO_PCH] = 1;
                    outflags[`LOAD_ABH] = 1;
                    outflags[`SET_ADL_TO_PCL] = 1;
                    outflags[`LOAD_ABL] = 1;

                    //Get ALU to the DB so that the zero flag can be written
                    outflags[`SET_SB_TO_ALU] = 1;
                    outflags[`SET_DB_TO_SB] = 1;

                    //Set PSR from ALU outflags
                    outflags[`WRITE_ZERO_FLAG] = 1;

                    outflags[`END_INSTRUCTION] = 1'b1; // signal to end the instruction
                end
                default: outflags = 0;
            endcase

            end
            `BRK: begin                                          // code BRK

            outflags = 0;
            case (state)
                `T0: begin
                    //Go to Stack
                    outflags[`SET_ADH_TO_ONE] = 1;
                    outflags[`LOAD_ABH] = 1;
                    outflags[`SET_ADL_TO_SP] = 1;
                    outflags[`LOAD_ABL] = 1;
                    
                    //Set input A to FF
                    outflags[`SET_SB_HIGH] = 1;
                    outflags[`SET_INPUT_A_TO_SB] = 1;

                    //Set input B to SP
                    outflags[`SET_INPUT_B_TO_ADL] = 1;

                    //Add SP+FF = SP-1
                    outflags[`ALU_ADD] = 1;
                    outflags[`LOAD_ALU] = 1;

                    //Get PCH to DOR
                    outflags[`SET_DB_TO_PCH] = 1;
                    outflags[`LOAD_DOR] = 1;
                    
                end
                `T1: begin
                    //Go to next Stack
                    outflags[`SET_ADL_TO_ALU] = 1;
                    outflags[`LOAD_ABL] = 1;
                    
                    //Set input A to FF
                    outflags[`SET_SB_HIGH] = 1;
                    outflags[`SET_INPUT_A_TO_SB] = 1;

                    //Set input B to SP
                    outflags[`SET_INPUT_B_TO_ADL] = 1;

                    //Add SP+FF = SP-1
                    outflags[`ALU_ADD] = 1;
                    outflags[`LOAD_ALU] = 1;

                    //Get PCL to DOR
                    outflags[`SET_DB_TO_PCL] = 1;
                    outflags[`LOAD_DOR] = 1;
                    
                end
                `T2: begin
                    //Go to next Stack
                    outflags[`SET_ADL_TO_ALU] = 1;
                    outflags[`LOAD_ABL] = 1;
                    
                    //Set input A to FF
                    outflags[`SET_SB_HIGH] = 1;
                    outflags[`SET_INPUT_A_TO_SB] = 1;

                    //Set input B to SP
                    outflags[`SET_INPUT_B_TO_ADL] = 1;

                    //Add SP+FF = SP-1
                    outflags[`ALU_ADD] = 1;
                    outflags[`LOAD_ALU] = 1;

                    //Get PSR to DOR
                    outflags[`SET_DB_TO_PSR] = 1;
                    outflags[`SET_PSR_OUTPUT_BRK_HIGH] = ~(nmi|irq|reset);
                    outflags[`LOAD_DOR] = 1;
                end
                `T3: begin
                    //set ABH and ABL to presets
                    outflags[`SET_ADH_FF] = 1;
                    outflags[`LOAD_ABH] = 1;
                    outflags[`SET_ADL_FA] = nmi;
                    outflags[`SET_ADL_FC] = reset;
                    outflags[`SET_ADL_FE] = ~(nmi|reset);
                    outflags[`LOAD_ABL] = 1;

                    //Get ALU ouput to SP Reg
                    outflags[`SET_SB_TO_ALU] = 1;    
                    outflags[`LOAD_SP] = 1;    
                end
                `T4: begin
                    //set ABH and ABL to presets
                    outflags[`SET_ADH_FF] = 1;
                    outflags[`LOAD_ABH] = 1;
                    outflags[`SET_ADL_FB] = nmi;
                    outflags[`SET_ADL_FD] = reset;
                    outflags[`SET_ADL_FF] = ~(nmi|reset);
                    outflags[`LOAD_ABL] = 1;

                    //set B to Data
                    outflags[`SET_DB_TO_DATA] = 1;
                    outflags[`SET_INPUT_B_TO_DB] = 1;

                    //add data + 0
                    outflags[`SET_INPUT_A_TO_LOW] = 1;
                    outflags[`ALU_ADD] = 1;
                    outflags[`LOAD_ALU] = 1;
                end
                `T5: begin
                    //Update ABL
                    outflags[`SET_ADL_TO_ALU] = 1;
                    outflags[`LOAD_ABL] = 1;

                    //Update ABH
                    outflags[`SET_ADH_TO_DATA] = 1;
                    outflags[`LOAD_ABH] = 1;

                    //Update PC
                    outflags[`LOAD_PC] = 1;
                    outflags[`PC_INC] = 1;
                    
                    //Set I flag if nmi or irq after PSR has been written
                    if(setInterruptFlag) begin
                        load_psr_I = 1'b1;
                        psr_data_to_load = 1'b1;
                    end
                end
                `T6:  begin
                    //Increment PC
                    outflags[`PC_INC] = 1;

                    //set ABH and ABL to PC
                    outflags[`SET_ADH_TO_PCH] = 1;
                    outflags[`LOAD_ABH] = 1;
                    outflags[`SET_ADL_TO_PCL] = 1;
                    outflags[`LOAD_ABL] = 1;

                    outflags[`END_INSTRUCTION] = 1'b1; // signal to end the instruction
                end
                default: outflags = 0;
            endcase

            end
            `CLC: begin                                          // code CLC

            outflags = 0;
            case (state)
                `T0: begin
                    //Set FLAG
                    outflags[`PSR_DATA_TO_LOAD] = 0;
                    outflags[`LOAD_CARRY_PSR_FLAG] = 1;
                
                end
                `T1: begin
                    //Increment PC and set ABH and ABL to PC
                    outflags[`PC_INC] = 1;
                    outflags[`SET_ADH_TO_PCH] = 1;
                    outflags[`LOAD_ABH] = 1;
                    outflags[`SET_ADL_TO_PCL] = 1;
                    outflags[`LOAD_ABL] = 1;

                    outflags[`END_INSTRUCTION] = 1'b1; // signal to end the instruction
                end
                default: outflags = 0;
            endcase

            end
            `CLD: begin                                          // code CLD

            outflags = 0;
            case (state)
                `T0: begin
                    //Set FLAG
                    outflags[`PSR_DATA_TO_LOAD] = 0;
                    outflags[`LOAD_DECIMAL_PSR_FLAG] = 1;
                
                end
                `T1: begin
                    //Increment PC and set ABH and ABL to PC
                    outflags[`PC_INC] = 1;
                    outflags[`SET_ADH_TO_PCH] = 1;
                    outflags[`LOAD_ABH] = 1;
                    outflags[`SET_ADL_TO_PCL] = 1;
                    outflags[`LOAD_ABL] = 1;

                    outflags[`END_INSTRUCTION] = 1'b1; // signal to end the instruction
                end
                default: outflags = 0;
            endcase

            end
            `CLI: begin                                          // code CLI

            outflags = 0;
            case (state)
                `T0: begin
                    //Set FLAG
                    outflags[`PSR_DATA_TO_LOAD] = 0;
                    outflags[`LOAD_INTERUPT_PSR_FLAG] = 1;
                
                end
                `T1: begin
                    //Increment PC and set ABH and ABL to PC
                    outflags[`PC_INC] = 1;
                    outflags[`SET_ADH_TO_PCH] = 1;
                    outflags[`LOAD_ABH] = 1;
                    outflags[`SET_ADL_TO_PCL] = 1;
                    outflags[`LOAD_ABL] = 1;

                    outflags[`END_INSTRUCTION] = 1'b1; // signal to end the instruction
                end
                default: outflags = 0;
            endcase

            end
            `CLV: begin                                          // code CLV

            outflags = 0;
            case (state)
                `T0: begin
                    //Set FLAG
                    outflags[`LOAD_OVERFLOW_PSR_FLAG] = 1;
                
                end
                `T1: begin
                    //Increment PC and set ABH and ABL to PC
                    outflags[`PC_INC] = 1;
                    outflags[`SET_ADH_TO_PCH] = 1;
                    outflags[`LOAD_ABH] = 1;
                    outflags[`SET_ADL_TO_PCL] = 1;
                    outflags[`LOAD_ABL] = 1;

                    outflags[`END_INSTRUCTION] = 1'b1; // signal to end the instruction
                end
                default: outflags = 0;
            endcase

            end
            `CMP: begin                                          // code CMP

            outflags = 0;
            case (state)
                `T0: begin
                    //Increment PC
                    outflags[`PC_INC] = 1;

                    //set ABH and ABL to PC
                    outflags[`SET_ADH_TO_PCH] = 1;
                    outflags[`LOAD_ABH] = 1;
                    outflags[`SET_ADL_TO_PCL] = 1;
                    outflags[`LOAD_ABL] = 1;

                    //Set input b
                    outflags[`SET_DB_TO_DATA] = 1;
                    outflags[`SET_INPUT_B_TO_NOT_DB] = 1;
                    outflags[`SET_ALU_CARRY_HIGH] = 1;

                    //set input a
                    outflags[`SET_SB_TO_ACC] = 1;
                    outflags[`SET_INPUT_A_TO_SB] = 1;

                    //Subtract X-M
                    outflags[`ALU_ADD] = 1;
                    outflags[`LOAD_ALU] = 1;
                    outflags[`SET_PSR_CARRY_TO_ALU_CARRY] = 1;
                
                end
                `T1: begin
                    //Increment PC
                    outflags[`PC_INC] = 1;

                    //set ABH and ABL to PC
                    outflags[`SET_ADH_TO_PCH] = 1;
                    outflags[`LOAD_ABH] = 1;
                    outflags[`SET_ADL_TO_PCL] = 1;
                    outflags[`LOAD_ABL] = 1;

                    //Move ALU to ACC
                    outflags[`SET_SB_TO_ALU] = 1;
                    outflags[`SET_DB_TO_SB] = 1;

                    //Set PSR from ALU outflags
                    
                    outflags[`WRITE_ZERO_FLAG] = 1;
                    outflags[`SET_PSR_N_TO_DB7] = 1;

                    outflags[`END_INSTRUCTION] = 1'b1; // signal to end the instruction

                end
                default: outflags = 0;
            endcase

            end
            `CPX: begin                                          // code CPX

            outflags = 0;
            case (state)
                `T0: begin
                    //Increment PC
                    outflags[`PC_INC] = 1;

                    //set ABH and ABL to PC
                    outflags[`SET_ADH_TO_PCH] = 1;
                    outflags[`LOAD_ABH] = 1;
                    outflags[`SET_ADL_TO_PCL] = 1;
                    outflags[`LOAD_ABL] = 1;

                    //Set input b
                    outflags[`SET_DB_TO_DATA] = 1;
                    outflags[`SET_INPUT_B_TO_NOT_DB] = 1;
                    outflags[`SET_ALU_CARRY_HIGH] = 1;

                    //set input a
                    outflags[`SET_SB_TO_X] = 1;
                    outflags[`SET_INPUT_A_TO_SB] = 1;

                    //Subtract Y-M
                    outflags[`ALU_ADD] = 1;
                    outflags[`LOAD_ALU] = 1;
                    outflags[`SET_PSR_CARRY_TO_ALU_CARRY] = 1;
                
                end
                `T1: begin
                    //Increment PC
                    outflags[`PC_INC] = 1;

                    //set ABH and ABL to PC
                    outflags[`SET_ADH_TO_PCH] = 1;
                    outflags[`LOAD_ABH] = 1;
                    outflags[`SET_ADL_TO_PCL] = 1;
                    outflags[`LOAD_ABL] = 1;

                    //Move ALU to ACC
                    outflags[`SET_SB_TO_ALU] = 1;
                    outflags[`SET_DB_TO_SB] = 1;

                    //Set PSR from ALU outflags
                    
                    outflags[`WRITE_ZERO_FLAG] = 1;
                    outflags[`SET_PSR_N_TO_DB7] = 1;

                    outflags[`END_INSTRUCTION] = 1'b1; // signal to end the instruction

                end
                default: outflags = 0;
            endcase

            end
            `CPY: begin                                          // code CPY

            outflags = 0;
            case (state)
                `T0: begin
                    //Increment PC
                    outflags[`PC_INC] = 1;

                    //set ABH and ABL to PC
                    outflags[`SET_ADH_TO_PCH] = 1;
                    outflags[`LOAD_ABH] = 1;
                    outflags[`SET_ADL_TO_PCL] = 1;
                    outflags[`LOAD_ABL] = 1;

                    //Set input b
                    outflags[`SET_DB_TO_DATA] = 1;
                    outflags[`SET_INPUT_B_TO_NOT_DB] = 1;
                    outflags[`SET_ALU_CARRY_HIGH] = 1;

                    //set input a
                    outflags[`SET_SB_TO_Y] = 1;
                    outflags[`SET_INPUT_A_TO_SB] = 1;

                    //Subtract ACC-M
                    outflags[`ALU_ADD] = 1;
                    outflags[`LOAD_ALU] = 1;
                    outflags[`SET_PSR_CARRY_TO_ALU_CARRY] = 1;
                
                end
                `T1: begin
                    //Increment PC
                    outflags[`PC_INC] = 1;

                    //set ABH and ABL to PC
                    outflags[`SET_ADH_TO_PCH] = 1;
                    outflags[`LOAD_ABH] = 1;
                    outflags[`SET_ADL_TO_PCL] = 1;
                    outflags[`LOAD_ABL] = 1;

                    //Move ALU to ACC
                    outflags[`SET_SB_TO_ALU] = 1;
                    outflags[`SET_DB_TO_SB] = 1;

                    //Set PSR from ALU outflags
                    
                    outflags[`WRITE_ZERO_FLAG] = 1;
                    outflags[`SET_PSR_N_TO_DB7] = 1;

                    outflags[`END_INSTRUCTION] = 1'b1; // signal to end the instruction

                end
                default: outflags = 0;
            endcase

            end
            `DEC: begin                                          // code DEC

            outflags = 0;
            case (state)
                `T0: begin
                    //Set B and A to be FF and Data
                    outflags[`SET_DB_HIGH] = 1;
                    outflags[`SET_INPUT_A_TO_SB] = 1;
                    outflags[`SET_INPUT_B_TO_DB] = 1;
                    
                    //What to decrement
                    outflags[`SET_ADH_TO_DATA] = 1;
                    outflags[`SET_SB_TO_ADH] = 1;
                    
                    //Add them together
                    outflags[`ALU_ADD] = 1;
                    outflags[`LOAD_ALU] = 1;
                end
                `T1: begin
                    //Move ALU to DOR
                    outflags[`SET_SB_TO_ALU] = 1;
                    outflags[`SET_DB_TO_SB] = 1;
                    outflags[`LOAD_DOR] = 1;

                    //Set PSR outflags
                    outflags[`WRITE_ZERO_FLAG] = 1;
                    outflags[`SET_PSR_N_TO_DB7] = 1;
                end
                `T2: begin
                    //Increment PC
                    outflags[`PC_INC] = 1;

                    //set ABH and ABL to PC
                    outflags[`SET_ADH_TO_PCH] = 1;
                    outflags[`LOAD_ABH] = 1;
                    outflags[`SET_ADL_TO_PCL] = 1;
                    outflags[`LOAD_ABL] = 1;
                end
                `T3: begin
                    //Increment PC
                    outflags[`PC_INC] = 1;

                    //set ABH and ABL to PC
                    outflags[`SET_ADH_TO_PCH] = 1;
                    outflags[`LOAD_ABH] = 1;
                    outflags[`SET_ADL_TO_PCL] = 1;
                    outflags[`LOAD_ABL] = 1;

                    outflags[`END_INSTRUCTION] = 1'b1; // signal to end the instruction
                end
                default: outflags = 0;
            endcase

            end
            `DEX: begin                                          // code DEX

            outflags = 0;
            case (state)
                `T0: begin
                    //Set B and A to be FF and Y
                    outflags[`SET_DB_HIGH] = 1;
                    outflags[`SET_INPUT_A_TO_SB] = 1;
                    outflags[`SET_INPUT_B_TO_DB] = 1;
                    
                    //What to increment
                    outflags[`SET_SB_TO_X] = 1;
                    
                    //Add them together
                    outflags[`ALU_ADD] = 1;
                    outflags[`LOAD_ALU] = 1;
                end
                `T1: begin
                    //Increment PC and set ABH and ABL to PC
                    outflags[`PC_INC] = 1;
                    outflags[`SET_ADH_TO_PCH] = 1;
                    outflags[`LOAD_ABH] = 1;
                    outflags[`SET_ADL_TO_PCL] = 1;
                    outflags[`LOAD_ABL] = 1;
                    //Move ALU to X
                    outflags[`SET_SB_TO_ALU] = 1;
                    outflags[`LOAD_X] = 1;

                    //Set PSR outflags
                    outflags[`SET_DB_TO_SB] = 1;
                    outflags[`WRITE_ZERO_FLAG] = 1;
                    outflags[`SET_PSR_N_TO_DB7] = 1;

                    outflags[`END_INSTRUCTION] = 1'b1; // signal to end the instruction
                end
                default: outflags = 0;
            endcase

            end
            `DEY: begin                                          // code DEY

            outflags = 0;
            case (state)
                `T0: begin
                    //Set B and A to be FF and Y
                    outflags[`SET_DB_HIGH] = 1;
                    outflags[`SET_INPUT_A_TO_SB] = 1;
                    outflags[`SET_INPUT_B_TO_DB] = 1;
                    
                    //What to decrement
                    outflags[`SET_SB_TO_Y] = 1;

                    //Add them together
                    outflags[`ALU_ADD] = 1;
                    outflags[`LOAD_ALU] = 1;
                end
                `T1: begin
                    //Increment PC and set ABH and ABL to PC
                    outflags[`PC_INC] = 1;
                    outflags[`SET_ADH_TO_PCH] = 1;
                    outflags[`LOAD_ABH] = 1;
                    outflags[`SET_ADL_TO_PCL] = 1;
                    outflags[`LOAD_ABL] = 1;
                    //Move ALU to Y
                    outflags[`SET_SB_TO_ALU] = 1;
                    outflags[`LOAD_Y] = 1;

                    //Set PSR outflags
                    outflags[`SET_DB_TO_SB] = 1;
                    outflags[`WRITE_ZERO_FLAG] = 1;
                    outflags[`SET_PSR_N_TO_DB7] = 1;

                    outflags[`END_INSTRUCTION] = 1'b1; // signal to end the instruction
                end
                default: outflags = 0;
            endcase

            end
            `EOR: begin                                          // code EOR

            outflags = 0;
            case (state)
                `T0: begin
                    //Increment PC
                    outflags[`PC_INC] = 1;

                    //set ABH and ABL to PC
                    outflags[`SET_ADH_TO_PCH] = 1;
                    outflags[`LOAD_ABH] = 1;
                    outflags[`SET_ADL_TO_PCL] = 1;
                    outflags[`LOAD_ABL] = 1;

                    //Set input b
                    outflags[`SET_DB_TO_DATA] = 1;
                    outflags[`SET_INPUT_B_TO_DB] = 1;

                    //set input a
                    outflags[`SET_SB_TO_ACC] = 1;
                    outflags[`SET_INPUT_A_TO_SB] = 1;

                    //add ACC+C+DATA
                    outflags[`ALU_XOR] = 1;
                    outflags[`LOAD_ALU] = 1;
                
                end
                `T1: begin
                    //Increment PC
                    outflags[`PC_INC] = 1;

                    //set ABH and ABL to PC
                    outflags[`SET_ADH_TO_PCH] = 1;
                    outflags[`LOAD_ABH] = 1;
                    outflags[`SET_ADL_TO_PCL] = 1;
                    outflags[`LOAD_ABL] = 1;

                    //Move ALU to ACC
                    outflags[`SET_SB_TO_ALU] = 1;
                    outflags[`SET_DB_TO_SB] = 1;
                    outflags[`LOAD_ACC] = 1;

                    //Set PSR from ALU outflags
                    
                    outflags[`WRITE_ZERO_FLAG] = 1;
                    outflags[`SET_PSR_N_TO_DB7] = 1;

                    outflags[`END_INSTRUCTION] = 1'b1; // signal to end the instruction
                end
                default: outflags = 0;
            endcase

            end
            `INC: begin                                          // code INC
            
            outflags = 0;
            case (state)
                `T0: begin
                    //Set C B and A to be 1 Data and 0
                    outflags[`SET_DB_TO_DATA] = 1;
                    outflags[`SET_INPUT_B_TO_DB] = 1;
                    outflags[`SET_ALU_CARRY_HIGH] = 1;
                    outflags[`SET_INPUT_A_TO_LOW] = 1;
                    
                    //Add them together
                    outflags[`ALU_ADD] = 1;
                    outflags[`LOAD_ALU] = 1;
                end
                `T1: begin
                    //Move ALU to DOR
                    outflags[`SET_SB_TO_ALU] = 1;
                    outflags[`SET_DB_TO_SB] = 1;
                    outflags[`LOAD_DOR] = 1;

                    //Set PSR outflags
                    outflags[`WRITE_ZERO_FLAG] = 1;
                    outflags[`SET_PSR_N_TO_DB7] = 1;
                end
                `T2: begin
                    //Increment PC
                    outflags[`PC_INC] = 1;

                    //set ABH and ABL to PC
                    outflags[`SET_ADH_TO_PCH] = 1;
                    outflags[`LOAD_ABH] = 1;
                    outflags[`SET_ADL_TO_PCL] = 1;
                    outflags[`LOAD_ABL] = 1;
                end
                `T3: begin
                    //Increment PC
                    outflags[`PC_INC] = 1;

                    //set ABH and ABL to PC
                    outflags[`SET_ADH_TO_PCH] = 1;
                    outflags[`LOAD_ABH] = 1;
                    outflags[`SET_ADL_TO_PCL] = 1;
                    outflags[`LOAD_ABL] = 1;

                    outflags[`END_INSTRUCTION] = 1'b1; // signal to end the instruction
                end
                default: outflags = 0;
            endcase

            end
            `INX: begin                                          // code INX

            outflags = 0;
            case (state)
                `T0: begin
                    //Set B and A to input data
                    outflags[`SET_SB_TO_X] = 1;
                    outflags[`SET_DB_TO_SB] = 1;
                    outflags[`SET_INPUT_B_TO_DB] = 1;
                    outflags[`SET_ALU_CARRY_HIGH] = 1;
                    outflags[`SET_INPUT_A_TO_LOW] = 1;
                    
                    //Add them together
                    outflags[`ALU_ADD] = 1;
                    outflags[`LOAD_ALU] = 1;
                end
                `T1: begin
                    //Increment PC and set ABH and ABL to PC
                    outflags[`PC_INC] = 1;
                    outflags[`SET_ADH_TO_PCH] = 1;
                    outflags[`LOAD_ABH] = 1;
                    outflags[`SET_ADL_TO_PCL] = 1;
                    outflags[`LOAD_ABL] = 1;

                    //Move ALU to X
                    outflags[`SET_SB_TO_ALU] = 1;
                    outflags[`LOAD_X] = 1;

                    //Set PSR outflags
                    outflags[`SET_DB_TO_SB] = 1;
                    outflags[`WRITE_ZERO_FLAG] = 1;
                    outflags[`SET_PSR_N_TO_DB7] = 1;

                    outflags[`END_INSTRUCTION] = 1'b1; // signal to end the instruction
                end
                default: outflags = 0;
            endcase

            end
            `INY: begin                                          // code INY

            outflags = 0;
            case (state)
                `T0: begin
                    //Set C B and A to be 1 Y and 0
                    outflags[`SET_SB_TO_Y] = 1;
                    outflags[`SET_DB_TO_SB] = 1;
                    outflags[`SET_INPUT_B_TO_DB] = 1;
                    outflags[`SET_ALU_CARRY_HIGH] = 1;
                    outflags[`SET_INPUT_A_TO_LOW] = 1;
                    
                    //Add them together
                    outflags[`ALU_ADD] = 1;
                    outflags[`LOAD_ALU] = 1;
                end
                `T1: begin
                    //Increment PC and set ABH and ABL to PC
                    outflags[`PC_INC] = 1;
                    outflags[`SET_ADH_TO_PCH] = 1;
                    outflags[`LOAD_ABH] = 1;
                    outflags[`SET_ADL_TO_PCL] = 1;
                    outflags[`LOAD_ABL] = 1;

                    //Move ALU to Y
                    outflags[`SET_SB_TO_ALU] = 1;
                    outflags[`LOAD_Y] = 1;

                    //Set PSR outflags
                    outflags[`SET_DB_TO_SB] = 1;
                    outflags[`WRITE_ZERO_FLAG] = 1;
                    outflags[`SET_PSR_N_TO_DB7] = 1;

                    outflags[`END_INSTRUCTION] = 1'b1; // signal to end the instruction
                end
                default: outflags = 0;
            endcase

            end
            `JMP: begin                                          // code JMP

            outflags = 0;
            case (state)
                `T0: begin
                    //Increment PC
                    outflags[`PC_INC] = 1;
                    outflags[`LOAD_PC] = 1;

                    //set ABH and ABL to PC
                    outflags[`SET_ADH_TO_PCH] = 1;
                    outflags[`LOAD_ABH] = 1;
                    outflags[`SET_ADL_TO_PCL] = 1;
                    outflags[`LOAD_ABL] = 1;

                    outflags[`END_INSTRUCTION] = 1'b1; // signal to end the instruction
                end
                default: outflags = 0;
            endcase

            end
            `JSR: begin                                          // code JSR

            outflags = 0;
            case (state)
                `T0: begin
                    //Set input B and ABL to SP
                    outflags[`SET_ADL_TO_SP] = 1;
                    outflags[`SET_INPUT_B_TO_ADL] = 1;
                    outflags[`LOAD_ABL] = 1;

                    //Add 0 to SP
                    outflags[`SET_INPUT_A_TO_LOW] = 1;
                    outflags[`ALU_ADD] = 1;
                    outflags[`LOAD_ALU] = 1;

                    //Get PCH to DOR
                    outflags[`SET_DB_TO_PCH] = 1;
                    outflags[`LOAD_DOR] = 1;

                    //Set SP to Data
                    outflags[`SET_ADH_TO_DATA] = 1;
                    outflags[`SET_SB_TO_ADH] = 1;
                    outflags[`LOAD_SP] = 1;
                    
                end
                `T1: begin
                    //ABH to 01
                    outflags[`SET_ADH_TO_ONE] = 1;
                    outflags[`LOAD_ABH] = 1;

                    //ALU to Input A
                    outflags[`SET_SB_TO_ALU] = 1;
                    outflags[`SET_INPUT_A_TO_SB] = 1;

                    //FF to Input B
                    outflags[`SET_DB_HIGH] = 1;
                    outflags[`SET_INPUT_B_TO_DB] = 1;

                    //Add FF to SP
                    outflags[`ALU_ADD] = 1;
                    outflags[`LOAD_ALU] = 1;
                end
                `T2: begin
                    //Get PCL to DOR
                    outflags[`SET_DB_TO_PCL] = 1;
                    outflags[`LOAD_DOR] = 1;

                    //ALU to ABL
                    outflags[`SET_ADL_TO_ALU] = 1;
                    outflags[`LOAD_ABL] = 1;
                end
                `T3: begin
                    //set ABH and ABL to PC
                    outflags[`SET_ADH_TO_PCH] = 1;
                    outflags[`LOAD_ABH] = 1;
                    outflags[`SET_ADL_TO_PCL] = 1;
                    outflags[`LOAD_ABL] = 1;

                    //ALU to Input A
                    outflags[`SET_SB_TO_ALU] = 1;
                    outflags[`SET_INPUT_A_TO_SB] = 1;

                    //FF to Input B
                    outflags[`SET_DB_HIGH] = 1;
                    outflags[`SET_INPUT_B_TO_DB] = 1;

                    //Add FF to SP
                    outflags[`ALU_ADD] = 1;
                    outflags[`LOAD_ALU] = 1;
                end
                `T4: begin
                    //Update ABL
                    outflags[`SET_ADL_TO_SP] = 1;
                    outflags[`LOAD_ABL] = 1;

                    //Update ABH
                    outflags[`SET_ADH_TO_DATA] = 1;
                    outflags[`LOAD_ABH] = 1;

                    //Update PC
                    outflags[`LOAD_PC] = 1;
                    outflags[`PC_INC] = 1;

                    //Update SP Reg
                    outflags[`SET_SB_TO_ALU] = 1;
                    outflags[`LOAD_SP] = 1;
                end
                `T5: begin
                    //Increment PC
                    outflags[`PC_INC] = 1;

                    //set ABH and ABL to PC
                    outflags[`SET_ADH_TO_PCH] = 1;
                    outflags[`LOAD_ABH] = 1;
                    outflags[`SET_ADL_TO_PCL] = 1;
                    outflags[`LOAD_ABL] = 1;

                    outflags[`END_INSTRUCTION] = 1'b1; // signal to end the instruction
                end
                default: outflags = 0;
            endcase

            end
            `LDA: begin                                          // code LDA

            outflags = 0;
            case (state)
                `T0:  begin
                    //Increment PC
                    outflags[`PC_INC] = 1;

                    //set ABH and ABL to PC
                    outflags[`SET_ADH_TO_PCH] = 1;
                    outflags[`LOAD_ABH] = 1;
                    outflags[`SET_ADL_TO_PCL] = 1;
                    outflags[`LOAD_ABL] = 1;

                    //Get Data to ACC
                    outflags[`SET_DB_TO_DATA] = 1;
                    outflags[`SET_SB_TO_DB] = 1;
                    outflags[`LOAD_ACC] = 1;

                    //Set PSR outflags
                    outflags[`WRITE_ZERO_FLAG] = 1;
                    outflags[`SET_PSR_N_TO_DB7] = 1;

                end
                `T1: begin
                    //Increment PC
                    outflags[`PC_INC] = 1;

                    //set ABH and ABL to PC
                    outflags[`SET_ADH_TO_PCH] = 1;
                    outflags[`LOAD_ABH] = 1;
                    outflags[`SET_ADL_TO_PCL] = 1;
                    outflags[`LOAD_ABL] = 1;

                    outflags[`END_INSTRUCTION] = 1'b1; // signal to end the instruction
                end
                default: outflags = 0;
            endcase

            end
            `LDX: begin                                          // code LDX

            outflags = 0;
            case (state)
                `T0:  begin
                    //Increment PC
                    outflags[`PC_INC] = 1;

                    //set ABH and ABL to PC
                    outflags[`SET_ADH_TO_PCH] = 1;
                    outflags[`LOAD_ABH] = 1;
                    outflags[`SET_ADL_TO_PCL] = 1;
                    outflags[`LOAD_ABL] = 1;

                    //Get Data to ACC
                    outflags[`SET_DB_TO_DATA] = 1;
                    outflags[`SET_SB_TO_DB] = 1;
                    outflags[`LOAD_X] = 1;

                    //Set PSR outflags
                    outflags[`WRITE_ZERO_FLAG] = 1;
                    outflags[`SET_PSR_N_TO_DB7] = 1;

                end
                `T1: begin
                    //Increment PC
                    outflags[`PC_INC] = 1;

                    //set ABH and ABL to PC
                    outflags[`SET_ADH_TO_PCH] = 1;
                    outflags[`LOAD_ABH] = 1;
                    outflags[`SET_ADL_TO_PCL] = 1;
                    outflags[`LOAD_ABL] = 1;

                    outflags[`END_INSTRUCTION] = 1'b1; // signal to end the instruction
                end
                default: outflags = 0;
            endcase

            end
            `LDY: begin                                          // code LDY

            outflags = 0;
            case (state)
                `T0:  begin
                    //Increment PC
                    outflags[`PC_INC] = 1;

                    //set ABH and ABL to PC
                    outflags[`SET_ADH_TO_PCH] = 1;
                    outflags[`LOAD_ABH] = 1;
                    outflags[`SET_ADL_TO_PCL] = 1;
                    outflags[`LOAD_ABL] = 1;

                    //Get Data to ACC
                    outflags[`SET_DB_TO_DATA] = 1;
                    outflags[`SET_SB_TO_DB] = 1;
                    outflags[`LOAD_Y] = 1;

                    //Set PSR outflags
                    outflags[`WRITE_ZERO_FLAG] = 1;
                    outflags[`SET_PSR_N_TO_DB7] = 1;

                end
                `T1: begin
                    //Increment PC
                    outflags[`PC_INC] = 1;

                    //set ABH and ABL to PC
                    outflags[`SET_ADH_TO_PCH] = 1;
                    outflags[`LOAD_ABH] = 1;
                    outflags[`SET_ADL_TO_PCL] = 1;
                    outflags[`LOAD_ABL] = 1;

                    outflags[`END_INSTRUCTION] = 1'b1; // signal to end the instruction
                end
                default: outflags = 0;
            endcase

            end
            `LSR: begin                                          // code LSR

            outflags = 0;
            case (state)
                `T0: begin
                    //Set A to DATA
                    outflags[`SET_DB_TO_DATA] = 1;
                    outflags[`SET_SB_TO_DB] = 1;
                    outflags[`SET_INPUT_A_TO_SB] = 1;
                    
                    //Shift
                    outflags[`ALU_R_SHIFT] = 1;
                    outflags[`LOAD_ALU] = 1;
                    
                    //SET outflags
                    outflags[`SET_PSR_CARRY_TO_ALU_CARRY] = 1;
                end
                `T1: begin
                    //Move ALU to DOR
                    outflags[`SET_SB_TO_ALU] = 1;
                    outflags[`SET_DB_TO_SB] = 1;
                    outflags[`LOAD_DOR] = 1;

                    //Set PSR outflags
                    outflags[`WRITE_ZERO_FLAG] = 1;
                    outflags[`SET_PSR_N_TO_DB7] = 1;
                end
                `T2: begin
                    //Increment PC
                    outflags[`PC_INC] = 1;

                    //set ABH and ABL to PC
                    outflags[`SET_ADH_TO_PCH] = 1;
                    outflags[`LOAD_ABH] = 1;
                    outflags[`SET_ADL_TO_PCL] = 1;
                    outflags[`LOAD_ABL] = 1;
                end
                `T3: begin
                    //Increment PC
                    outflags[`PC_INC] = 1;

                    //set ABH and ABL to PC
                    outflags[`SET_ADH_TO_PCH] = 1;
                    outflags[`LOAD_ABH] = 1;
                    outflags[`SET_ADL_TO_PCL] = 1;
                    outflags[`LOAD_ABL] = 1;

                    outflags[`END_INSTRUCTION] = 1'b1; // signal to end the instruction
                end
                default: outflags = 0;
            endcase

            end
            `NOP: begin                                          // code NOP

            outflags = 0;
            case (state)
                `T0: begin
                    
                end
                `T1: begin
                    //Increment PC and set ABH and ABL to PC
                    outflags[`PC_INC] = 1;
                    outflags[`SET_ADH_TO_PCH] = 1;
                    outflags[`LOAD_ABH] = 1;
                    outflags[`SET_ADL_TO_PCL] = 1;
                    outflags[`LOAD_ABL] = 1;
                    
                    outflags[`END_INSTRUCTION] = 1'b1; // signal to end the instruction
                end
                default: outflags = 0;
            endcase

            end
            `ORA: begin                                          // code ORA

            outflags = 0;
            case (state)
                `T0: begin
                    //Increment PC
                    outflags[`PC_INC] = 1;

                    //set ABH and ABL to PC
                    outflags[`SET_ADH_TO_PCH] = 1;
                    outflags[`LOAD_ABH] = 1;
                    outflags[`SET_ADL_TO_PCL] = 1;
                    outflags[`LOAD_ABL] = 1;

                    //Set input b
                    outflags[`SET_DB_TO_DATA] = 1;
                    outflags[`SET_INPUT_B_TO_DB] = 1;

                    //set input a
                    outflags[`SET_SB_TO_ACC] = 1;
                    outflags[`SET_INPUT_A_TO_SB] = 1;

                    //add ACC+C+DATA
                    outflags[`ALU_OR] = 1;
                    outflags[`LOAD_ALU] = 1;
                
                end
                `T1: begin
                    //Increment PC
                    outflags[`PC_INC] = 1;

                    //set ABH and ABL to PC
                    outflags[`SET_ADH_TO_PCH] = 1;
                    outflags[`LOAD_ABH] = 1;
                    outflags[`SET_ADL_TO_PCL] = 1;
                    outflags[`LOAD_ABL] = 1;

                    //Move ALU to ACC
                    outflags[`SET_SB_TO_ALU] = 1;
                    outflags[`SET_DB_TO_SB] = 1;
                    outflags[`LOAD_ACC] = 1;

                    //Set PSR from ALU outflags
                    
                    outflags[`WRITE_ZERO_FLAG] = 1;
                    outflags[`SET_PSR_N_TO_DB7] = 1;

                    outflags[`END_INSTRUCTION] = 1'b1; // signal to end the instruction
                end
                default: outflags = 0;
            endcase

            end
            `PHA: begin                                          // code PHA

            outflags = 0;
            case (state)
                `T0: begin
                    //Decrement PC
                    outflags[`PC_DEC] = 1;

                    //Go to Stack
                    outflags[`SET_ADH_TO_ONE] = 1;
                    outflags[`LOAD_ABH] = 1;
                    outflags[`SET_ADL_TO_SP] = 1;
                    outflags[`LOAD_ABL] = 1;

                    //Load PSR to DOR
                    outflags[`SET_DB_TO_ACC] = 1;
                    outflags[`SET_PSR_OUTPUT_BRK_HIGH] = 1;
                    outflags[`LOAD_DOR] = 1;
                end
                `T1: begin
                    //Increment PC
                    outflags[`PC_INC] = 1;

                    //set ABH and ABL to PC
                    outflags[`SET_ADH_TO_PCH] = 1;
                    outflags[`LOAD_ABH] = 1;
                    outflags[`SET_ADL_TO_PCL] = 1;
                    outflags[`LOAD_ABL] = 1;

                    //Set input A to SP
                    outflags[`SET_SB_TO_SP] = 1;
                    outflags[`SET_INPUT_A_TO_SB] = 1;

                    //Set input B to FF
                    outflags[`SET_DB_HIGH] = 1;
                    outflags[`SET_INPUT_B_TO_DB] = 1;

                    //Add SP+FF = SP-1
                    outflags[`ALU_ADD] = 1;
                    outflags[`LOAD_ALU] = 1;
                end
                `T2: begin
                    //Increment PC
                    outflags[`PC_INC] = 1;

                    //set ABH and ABL to PC
                    outflags[`SET_ADH_TO_PCH] = 1;
                    outflags[`LOAD_ABH] = 1;
                    outflags[`SET_ADL_TO_PCL] = 1;
                    outflags[`LOAD_ABL] = 1;

                    //Set SP to SP-1
                    outflags[`SET_SB_TO_ALU] = 1;
                    outflags[`LOAD_SP] = 1;

                    outflags[`END_INSTRUCTION] = 1'b1; // signal to end the instruction
                end
                default: outflags = 0;
            endcase

            end
            `PHP: begin                                          // code PHP

            outflags = 0;
            case (state)
                `T0: begin
                    //Decrement PC
                    outflags[`PC_DEC] = 1;

                    //Go to Stack
                    outflags[`SET_ADH_TO_ONE] = 1;
                    outflags[`LOAD_ABH] = 1;
                    outflags[`SET_ADL_TO_SP] = 1;
                    outflags[`LOAD_ABL] = 1;

                    //Load PSR to DOR
                    outflags[`SET_DB_TO_PSR] = 1;
                    outflags[`SET_PSR_OUTPUT_BRK_HIGH] = 1;
                    outflags[`LOAD_DOR] = 1;
                end
                `T1: begin
                    //Increment PC
                    outflags[`PC_INC] = 1;

                    //set ABH and ABL to PC
                    outflags[`SET_ADH_TO_PCH] = 1;
                    outflags[`LOAD_ABH] = 1;
                    outflags[`SET_ADL_TO_PCL] = 1;
                    outflags[`LOAD_ABL] = 1;

                    //Set input A to SP
                    outflags[`SET_SB_TO_SP] = 1;
                    outflags[`SET_INPUT_A_TO_SB] = 1;

                    //Set input B to FF
                    outflags[`SET_DB_HIGH] = 1;
                    outflags[`SET_INPUT_B_TO_DB] = 1;

                    //Add SP+FF = SP-1
                    outflags[`ALU_ADD] = 1;
                    outflags[`LOAD_ALU] = 1;
                end
                `T2: begin
                    //Increment PC
                    outflags[`PC_INC] = 1;

                    //set ABH and ABL to PC
                    outflags[`SET_ADH_TO_PCH] = 1;
                    outflags[`LOAD_ABH] = 1;
                    outflags[`SET_ADL_TO_PCL] = 1;
                    outflags[`LOAD_ABL] = 1;

                    //Set SP to SP-1
                    outflags[`SET_SB_TO_ALU] = 1;
                    outflags[`LOAD_SP] = 1;

                    outflags[`END_INSTRUCTION] = 1'b1; // signal to end the instruction
                end
                default: outflags = 0;
            endcase

            end
            `PLA: begin                                          // code PLA

            outflags = 0;
            case (state)
                `T0: begin
                    //Decrement PC
                    outflags[`PC_DEC] = 1;

                    //Set input B to SP
                    outflags[`SET_SB_TO_SP] = 1;
                    outflags[`SET_DB_TO_SB] = 1;
                    outflags[`SET_INPUT_B_TO_DB] = 1;

                    //Set A to 0
                    outflags[`SET_INPUT_A_TO_LOW] = 1;

                    //Add 1 to SP
                    outflags[`SET_ALU_CARRY_HIGH] = 1;
                    outflags[`ALU_ADD] = 1;
                    outflags[`LOAD_ALU] = 1;
                end
                `T1: begin
                    //ALU to SP
                    outflags[`SET_SB_TO_ALU] = 1;
                    outflags[`LOAD_SP] = 1;

                    //ALU to ABL
                    outflags[`SET_ADL_TO_ALU] = 1;
                    outflags[`LOAD_ABL] = 1;

                    //01 to ADH
                    outflags[`SET_ADH_TO_ONE] = 1;
                    outflags[`LOAD_ABH] = 1;
                end
                `T2: begin
                    //Increment PC
                    outflags[`PC_INC] = 1;

                    //set ABH and ABL to PC
                    outflags[`SET_ADH_TO_PCH] = 1;
                    outflags[`LOAD_ABH] = 1;
                    outflags[`SET_ADL_TO_PCL] = 1;
                    outflags[`LOAD_ABL] = 1;

                    //Set ACC
                    outflags[`SET_DB_TO_DATA] = 1;
                    outflags[`SET_SB_TO_DB] = 1;
                    outflags[`LOAD_ACC] = 1;

                    //Set PSR outflags
                    outflags[`WRITE_ZERO_FLAG] = 1;
                    outflags[`SET_PSR_N_TO_DB7] = 1;

                end
                `T3: begin
                    //Increment PC
                    outflags[`PC_INC] = 1;

                    //set ABH and ABL to PC
                    outflags[`SET_ADH_TO_PCH] = 1;
                    outflags[`LOAD_ABH] = 1;
                    outflags[`SET_ADL_TO_PCL] = 1;
                    outflags[`LOAD_ABL] = 1;

                    outflags[`END_INSTRUCTION] = 1'b1; // signal to end the instruction
                end
                default: outflags = 0;
            endcase

            end
            `PLP: begin                                          // code PLP

            outflags = 0;
            case (state)
                `T0: begin
                    //Decrement PC
                    outflags[`PC_DEC] = 1;

                    //Set input B to SP
                    outflags[`SET_SB_TO_SP] = 1;
                    outflags[`SET_DB_TO_SB] = 1;
                    outflags[`SET_INPUT_B_TO_DB] = 1;

                    //Set A to 0
                    outflags[`SET_INPUT_A_TO_LOW] = 1;

                    //Add 1 to SP
                    outflags[`SET_ALU_CARRY_HIGH] = 1;
                    outflags[`ALU_ADD] = 1;
                    outflags[`LOAD_ALU] = 1;
                end
                `T1: begin
                    //ALU to SP
                    outflags[`SET_SB_TO_ALU] = 1;
                    outflags[`LOAD_SP] = 1;

                    //ALU to ABL
                    outflags[`SET_ADL_TO_ALU] = 1;
                    outflags[`LOAD_ABL] = 1;

                    //01 to ADH
                    outflags[`SET_ADH_TO_ONE] = 1;
                    outflags[`LOAD_ABH] = 1;
                end
                `T2: begin
                    //Increment PC
                    outflags[`PC_INC] = 1;

                    //set ABH and ABL to PC
                    outflags[`SET_ADH_TO_PCH] = 1;
                    outflags[`LOAD_ABH] = 1;
                    outflags[`SET_ADL_TO_PCL] = 1;
                    outflags[`LOAD_ABL] = 1;

                    //Set PSR
                    outflags[`SET_DB_TO_DATA] = 1;
                    outflags[`SET_PSR_TO_DB] = 1;
                end
                `T3: begin
                    //Increment PC
                    outflags[`PC_INC] = 1;

                    //set ABH and ABL to PC
                    outflags[`SET_ADH_TO_PCH] = 1;
                    outflags[`LOAD_ABH] = 1;
                    outflags[`SET_ADL_TO_PCL] = 1;
                    outflags[`LOAD_ABL] = 1;

                    outflags[`END_INSTRUCTION] = 1'b1; // signal to end the instruction
                end
                default: outflags = 0;
            endcase

            end
            `ROL: begin                                          // code ROL

            outflags = 0;
            case (state)
                `T0: begin
                    //Set B and A to input data
                    outflags[`SET_DB_TO_DATA] = 1;
                    outflags[`SET_SB_TO_DB] = 1;
                    outflags[`SET_INPUT_A_TO_SB] = 1;
                    outflags[`SET_INPUT_B_TO_DB] = 1;
                    outflags[`SET_ALU_CARRY_TO_PSR_CARRY] = 1;
                    
                    //Add them together
                    outflags[`ALU_ADD] = 1;
                    outflags[`LOAD_ALU] = 1;
                    //SET outflags
                    outflags[`SET_PSR_CARRY_TO_ALU_CARRY] = 1;
                end
                `T1: begin
                    //Move ALU to DOR
                    outflags[`SET_SB_TO_ALU] = 1;
                    outflags[`SET_DB_TO_SB] = 1;
                    outflags[`LOAD_DOR] = 1;

                    //Set PSR outflags
                    outflags[`WRITE_ZERO_FLAG] = 1;
                    outflags[`SET_PSR_N_TO_DB7] = 1;
                end
                `T2: begin
                    //Increment PC
                    outflags[`PC_INC] = 1;

                    //set ABH and ABL to PC
                    outflags[`SET_ADH_TO_PCH] = 1;
                    outflags[`LOAD_ABH] = 1;
                    outflags[`SET_ADL_TO_PCL] = 1;
                    outflags[`LOAD_ABL] = 1;
                end
                `T3: begin
                    //Increment PC
                    outflags[`PC_INC] = 1;

                    //set ABH and ABL to PC
                    outflags[`SET_ADH_TO_PCH] = 1;
                    outflags[`LOAD_ABH] = 1;
                    outflags[`SET_ADL_TO_PCL] = 1;
                    outflags[`LOAD_ABL] = 1;

                    outflags[`END_INSTRUCTION] = 1'b1; // signal to end the instruction
                end
                default: outflags = 0;
            endcase

            end
            `ROR: begin                                          // code ROR

            outflags = 0;
            case (state)
                `T0: begin
                    //Set A to DATA
                    outflags[`SET_DB_TO_DATA] = 1;
                    outflags[`SET_SB_TO_DB] = 1;
                    outflags[`SET_INPUT_A_TO_SB] = 1;
                    outflags[`SET_ALU_CARRY_TO_PSR_CARRY] = 1;
                    
                    //Rotate
                    outflags[`ALU_R_SHIFT] = 1;
                    outflags[`LOAD_ALU] = 1;
                    
                    //SET outflags
                    outflags[`SET_PSR_CARRY_TO_ALU_CARRY] = 1;
                end
                `T1: begin
                    //Move ALU to DOR
                    outflags[`SET_SB_TO_ALU] = 1;
                    outflags[`SET_DB_TO_SB] = 1;
                    outflags[`LOAD_DOR] = 1;

                    //Set PSR outflags
                    outflags[`WRITE_ZERO_FLAG] = 1;
                    outflags[`SET_PSR_N_TO_DB7] = 1;
                end
                `T2: begin
                    //Increment PC
                    outflags[`PC_INC] = 1;

                    //set ABH and ABL to PC
                    outflags[`SET_ADH_TO_PCH] = 1;
                    outflags[`LOAD_ABH] = 1;
                    outflags[`SET_ADL_TO_PCL] = 1;
                    outflags[`LOAD_ABL] = 1;
                end
                `T3: begin
                    //Increment PC
                    outflags[`PC_INC] = 1;

                    //set ABH and ABL to PC
                    outflags[`SET_ADH_TO_PCH] = 1;
                    outflags[`LOAD_ABH] = 1;
                    outflags[`SET_ADL_TO_PCL] = 1;
                    outflags[`LOAD_ABL] = 1;

                    outflags[`END_INSTRUCTION] = 1'b1; // signal to end the instruction
                end
                default: outflags = 0;
            endcase

            end
            `RTI: begin                                          // code RTI
            
            outflags = 0;
            case (state)
                `T0: begin
                    //go to stack
                    outflags[`SET_ADH_TO_ONE] = 1;
                    outflags[`LOAD_ABH] = 1;
                    
                    //Set input B to SP
                    outflags[`SET_SB_TO_SP] = 1;
                    outflags[`SET_DB_TO_SB] = 1;
                    outflags[`SET_INPUT_B_TO_DB] = 1;

                    //Set A to 0
                    outflags[`SET_INPUT_A_TO_LOW] = 1;

                    //Add 1 to SP
                    outflags[`SET_ALU_CARRY_HIGH] = 1;
                    outflags[`ALU_ADD] = 1;
                    outflags[`LOAD_ALU] = 1;
                end
                `T1: begin
                    //ABL to ALU
                    outflags[`SET_ADL_TO_ALU] = 1;
                    outflags[`LOAD_ABL]  = 1;

                    //Set input B to ADL(SP+1)
                    outflags[`SET_INPUT_B_TO_ADL] = 1;

                    //Set A to 0
                    outflags[`SET_INPUT_A_TO_LOW] = 1;

                    //Add 1 to SP
                    outflags[`SET_ALU_CARRY_HIGH] = 1;
                    outflags[`ALU_ADD] = 1;
                    outflags[`LOAD_ALU] = 1;
                end
                `T2: begin
                    ///ABL to ALU
                    outflags[`SET_ADL_TO_ALU] = 1;
                    outflags[`LOAD_ABL]  = 1;

                    //Set input B to ADL(SP+1)
                    outflags[`SET_INPUT_B_TO_ADL] = 1;

                    //Set A to 0
                    outflags[`SET_INPUT_A_TO_LOW] = 1;

                    //Add 1 to SP
                    outflags[`SET_ALU_CARRY_HIGH] = 1;
                    outflags[`ALU_ADD] = 1;
                    outflags[`LOAD_ALU] = 1;

                    //Set PSR
                    outflags[`SET_DB_TO_DATA] = 1;
                    outflags[`SET_PSR_TO_DB] = 1;
                    
                end
                `T3: begin
                    ///ABL to ALU
                    outflags[`SET_ADL_TO_ALU] = 1;
                    outflags[`LOAD_ABL]  = 1;

                    //ALU to SP
                    outflags[`SET_SB_TO_ALU] = 1;
                    outflags[`LOAD_SP] = 1;
                    
                    //Set input B to Data
                    outflags[`SET_DB_TO_DATA] = 1;
                    outflags[`SET_INPUT_B_TO_DB] = 1;//goofy forgot what was happening here

                    //Set A to 0
                    outflags[`SET_INPUT_A_TO_LOW] = 1;

                    //Save Data in ALU
                    outflags[`ALU_ADD] = 1;
                    outflags[`LOAD_ALU] = 1;
                end
                `T4: begin
                    //Update ABL
                    outflags[`SET_ADL_TO_ALU] = 1;
                    outflags[`LOAD_ABL] = 1;

                    //Update ABH
                    outflags[`SET_ADH_TO_DATA] = 1;
                    outflags[`LOAD_ABH] = 1;

                    //Update PC
                    outflags[`LOAD_PC] = 1;
                    outflags[`PC_INC] = 1;
                end
                `T5: begin
                    //Increment PC
                    outflags[`PC_INC] = 1;

                    //set ABH and ABL to PC
                    outflags[`SET_ADH_TO_PCH] = 1;
                    outflags[`LOAD_ABH] = 1;
                    outflags[`SET_ADL_TO_PCL] = 1;
                    outflags[`LOAD_ABL] = 1;

                    outflags[`END_INSTRUCTION] = 1'b1; // signal to end the instruction
                end
                default: outflags = 0;
            endcase

            end
            `RTS: begin                                          // code RTS // STILL NEEDS WORK

            outflags = 0;
            case (state)
                `T0: begin
                    //go to stack
                    outflags[`SET_ADH_TO_ONE] = 1;
                    outflags[`LOAD_ABH] = 1;

                    //Set input B to SP
                    outflags[`SET_SB_TO_SP] = 1;
                    outflags[`SET_DB_TO_SB] = 1;
                    outflags[`SET_INPUT_B_TO_DB] = 1;

                    //Set A to 0
                    outflags[`SET_INPUT_A_TO_LOW] = 1;

                    //Add 1 to SP
                    outflags[`SET_ALU_CARRY_HIGH] = 1;
                    outflags[`ALU_ADD] = 1;
                    outflags[`LOAD_ALU] = 1;
                end
                `T1: begin
                    //ABL to ALU
                    outflags[`SET_ADL_TO_ALU] = 1;
                    outflags[`LOAD_ABL]  = 1;

                    //Set input B to ADL(SP+1)
                    outflags[`SET_INPUT_B_TO_ADL] = 1;

                    //Set A to 0
                    outflags[`SET_INPUT_A_TO_LOW] = 1;

                    //Add 1 to SP
                    outflags[`SET_ALU_CARRY_HIGH] = 1;
                    outflags[`ALU_ADD] = 1;
                    outflags[`LOAD_ALU] = 1;
                end
                `T2: begin
                    //ABL to ALU
                    outflags[`SET_ADL_TO_ALU] = 1;
                    outflags[`LOAD_ABL]  = 1;

                    //SP to ALU
                    outflags[`SET_SB_TO_ALU] = 1;
                    outflags[`LOAD_SP] = 1;
                    
                    //Set input B to Data
                    outflags[`SET_DB_TO_DATA] = 1;
                    outflags[`SET_INPUT_B_TO_DB] = 1;

                    //Set A to 0
                    outflags[`SET_INPUT_A_TO_LOW] = 1;

                    //Save Data in ALU
                    outflags[`ALU_ADD] = 1;
                    outflags[`LOAD_ALU] = 1;
                end
                `T3: begin
                    //Update ABL
                    outflags[`SET_ADL_TO_ALU] = 1;
                    outflags[`LOAD_ABL] = 1;

                    //Update ABH
                    outflags[`SET_ADH_TO_DATA] = 1;
                    outflags[`LOAD_ABH] = 1;

                    //Update PC
                    outflags[`LOAD_PC] = 1;
                    outflags[`PC_INC] = 1;
                end
                `T4: begin
                    //Increment PC
                    outflags[`PC_INC] = 1;

                    //set ABH and ABL to PC
                    outflags[`SET_ADH_TO_PCH] = 1;
                    outflags[`LOAD_ABH] = 1;
                    outflags[`SET_ADL_TO_PCL] = 1;
                    outflags[`LOAD_ABL] = 1;
                end
                `T5: begin
                    //Increment PC
                    outflags[`PC_INC] = 1;

                    //set ABH and ABL to PC
                    outflags[`SET_ADH_TO_PCH] = 1;
                    outflags[`LOAD_ABH] = 1;
                    outflags[`SET_ADL_TO_PCL] = 1;
                    outflags[`LOAD_ABL] = 1;

                    outflags[`END_INSTRUCTION] = 1'b1; // signal to end the instruction
                end
                default: outflags = 0;
            endcase

            end
            `SBC: begin                                          // code SBC

            outflags = 0;
            case (state)
                `T0: begin
                    //Increment PC
                    outflags[`PC_INC] = 1;

                    //set ABH and ABL to PC
                    outflags[`SET_ADH_TO_PCH] = 1;
                    outflags[`LOAD_ABH] = 1;
                    outflags[`SET_ADL_TO_PCL] = 1;
                    outflags[`LOAD_ABL] = 1;

                    //Set input b
                    outflags[`SET_DB_TO_DATA] = 1;
                    outflags[`SET_INPUT_B_TO_NOT_DB] = 1;

                    //set carry
                    outflags[`SET_ALU_CARRY_TO_PSR_CARRY] = 1;
                    outflags[`SET_ALU_DEC_TO_PSR_DEC] = 1;

                    //set input a
                    outflags[`SET_SB_TO_ACC] = 1;
                    outflags[`SET_INPUT_A_TO_SB] = 1;

                    //SUBTRACT ACC+C-DATA
                    outflags[`ALU_ADD] = 1;
                    outflags[`LOAD_ALU] = 1;
                    outflags[`SET_PSR_CARRY_TO_ALU_CARRY] = 1;
                    outflags[`SET_PSR_OVERFLOW_TO_ALU_OVERFLOW] = 1;
                
                end
                `T1: begin
                    //Increment PC
                    outflags[`PC_INC] = 1;

                    //set ABH and ABL to PC
                    outflags[`SET_ADH_TO_PCH] = 1;
                    outflags[`LOAD_ABH] = 1;
                    outflags[`SET_ADL_TO_PCL] = 1;
                    outflags[`LOAD_ABL] = 1;

                    //Move ALU to ACC
                    outflags[`SET_SB_TO_ALU] = 1;
                    outflags[`SET_DB_TO_SB] = 1;
                    outflags[`LOAD_ACC] = 1;

                    //Set PSR from ALU outflags
                    
                    outflags[`WRITE_ZERO_FLAG] = 1;
                    outflags[`SET_PSR_N_TO_DB7] = 1;

                    outflags[`END_INSTRUCTION] = 1'b1; // signal to end the instruction

                end
                default: outflags = 0;
            endcase

            end
            `SEC: begin                                          // code SEC

            outflags = 0;
            case (state)
                `T0: begin
                    //Set FLAG
                    outflags[`PSR_DATA_TO_LOAD] = 1;
                    outflags[`LOAD_CARRY_PSR_FLAG] = 1;
                
                end
                `T1: begin
                    //Increment PC and set ABH and ABL to PC
                    outflags[`PC_INC] = 1;
                    outflags[`SET_ADH_TO_PCH] = 1;
                    outflags[`LOAD_ABH] = 1;
                    outflags[`SET_ADL_TO_PCL] = 1;
                    outflags[`LOAD_ABL] = 1;

                    outflags[`END_INSTRUCTION] = 1'b1; // signal to end the instruction
                end
                default: outflags = 0;
            endcase

            end
            `SED: begin                                          // code SED

            outflags = 0;
            case (state)
                `T0: begin
                    //Set FLAG
                    outflags[`PSR_DATA_TO_LOAD] = 1;
                    outflags[`LOAD_DECIMAL_PSR_FLAG] = 1;
                
                end
                `T1: begin
                    //Increment PC and set ABH and ABL to PC
                    outflags[`PC_INC] = 1;
                    outflags[`SET_ADH_TO_PCH] = 1;
                    outflags[`LOAD_ABH] = 1;
                    outflags[`SET_ADL_TO_PCL] = 1;
                    outflags[`LOAD_ABL] = 1;

                    outflags[`END_INSTRUCTION] = 1'b1; // signal to end the instruction
                end
                default: outflags = 0;
            endcase

            end
            `SEI: begin                                          // code SEI

            outflags = 0;
            case (state)
                `T0: begin
                    //Set FLAG
                    outflags[`PSR_DATA_TO_LOAD] = 1;
                    outflags[`LOAD_INTERUPT_PSR_FLAG] = 0;
                
                end
                `T1: begin
                    //Increment PC and set ABH and ABL to PC
                    outflags[`PC_INC] = 1;
                    outflags[`SET_ADH_TO_PCH] = 1;
                    outflags[`LOAD_ABH] = 1;
                    outflags[`SET_ADL_TO_PCL] = 1;
                    outflags[`LOAD_ABL] = 1;

                    outflags[`END_INSTRUCTION] = 1'b1; // signal to end the instruction
                end
                default: outflags = 0;
            endcase

            end
            `STA, `STX, `STY: begin                                          // code STO (STA, STX, STY) WE NEED TO ADD LOGIC TO STORE TO A, X, OR Y
            
            outflags = 0;
            case (state)
                `T0: begin
                    outflags[`PC_INC] = 1;
                    outflags[`SET_ADH_TO_PCH] = 1;
                    outflags[`LOAD_ABH] = 1;
                    outflags[`SET_ADL_TO_PCL] = 1;
                    outflags[`LOAD_ABL] = 1;
                
                end
                `T1: begin
                    //Increment PC and set ABH and ABL to PC
                    outflags[`PC_INC] = 1;
                    outflags[`SET_ADH_TO_PCH] = 1;
                    outflags[`LOAD_ABH] = 1;
                    outflags[`SET_ADL_TO_PCL] = 1;
                    outflags[`LOAD_ABL] = 1;

                    outflags[`END_INSTRUCTION] = 1'b1; // signal to end the instruction
                end
                default: outflags = 0;
            endcase

            end
            `TAX: begin                                          // code TAX

            outflags = 0;
            case (state)
                `T0: begin
                    //Set signal on the stack bus
                    outflags[`SET_SB_TO_ACC] = 1;
                    
                    //update registar
                    outflags[`LOAD_X] = 1;
                end
                `T1: begin
                    //Increment PC and set ABH and ABL to PC
                    outflags[`PC_INC] = 1;
                    outflags[`SET_ADH_TO_PCH] = 1;
                    outflags[`LOAD_ABH] = 1;
                    outflags[`SET_ADL_TO_PCL] = 1;
                    outflags[`LOAD_ABL] = 1;
                    
                    outflags[`END_INSTRUCTION] = 1'b1; // signal to end the instruction
                end
                default: outflags = 0;
            endcase

            end
            `TAY: begin                                          // code TAY

            outflags = 0;
            case (state)
                `T0: begin
                    //Set signal on the stack bus
                    outflags[`SET_SB_TO_ACC] = 1;
                    
                    //update registar
                    outflags[`LOAD_Y] = 1;
                end
                `T1: begin
                    //Increment PC and set ABH and ABL to PC
                    outflags[`PC_INC] = 1;
                    outflags[`SET_ADH_TO_PCH] = 1;
                    outflags[`LOAD_ABH] = 1;
                    outflags[`SET_ADL_TO_PCL] = 1;
                    outflags[`LOAD_ABL] = 1;
                    
                    outflags[`END_INSTRUCTION] = 1'b1; // signal to end the instruction
                end
                default: outflags = 0;
            endcase

            end
            `TSX: begin                                          // code TSX

        outflags = 0;
            case (state)
                `T0: begin
                    //Set signal on the stack bus
                    outflags[`SET_SB_TO_SP] = 1;
                    
                    //update registar
                    outflags[`LOAD_X] = 1;
                end
                `T1: begin
                    //Increment PC and set ABH and ABL to PC
                    outflags[`PC_INC] = 1;
                    outflags[`SET_ADH_TO_PCH] = 1;
                    outflags[`LOAD_ABH] = 1;
                    outflags[`SET_ADL_TO_PCL] = 1;
                    outflags[`LOAD_ABL] = 1;
                    
                    outflags[`END_INSTRUCTION] = 1'b1; // signal to end the instruction
                end
                default: outflags = 0;
            endcase

            end
            `TXA: begin                                          // code TXA

            outflags = 0;
            case (state)
                `T0: begin
                    //Set signal on the stack bus
                    outflags[`SET_SB_TO_X] = 1;
                    
                    //update registar
                    outflags[`LOAD_ACC] = 1;
                end
                `T1: begin
                    //Increment PC and set ABH and ABL to PC
                    outflags[`PC_INC] = 1;
                    outflags[`SET_ADH_TO_PCH] = 1;
                    outflags[`LOAD_ABH] = 1;
                    outflags[`SET_ADL_TO_PCL] = 1;
                    outflags[`LOAD_ABL] = 1;
                    
                    outflags[`END_INSTRUCTION] = 1'b1; // signal to end the instruction
                end
                default: outflags = 0;
            endcase

            end
            `TXS: begin                                          // code TXS

            outflags = 0;
            case (state)
                `T0: begin
                    //Set signal on the stack bus
                    outflags[`SET_SB_TO_X] = 1;
                    
                    //update registar
                    outflags[`LOAD_SP] = 1;
                end
                `T1: begin
                    //Increment PC and set ABH and ABL to PC
                    outflags[`PC_INC] = 1;
                    outflags[`SET_ADH_TO_PCH] = 1;
                    outflags[`LOAD_ABH] = 1;
                    outflags[`SET_ADL_TO_PCL] = 1;
                    outflags[`LOAD_ABL] = 1;
                    
                    outflags[`END_INSTRUCTION] = 1'b1; // signal to end the instruction
                end
                default: outflags = 0;
            endcase

            end
            `ASLA: begin                                          // code ASLA

                outflags = 0;
            case (state)
                `T0:  begin
                    //Set B and A to input data
                    outflags[`SET_DB_TO_ACC] = 1;
                    outflags[`SET_SB_TO_ACC] = 1;
                    outflags[`SET_INPUT_A_TO_SB] = 1;
                    outflags[`SET_INPUT_B_TO_DB] = 1;
                    
                    //Add them together
                    outflags[`ALU_ADD] = 1;
                    outflags[`LOAD_ALU] = 1;
                    
                    //SET FLAGS
                    outflags[`SET_PSR_CARRY_TO_ALU_CARRY] = 1;
                end
                `T1: begin
                    //Increment PC and set ABH and ABL to PC
                    outflags[`PC_INC] = 1;
                    outflags[`SET_ADH_TO_PCH] = 1;
                    outflags[`LOAD_ABH] = 1;
                    outflags[`SET_ADL_TO_PCL] = 1;
                    outflags[`LOAD_ABL] = 1;
                    
                    //Move ALU to ACC
                    outflags[`SET_SB_TO_ALU] = 1;
                    outflags[`LOAD_ACC] = 1;

                    //Set PSR FLAGS
                    outflags[`SET_DB_TO_SB] = 1;
                    outflags[`WRITE_ZERO_FLAG] = 1;
                    outflags[`SET_PSR_N_TO_DB7] = 1;

                    outflags[`END_INSTRUCTION] = 1'b1; // signal to end the instruction
                end
                default: outflags = 0;
            endcase

            end
            `ROLA: begin                                          // code ROLA
                outflags = 0;
            case (state)
                `T0: begin
                    //Set B and A to input data
                    outflags[`SET_DB_TO_ACC] = 1;
                    outflags[`SET_SB_TO_ACC] = 1;
                    outflags[`SET_INPUT_A_TO_SB] = 1;
                    outflags[`SET_INPUT_B_TO_DB] = 1;
                    outflags[`SET_ALU_CARRY_TO_PSR_CARRY] = 1;
                    
                    //Add them together
                    outflags[`ALU_ADD] = 1;
                    outflags[`LOAD_ALU] = 1;
                    //SET outflags
                    outflags[`SET_PSR_CARRY_TO_ALU_CARRY] = 1;
                end
                `T1: begin
                    //Increment PC and set ABH and ABL to PC
                    outflags[`PC_INC] = 1;
                    outflags[`SET_ADH_TO_PCH] = 1;
                    outflags[`LOAD_ABH] = 1;
                    outflags[`SET_ADL_TO_PCL] = 1;
                    outflags[`LOAD_ABL] = 1;

                    //Move ALU to ACC
                    outflags[`SET_SB_TO_ALU] = 1;
                    outflags[`LOAD_ACC] = 1;

                    //Set PSR outflags
                    outflags[`SET_DB_TO_SB] = 1;
                    outflags[`WRITE_ZERO_FLAG] = 1;
                    outflags[`SET_PSR_N_TO_DB7] = 1;

                    outflags[`END_INSTRUCTION] = 1'b1; // signal to end the instruction
                end
                default: outflags = 0;
            endcase
            end
            `LSRA: begin                                          // code LSRA
            
            outflags = 0;
            case (state)
                `T0: begin
                    //Set A to ACC
                    outflags[`SET_SB_TO_ACC] = 1;
                    outflags[`SET_INPUT_A_TO_SB] = 1;
                    
                    //Shift
                    outflags[`ALU_R_SHIFT] = 1;
                    outflags[`LOAD_ALU] = 1;
                    
                    //SET outflags
                    outflags[`SET_PSR_CARRY_TO_ALU_CARRY] = 1;
                end
                `T1: begin
                    //Increment PC and set ABH and ABL to PC
                    outflags[`PC_INC] = 1;
                    outflags[`SET_ADH_TO_PCH] = 1;
                    outflags[`LOAD_ABH] = 1;
                    outflags[`SET_ADL_TO_PCL] = 1;
                    outflags[`LOAD_ABL] = 1;
                    
                    //Move ALU to ACC
                    outflags[`SET_SB_TO_ALU] = 1;
                    outflags[`LOAD_ACC] = 1;

                    //Set PSR outflags
                    outflags[`SET_DB_TO_SB] = 1;
                    outflags[`WRITE_ZERO_FLAG] = 1;
                    outflags[`SET_PSR_N_TO_DB7] = 1;

                    outflags[`END_INSTRUCTION] = 1'b1; // signal to end the instruction
                    end
                default: outflags = 0;
            endcase

            end

            `RORA: begin                                          // code RORA

            outflags = 0;
            case (state)
                `T0: begin
                    //Set A to ACC
                    outflags[`SET_SB_TO_ACC] = 1;
                    outflags[`SET_INPUT_A_TO_SB] = 1;
                    outflags[`SET_ALU_CARRY_TO_PSR_CARRY] = 1;
                    
                    //Rotate
                    outflags[`ALU_R_SHIFT] = 1;
                    outflags[`LOAD_ALU] = 1;
                    
                    //SET outflags
                    outflags[`SET_PSR_CARRY_TO_ALU_CARRY] = 1;
                end
                `T1: begin
                    //Increment PC and set ABH and ABL to PC
                    outflags[`PC_INC] = 1;
                    outflags[`SET_ADH_TO_PCH] = 1;
                    outflags[`LOAD_ABH] = 1;
                    outflags[`SET_ADL_TO_PCL] = 1;
                    outflags[`LOAD_ABL] = 1;
                    
                    //Move ALU to ACC
                    outflags[`SET_SB_TO_ALU] = 1;
                    outflags[`LOAD_ACC] = 1;
                    
                    //Set PSR outflags
                    outflags[`SET_DB_TO_SB] = 1;
                    outflags[`WRITE_ZERO_FLAG] = 1;
                    outflags[`SET_PSR_N_TO_DB7] = 1;

                    outflags[`END_INSTRUCTION] = 1'b1; // signal to end the instruction
                end
                default: outflags = 0;
            endcase

            end
            `TYA: begin                                          // code TYA

            outflags = 0;
            case (state)
                `T0: begin
                    //Set signal on the stack bus
                    outflags[`SET_SB_TO_Y] = 1;
                    
                    //update registar
                    outflags[`LOAD_ACC] = 1;
                end
                `T1: begin
                    //Increment PC and set ABH and ABL to PC
                    outflags[`PC_INC] = 1;
                    outflags[`SET_ADH_TO_PCH] = 1;
                    outflags[`LOAD_ABH] = 1;
                    outflags[`SET_ADL_TO_PCL] = 1;
                    outflags[`LOAD_ABL] = 1;
                    
                    outflags[`END_INSTRUCTION] = 1'b1; // signal to end the instruction
                end
                default: outflags = 0;
            endcase

            end
            default: outflags = 0;
        endcase

    end

    // //*
    // if(setInterruptFlag)
    // begin
    //     load_psr_I = 1'b1;
    //     psr_data_to_load = 1'b1;
    // end else //*/
    // begin
    //     load_psr_I = 1'b0;
    //     psr_data_to_load = 1'b0;
    // end
  
    if(~enableFFs)  begin // VERY IMPORTANT: THIS HALTS 2/3RDS OF CLOCK CYCLES
        outflags = 0;
        load_psr_I = 0;
    end
end

always_comb begin : readNotWriteAssignment
    readNotWrite = 1;
    if(~isAddressing | passAddressing) begin
        //Store Instructions
        if (instructionCode == `STA | instructionCode == `STX | instructionCode == `STY)
        begin
            if (state == `T0)
                readNotWrite = 0;
        end
        //RMW Instructions
        else if( instructionCode == `ASL | instructionCode == `DEC | instructionCode == `INC | instructionCode == `LSR | instructionCode == `ROL | instructionCode == `ROR )
        begin
            if (state == `T1 | state == `T2)
                    readNotWrite = 0;
        end
        else if (instructionCode == `BRK)
        begin
            if (state == `T1 | state == `T2 | state == `T3)
                readNotWrite = reset;
        end
        else if (instructionCode == `JSR)
        begin
            if(state == `T2 | state == `T3)
                readNotWrite = 0;
        end
        else if (instructionCode == `PHA | instructionCode == `PHP)
        begin
            if(state == `T1)
                readNotWrite = 0;
        end
    end
end

endmodule
