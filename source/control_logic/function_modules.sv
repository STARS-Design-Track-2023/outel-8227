`include "param_file.sv"

/*
* Finished Modules:
* 1. Single byte instructions: ALL, Finished FLAGS I THINK
* 2. Internal Execution on Memory Data: ALL
* 3. Store Operations: ALL
* 4. Read Modify Write: ALL
* 5. Misc.: PSP PLP , PSA, PLA, BRK, JSR, 
*/

module ASL_A(
    input logic [2:0] state,
    output logic [NUMFLAGS-1:0] flags
);

always_comb begin
    flags = 0;
    case (state)
        T0:  begin
            //Set B and A to input data
            flags[SET_DB_TO_ACC] = 1;
            flags[SET_SB_TO_ACC] = 1;
            flags[SET_INPUT_A_TO_SB] = 1;
            flags[SET_INPUT_B_TO_DB] = 1;
            
            //Add them together
            flags[ALU_ADD] = 1;
            flags[LOAD_ALU] = 1;
            
            //SET FLAGS
            flags[SET_PSR_CARRY_TO_ALU_CARRY_OUT] = 1;
        end
        T1: begin
            //Increment PC and set ABH and ABL to PC
            flags[PC_INC] = 1;
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;
            
            //Move ALU to ACC
            flags[SET_SB_TO_ALU] = 1;
            flags[LOAD_ACC] = 1;

            //Set PSR FLAGS
            flags[SET_DB_TO_SB] = 1;
            flags[WRITE_ZERO_FLAG] = 1;
            flags[WRITE_NEGATIVE_FLAG] = 1;
        end
        default: flags = 0;
    endcase
end
    
endmodule

module ROL_A(
    input logic [2:0] state,
    output logic [NUMFLAGS-1:0] flags
);

always_comb begin
    flags = 0;
    case (state)
        T0: begin
            //Set B and A to input data
            flags[SET_DB_TO_ACC] = 1;
            flags[SET_SB_TO_ACC] = 1;
            flags[SET_INPUT_A_TO_SB] = 1;
            flags[SET_INPUT_B_TO_DB] = 1;
            flags[SET_ALU_CARRY_TO_PSR_CARRY] = 1;
            
            //Add them together
            flags[ALU_ADD] = 1;
            flags[LOAD_ALU] = 1;
            //SET FLAGS
            flags[SET_PSR_CARRY_TO_ALU_CARRY_OUT] = 1;
        end
        T1: begin
            //Increment PC and set ABH and ABL to PC
            flags[PC_INC] = 1;
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;

            //Move ALU to ACC
            flags[SET_SB_TO_ALU] = 1;
            flags[LOAD_ACC] = 1;

            //Set PSR FLAGS
            flags[SET_DB_TO_SB] = 1;
            flags[WRITE_ZERO_FLAG] = 1;
            flags[WRITE_NEGATIVE_FLAG] = 1;
        end
        default: flags = 0;
    endcase
end
    
endmodule

module ROR_A(
    input logic [2:0] state,
    output logic [NUMFLAGS-1:0] flags
);

always_comb begin
    flags = 0;
    case (state)
        T0: begin
            //Set A to ACC
            flags[SET_SB_TO_ACC] = 1;
            flags[SET_INPUT_A_TO_SB] = 1;
            flags[SET_ALU_CARRY_TO_PSR_CARRY] = 1;
            
            //Rotate
            flags[ALU_R_SHIFT] = 1;
            flags[LOAD_ALU] = 1;
            
            //SET FLAGS
            flags[SET_PSR_CARRY_TO_ALU_CARRY_OUT] = 1;
        end
        T1: begin
            //Increment PC and set ABH and ABL to PC
            flags[PC_INC] = 1;
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;
            
            //Move ALU to ACC
            flags[SET_SB_TO_ALU] = 1;
            flags[LOAD_ACC] = 1;
            
            //Set PSR FLAGS
            flags[SET_DB_TO_SB] = 1;
            flags[WRITE_ZERO_FLAG] = 1;
            flags[WRITE_NEGATIVE_FLAG] = 1;
        end
        default: flags = 0;
    endcase
end
    
endmodule

module LSR_A(
    input logic [2:0] state,
    output logic [NUMFLAGS-1:0] flags
);

always_comb begin
    flags = 0;
    case (state)
        T0: begin
            //Set A to ACC
            flags[SET_SB_TO_ACC] = 1;
            flags[SET_INPUT_A_TO_SB] = 1;
            
            //Shift
            flags[ALU_R_SHIFT] = 1;
            flags[LOAD_ALU] = 1;
            
            //SET FLAGS
            flags[SET_PSR_CARRY_TO_ALU_CARRY_OUT] = 1;
        end
        T1: begin
            //Increment PC and set ABH and ABL to PC
            flags[PC_INC] = 1;
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;
            
            //Move ALU to ACC
            flags[SET_SB_TO_ALU] = 1;
            flags[LOAD_ACC] = 1;

            //Set PSR FLAGS
            flags[SET_DB_TO_SB] = 1;
            flags[WRITE_ZERO_FLAG] = 1;
            flags[WRITE_NEGATIVE_FLAG] = 1;
            end
        default: flags = 0;
    endcase
end
    
endmodule

module DEX(
    input logic [2:0] state,
    output logic [NUMFLAGS-1:0] flags
);

always_comb begin
    flags = 0;
    case (state)
        T0: begin
            //Set B and A to be FF and Y
            flags[SET_DB_HIGH] = 1;
            flags[SET_INPUT_A_TO_SB] = 1;
            flags[SET_INPUT_B_TO_DB] = 1;
            
            //What to increment
            flags[SET_SB_TO_X] = 1;
            
            //Add them together
            flags[ALU_ADD] = 1;
            flags[LOAD_ALU] = 1;
        end
        T1: begin
            //Increment PC and set ABH and ABL to PC
            flags[PC_INC] = 1;
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;
            //Move ALU to X
            flags[SET_SB_TO_ALU] = 1;
            flags[LOAD_X] = 1;
        end
        default: flags = 0;
    endcase
end
    
endmodule

module DEY(
    input logic [2:0] state,
    output logic [NUMFLAGS-1:0] flags
);

always_comb begin
    flags = 0;
    case (state)
        T0: begin
            //Set B and A to be FF and Y
            flags[SET_DB_HIGH] = 1;
            flags[SET_INPUT_A_TO_SB] = 1;
            flags[SET_INPUT_B_TO_DB] = 1;
            
            //What to decrement
            flags[SET_SB_TO_Y] = 1;

            //Add them together
            flags[ALU_ADD] = 1;
            flags[LOAD_ALU] = 1;
        end
        T1: begin
            //Increment PC and set ABH and ABL to PC
            flags[PC_INC] = 1;
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;
            //Move ALU to Y
            flags[SET_SB_TO_ALU] = 1;
            flags[LOAD_Y] = 1;
        end
        default: flags = 0;
    endcase
end
    
endmodule

module INY(
    input logic [2:0] state,
    output logic [NUMFLAGS-1:0] flags
);

always_comb begin
    flags = 0;
    case (state)
        T0: begin
            //Set C B and A to be 1 Y and 0
            flags[SET_SB_TO_Y] = 1;
            flags[SET_DB_TO_SB] = 1;
            flags[SET_INPUT_B_TO_DB] = 1;
            flags[SET_ALU_CARRY_HIGH] = 1;
            flags[SET_INPUT_A_TO_LOW] = 1;
            
            //Add them together
            flags[ALU_ADD] = 1;
            flags[LOAD_ALU] = 1;
        end
        T1: begin
            //Increment PC and set ABH and ABL to PC
            flags[PC_INC] = 1;
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;
            //Move ALU to Y
            flags[SET_SB_TO_ALU] = 1;
            flags[LOAD_Y] = 1;
        end
        default: flags = 0;
    endcase
end
    
endmodule

module INX(
    input logic [2:0] state,
    output logic [NUMFLAGS-1:0] flags
);

always_comb begin
    flags = 0;
    case (state)
        T0: begin
            //Set B and A to input data
            flags[SET_SB_TO_X] = 1;
            flags[SET_DB_TO_SB] = 1;
            flags[SET_INPUT_B_TO_DB] = 1;
            flags[SET_ALU_CARRY_HIGH] = 1;
            flags[SET_INPUT_A_TO_LOW] = 1;
            
            //Add them together
            flags[ALU_ADD] = 1;
            flags[LOAD_ALU] = 1;
        end
        T1: begin
            //Increment PC and set ABH and ABL to PC
            flags[PC_INC] = 1;
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;
            //Move ALU to X
            flags[SET_SB_TO_ALU] = 1;
            flags[LOAD_X] = 1;
        end
        default: flags = 0;
    endcase
end
    
endmodule

module NOP(
    input logic [2:0] state,
    output logic [NUMFLAGS-1:0] flags
);

always_comb begin
    flags = 0;
    case (state)
        T0: begin
            
        end
        T1: begin
            //Increment PC and set ABH and ABL to PC
            flags[PC_INC] = 1;
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;
            
        end
        default: flags = 0;
    endcase
end
    
endmodule


module TAX(
    input logic [2:0] state,
    output logic [NUMFLAGS-1:0] flags
);

always_comb begin
    flags = 0;
    case (state)
        T0: begin
            //Set signal on the stack bus
            flags[SET_SB_TO_ACC] = 1;
            
            //update registar
            flags[LOAD_X] = 1;
        end
        T1: begin
            //Increment PC and set ABH and ABL to PC
            flags[PC_INC] = 1;
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;
            
        end
        default: flags = 0;
    endcase
end
    
endmodule

module TAY(
    input logic [2:0] state,
    output logic [NUMFLAGS-1:0] flags
);

always_comb begin
    flags = 0;
    case (state)
        T0: begin
            //Set signal on the stack bus
            flags[SET_SB_TO_ACC] = 1;
            
            //update registar
            flags[LOAD_Y] = 1;
        end
        T1: begin
            //Increment PC and set ABH and ABL to PC
            flags[PC_INC] = 1;
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;
            
        end
        default: flags = 0;
    endcase
end
    
endmodule

module TSX(
    input logic [2:0] state,
    output logic [NUMFLAGS-1:0] flags
);

always_comb begin
    flags = 0;
    case (state)
        T0: begin
            //Set signal on the stack bus
            flags[SET_SB_TO_SP] = 1;
            
            //update registar
            flags[LOAD_X] = 1;
        end
        T1: begin
            //Increment PC and set ABH and ABL to PC
            flags[PC_INC] = 1;
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;
            
        end
        default: flags = 0;
    endcase
end
    
endmodule

module TXA(
    input logic [2:0] state,
    output logic [NUMFLAGS-1:0] flags
);

always_comb begin
    flags = 0;
    case (state)
        T0: begin
            //Set signal on the stack bus
            flags[SET_SB_TO_X] = 1;
            
            //update registar
            flags[LOAD_ACC] = 1;
        end
        T1: begin
            //Increment PC and set ABH and ABL to PC
            flags[PC_INC] = 1;
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;
            
        end
        default: flags = 0;
    endcase
end
    
endmodule

module TXS(
    input logic [2:0] state,
    output logic [NUMFLAGS-1:0] flags
);

always_comb begin
    flags = 0;
    case (state)
        T0: begin
            //Set signal on the stack bus
            flags[SET_SB_TO_X] = 1;
            
            //update registar
            flags[LOAD_SP] = 1;
        end
        T1: begin
            //Increment PC and set ABH and ABL to PC
            flags[PC_INC] = 1;
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;
            
        end
        default: flags = 0;
    endcase
end
    
endmodule

module TYA(
    input logic [2:0] state,
    output logic [NUMFLAGS-1:0] flags
);

always_comb begin
    flags = 0;
    case (state)
        T0: begin
            //Set signal on the stack bus
            flags[SET_SB_TO_Y] = 1;
            
            //update registar
            flags[LOAD_ACC] = 1;
        end
        T1: begin
            //Increment PC and set ABH and ABL to PC
            flags[PC_INC] = 1;
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;
            
        end
        default: flags = 0;
    endcase
end

endmodule

module SEC(
    input logic [2:0] state,
    output logic [NUMFLAGS-1:0] flags
);

always_comb begin
    flags = 0;
    case (state)
        T0: begin
            //Set FLAG
            flags[PSR_DATA_TO_LOAD] = 1;
            flags[LOAD_CARRY_PSR_FLAG] = 1;
        
        end
        T1: begin
            //Increment PC and set ABH and ABL to PC
            flags[PC_INC] = 1;
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;
        end
        default: flags = 0;
    endcase
end

endmodule

module SED(
    input logic [2:0] state,
    output logic [NUMFLAGS-1:0] flags
);

always_comb begin
    flags = 0;
    case (state)
        T0: begin
            //Set FLAG
            flags[PSR_DATA_TO_LOAD] = 1;
            flags[LOAD_DECIMAL_PSR_FLAG] = 1;
        
        end
        T1: begin
            //Increment PC and set ABH and ABL to PC
            flags[PC_INC] = 1;
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;
        end
        default: flags = 0;
    endcase
end

endmodule

module SEI(
    input logic [2:0] state,
    output logic [NUMFLAGS-1:0] flags
);

always_comb begin
    flags = 0;
    case (state)
        T0: begin
            //Set FLAG
            flags[PSR_DATA_TO_LOAD] = 1;
            flags[LOAD_INTERUPT_PSR_FLAG] = 1;
        
        end
        T1: begin
            //Increment PC and set ABH and ABL to PC
            flags[PC_INC] = 1;
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;
        end
        default: flags = 0;
    endcase
end

endmodule

module CLC(
    input logic [2:0] state,
    output logic [NUMFLAGS-1:0] flags
);

always_comb begin
    flags = 0;
    case (state)
        T0: begin
            //Set FLAG
            flags[PSR_DATA_TO_LOAD] = 1;
            flags[LOAD_CARRY_PSR_FLAG] = 0;
        
        end
        T1: begin
            //Increment PC and set ABH and ABL to PC
            flags[PC_INC] = 1;
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;
        end
        default: flags = 0;
    endcase
end

endmodule

module CLD(
    input logic [2:0] state,
    output logic [NUMFLAGS-1:0] flags
);

always_comb begin
    flags = 0;
    case (state)
        T0: begin
            //Set FLAG
            flags[PSR_DATA_TO_LOAD] = 1;
            flags[LOAD_DECIMAL_PSR_FLAG] = 0;
        
        end
        T1: begin
            //Increment PC and set ABH and ABL to PC
            flags[PC_INC] = 1;
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;
        end
        default: flags = 0;
    endcase
end

endmodule

module CLI(
    input logic [2:0] state,
    output logic [NUMFLAGS-1:0] flags
);

always_comb begin
    flags = 0;
    case (state)
        T0: begin
            //Set FLAG
            flags[PSR_DATA_TO_LOAD] = 1;
            flags[LOAD_INTERUPT_PSR_FLAG] = 0;
        
        end
        T1: begin
            //Increment PC and set ABH and ABL to PC
            flags[PC_INC] = 1;
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;
        end
        default: flags = 0;
    endcase
end

endmodule

module CLV(
    input logic [2:0] state,
    output logic [NUMFLAGS-1:0] flags
);

always_comb begin
    flags = 0;
    case (state)
        T0: begin
            //Set FLAG
            flags[PSR_DATA_TO_LOAD] = 1;
            flags[LOAD_OVERFLOW_PSR_FLAG] = 0;
        
        end
        T1: begin
            //Increment PC and set ABH and ABL to PC
            flags[PC_INC] = 1;
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;
        end
        default: flags = 0;
    endcase
end

endmodule

//All store opperations are the same

module STO(
    input logic [2:0] state,
    output logic [NUMFLAGS-1:0] flags
);

always_comb begin
    flags = 0;
    case (state)
        T0: begin
            //Set FLAG
            flags[SET_WRITE_FLAG] = 1;
        
        end
        T1: begin
            //Increment PC and set ABH and ABL to PC
            flags[PC_INC] = 1;
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;
        end
        default: flags = 0;
    endcase
end

endmodule

//START INTERNAL EXECUTION MEMORY OPS

module ADC(
    input logic [2:0] state,
    output logic [NUMFLAGS-1:0] flags
);

always_comb begin
    flags = 0;
    case (state)
        T0: begin
            //Increment PC
            flags[PC_INC] = 1;

            //set ABH and ABL to PC
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;

            //Set input b
            flags[SET_DB_TO_DATA] = 1;
            flags[SET_INPUT_B_TO_DB] = 1;

            //set carry
            flags[SET_ALU_CARRY_TO_PSR_CARRY] = 1;
            flags[SET_ALU_DEC_TO_PSR_DEC] = 1;

            //set input a
            flags[SET_SB_TO_ACC] = 1;
            flags[SET_INPUT_A_TO_SB] = 1;

            //add ACC+C+DATA
            flags[ALU_ADD] = 1;
            flags[LOAD_ALU] = 1;
            flags[SET_PSR_CARRY_TO_ALU_CARRY] = 1;
            flags[SET_PSR_OVERFLOW_TO_ALU_OVERFLOW] = 1;
        
        end
        T1: begin
            //Increment PC
            flags[PC_INC] = 1;

            //set ABH and ABL to PC
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;

            //Move ALU to ACC
            flags[SET_SB_TO_ALU] = 1;
            flags[SET_DB_TO_SB] = 1;
            flags[LOAD_ACC] = 1;

            //Set PSR from ALU Flags
            
            flags[WRITE_ZERO_FLAG] = 1;
            flags[WRITE_NEGATIVE_FLAG] = 1;

        end
        default: flags = 0;
    endcase
end

endmodule

module AND(
    input logic [2:0] state,
    output logic [NUMFLAGS-1:0] flags
);

always_comb begin
    flags = 0;
    case (state)
        T0: begin
            //Increment PC
            flags[PC_INC] = 1;

            //set ABH and ABL to PC
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;

            //Set input b
            flags[SET_DB_TO_DATA] = 1;
            flags[SET_INPUT_B_TO_DB] = 1;

            //set input a
            flags[SET_SB_TO_ACC] = 1;
            flags[SET_INPUT_A_TO_SB] = 1;

            //add ACC+C+DATA
            flags[ALU_AND] = 1;
            flags[LOAD_ALU] = 1;
        
        end
        T1: begin
            //Increment PC
            flags[PC_INC] = 1;

            //set ABH and ABL to PC
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;

            //Move ALU to ACC
            flags[SET_SB_TO_ALU] = 1;
            flags[SET_DB_TO_SB] = 1;
            flags[LOAD_ACC] = 1;

            //Set PSR from ALU Flags
            
            flags[WRITE_ZERO_FLAG] = 1;
            flags[WRITE_NEGATIVE_FLAG] = 1;
        end
        default: flags = 0;
    endcase
end

endmodule


module BIT(
    input logic [2:0] state,
    output logic [NUMFLAGS-1:0] flags
);

always_comb begin
    flags = 0;
    case (state)
        T0: begin
            //Increment PC
            flags[PC_INC] = 1;

            //set ABH and ABL to PC
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;

            //Set input b
            flags[SET_DB_TO_DATA] = 1;
            flags[SET_INPUT_B_TO_DB] = 1;

            //set input a
            flags[SET_SB_TO_ACC] = 1;
            flags[SET_INPUT_A_TO_SB] = 1;

            //And ACC&M
            flags[ALU_AND] = 1;
            flags[LOAD_ALU] = 1;
        
        end
        T1: begin
            //Increment PC
            flags[PC_INC] = 1;

            //set ABH and ABL to PC
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;

            //Set PSR from ALU Flags
            flags[SET_PSR_N_TO_DB7] = 1;
            flags[SET_PSR_V_TO_DB6] = 1;
            flags[WRITE_ZERO_FLAG] = 1;
        end
        default: flags = 0;
    endcase
end

endmodule

module CMP(
    input logic [2:0] state,
    output logic [NUMFLAGS-1:0] flags
);

always_comb begin
    flags = 0;
    case (state)
        T0: begin
            //Increment PC
            flags[PC_INC] = 1;

            //set ABH and ABL to PC
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;

            //Set input b
            flags[SET_DB_TO_DATA] = 1;
            flags[SET_INPUT_B_TO_NOT_DB] = 1;
            flags[SET_ALU_CARRY_HIGH] = 1;

            //set input a
            flags[SET_SB_TO_ACC] = 1;
            flags[SET_INPUT_A_TO_SB] = 1;

            //Subtract X-M
            flags[ALU_ADD] = 1;
            flags[LOAD_ALU] = 1;
            flags[SET_PSR_CARRY_TO_ALU_CARRY] = 1;
        
        end
        T1: begin
            //Increment PC
            flags[PC_INC] = 1;

            //set ABH and ABL to PC
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;

            //Move ALU to ACC
            flags[SET_SB_TO_ALU] = 1;
            flags[SET_DB_TO_SB] = 1;

            //Set PSR from ALU Flags
            
            flags[WRITE_ZERO_FLAG] = 1;
            flags[WRITE_NEGATIVE_FLAG] = 1;

        end
        default: flags = 0;
    endcase
end

endmodule

module CPX(
    input logic [2:0] state,
    output logic [NUMFLAGS-1:0] flags
);

always_comb begin
    flags = 0;
    case (state)
        T0: begin
            //Increment PC
            flags[PC_INC] = 1;

            //set ABH and ABL to PC
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;

            //Set input b
            flags[SET_DB_TO_DATA] = 1;
            flags[SET_INPUT_B_TO_NOT_DB] = 1;
            flags[SET_ALU_CARRY_HIGH] = 1;

            //set input a
            flags[SET_SB_TO_X] = 1;
            flags[SET_INPUT_A_TO_SB] = 1;

            //Subtract Y-M
            flags[ALU_ADD] = 1;
            flags[LOAD_ALU] = 1;
            flags[SET_PSR_CARRY_TO_ALU_CARRY] = 1;
        
        end
        T1: begin
            //Increment PC
            flags[PC_INC] = 1;

            //set ABH and ABL to PC
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;

            //Move ALU to ACC
            flags[SET_SB_TO_ALU] = 1;
            flags[SET_DB_TO_SB] = 1;

            //Set PSR from ALU Flags
            
            flags[WRITE_ZERO_FLAG] = 1;
            flags[WRITE_NEGATIVE_FLAG] = 1;

        end
        default: flags = 0;
    endcase
end

endmodule

module CPY(
    input logic [2:0] state,
    output logic [NUMFLAGS-1:0] flags
);

always_comb begin
    flags = 0;
    case (state)
        T0: begin
            //Increment PC
            flags[PC_INC] = 1;

            //set ABH and ABL to PC
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;

            //Set input b
            flags[SET_DB_TO_DATA] = 1;
            flags[SET_INPUT_B_TO_NOT_DB] = 1;
            flags[SET_ALU_CARRY_HIGH] = 1;

            //set input a
            flags[SET_SB_TO_Y] = 1;
            flags[SET_INPUT_A_TO_SB] = 1;

            //Subtract ACC-M
            flags[ALU_ADD] = 1;
            flags[LOAD_ALU] = 1;
            flags[SET_PSR_CARRY_TO_ALU_CARRY] = 1;
        
        end
        T1: begin
            //Increment PC
            flags[PC_INC] = 1;

            //set ABH and ABL to PC
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;

            //Move ALU to ACC
            flags[SET_SB_TO_ALU] = 1;
            flags[SET_DB_TO_SB] = 1;

            //Set PSR from ALU Flags
            
            flags[WRITE_ZERO_FLAG] = 1;
            flags[WRITE_NEGATIVE_FLAG] = 1;

        end
        default: flags = 0;
    endcase
end

endmodule

module EOR(
    input logic [2:0] state,
    output logic [NUMFLAGS-1:0] flags
);

always_comb begin
    flags = 0;
    case (state)
        T0: begin
            //Increment PC
            flags[PC_INC] = 1;

            //set ABH and ABL to PC
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;

            //Set input b
            flags[SET_DB_TO_DATA] = 1;
            flags[SET_INPUT_B_TO_DB] = 1;

            //set input a
            flags[SET_SB_TO_ACC] = 1;
            flags[SET_INPUT_A_TO_SB] = 1;

            //add ACC+C+DATA
            flags[ALU_XOR] = 1;
            flags[LOAD_ALU] = 1;
        
        end
        T1: begin
            //Increment PC
            flags[PC_INC] = 1;

            //set ABH and ABL to PC
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;

            //Move ALU to ACC
            flags[SET_SB_TO_ALU] = 1;
            flags[SET_DB_TO_SB] = 1;
            flags[LOAD_ACC] = 1;

            //Set PSR from ALU Flags
            
            flags[WRITE_ZERO_FLAG] = 1;
            flags[WRITE_NEGATIVE_FLAG] = 1;
        end
        default: flags = 0;
    endcase
end

endmodule

module ORA(
    input logic [2:0] state,
    output logic [NUMFLAGS-1:0] flags
);

always_comb begin
    flags = 0;
    case (state)
        T0: begin
            //Increment PC
            flags[PC_INC] = 1;

            //set ABH and ABL to PC
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;

            //Set input b
            flags[SET_DB_TO_DATA] = 1;
            flags[SET_INPUT_B_TO_DB] = 1;

            //set input a
            flags[SET_SB_TO_ACC] = 1;
            flags[SET_INPUT_A_TO_SB] = 1;

            //add ACC+C+DATA
            flags[ALU_OR] = 1;
            flags[LOAD_ALU] = 1;
        
        end
        T1: begin
            //Increment PC
            flags[PC_INC] = 1;

            //set ABH and ABL to PC
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;

            //Move ALU to ACC
            flags[SET_SB_TO_ALU] = 1;
            flags[SET_DB_TO_SB] = 1;
            flags[LOAD_ACC] = 1;

            //Set PSR from ALU Flags
            
            flags[WRITE_ZERO_FLAG] = 1;
            flags[WRITE_NEGATIVE_FLAG] = 1;
        end
        default: flags = 0;
    endcase
end

endmodule

module SBC(
    input logic [2:0] state,
    output logic [NUMFLAGS-1:0] flags
);

always_comb begin
    flags = 0;
    case (state)
        T0: begin
            //Increment PC
            flags[PC_INC] = 1;

            //set ABH and ABL to PC
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;

            //Set input b
            flags[SET_DB_TO_DATA] = 1;
            flags[SET_INPUT_B_TO_NOT_DB] = 1;

            //set carry
            flags[SET_ALU_CARRY_TO_PSR_CARRY] = 1;
            flags[SET_ALU_DEC_TO_PSR_DEC] = 1;

            //set input a
            flags[SET_SB_TO_ACC] = 1;
            flags[SET_INPUT_A_TO_SB] = 1;

            //SUBTRACT ACC+C-DATA
            flags[ALU_ADD] = 1;
            flags[LOAD_ALU] = 1;
            flags[SET_PSR_CARRY_TO_ALU_CARRY] = 1;
            flags[SET_PSR_OVERFLOW_TO_ALU_OVERFLOW] = 1;
        
        end
        T1: begin
            //Increment PC
            flags[PC_INC] = 1;

            //set ABH and ABL to PC
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;

            //Move ALU to ACC
            flags[SET_SB_TO_ALU] = 1;
            flags[SET_DB_TO_SB] = 1;
            flags[LOAD_ACC] = 1;

            //Set PSR from ALU Flags
            
            flags[WRITE_ZERO_FLAG] = 1;
            flags[WRITE_NEGATIVE_FLAG] = 1;

        end
        default: flags = 0;
    endcase
end

endmodule

module LDA(
    input logic [2:0] state,
    output logic [NUMFLAGS-1:0] flags
);

always_comb begin
    flags = 0;
    case (state)
        T0:  begin
            //Increment PC
            flags[PC_INC] = 1;

            //set ABH and ABL to PC
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;

            //Get Data to ACC
            flags[SET_DB_TO_DATA] = 1;
            flags[SET_SB_TO_DB] = 1;
            flags[LOAD_ACC] = 1;

            //Set PSR FLAGS
            flags[WRITE_ZERO_FLAG] = 1;
            flags[WRITE_NEGATIVE_FLAG] = 1;

        end
        T1: begin
            //Increment PC
            flags[PC_INC] = 1;

            //set ABH and ABL to PC
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;
        end
        default: flags = 0;
    endcase
end
endmodule

module LDX(
    input logic [2:0] state,
    output logic [NUMFLAGS-1:0] flags
);

always_comb begin
    flags = 0;
    case (state)
        T0:  begin
            //Increment PC
            flags[PC_INC] = 1;

            //set ABH and ABL to PC
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;

            //Get Data to ACC
            flags[SET_DB_TO_DATA] = 1;
            flags[SET_SB_TO_DB] = 1;
            flags[LOAD_X] = 1;

            //Set PSR FLAGS
            flags[WRITE_ZERO_FLAG] = 1;
            flags[WRITE_NEGATIVE_FLAG] = 1;

        end
        T1: begin
            //Increment PC
            flags[PC_INC] = 1;

            //set ABH and ABL to PC
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;
        end
        default: flags = 0;
    endcase
end
endmodule


module LDY(
    input logic [2:0] state,
    output logic [NUMFLAGS-1:0] flags
);

always_comb begin
    flags = 0;
    case (state)
        T0:  begin
            //Increment PC
            flags[PC_INC] = 1;

            //set ABH and ABL to PC
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;

            //Get Data to ACC
            flags[SET_DB_TO_DATA] = 1;
            flags[SET_SB_TO_DB] = 1;
            flags[LOAD_Y] = 1;

            //Set PSR FLAGS
            flags[WRITE_ZERO_FLAG] = 1;
            flags[WRITE_NEGATIVE_FLAG] = 1;

        end
        T1: begin
            //Increment PC
            flags[PC_INC] = 1;

            //set ABH and ABL to PC
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;
        end
        default: flags = 0;
    endcase
end
endmodule

module ASL(
    input logic [2:0] state,
    output logic [NUMFLAGS-1:0] flags
);

always_comb begin
    flags = 0;
    case (state)
        T0:  begin
            //Set B and A to input data
            flags[SET_DB_TO_DATA] = 1;
            flags[SET_SB_TO_DB] = 1;
            flags[SET_INPUT_A_TO_SB] = 1;
            flags[SET_INPUT_B_TO_DB] = 1;
            
            //Add them together
            flags[ALU_ADD] = 1;
            flags[LOAD_ALU] = 1;
            
            //SET FLAGS
            flags[SET_PSR_CARRY_TO_ALU_CARRY_OUT] = 1;
        end
        T1: begin
            //Move ALU to DOR
            flags[SET_SB_TO_ALU] = 1;
            flags[SET_DB_TO_SB] = 1;
            flags[LOAD_DOR] = 1;

            //Set PSR FLAGS
            flags[WRITE_ZERO_FLAG] = 1;
            flags[WRITE_NEGATIVE_FLAG] = 1;

            //Get ready to write
            flags[SET_WRITE_FLAG] = 1;
        end
        T2: begin
            //write modified data
            flags[SET_WRITE_FLAG] = 1;

            //Increment PC
            flags[PC_INC] = 1;

            //set ABH and ABL to PC
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;
        end
        T3: begin
            //Increment PC
            flags[PC_INC] = 1;

            //set ABH and ABL to PC
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;
        end
        default: flags = 0;
    endcase
end
    
endmodule

module ROL(
    input logic [2:0] state,
    output logic [NUMFLAGS-1:0] flags
);

always_comb begin
    flags = 0;
    case (state)
        T0: begin
            //Set B and A to input data
            flags[SET_DB_TO_DATA] = 1;
            flags[SET_SB_TO_DB] = 1;
            flags[SET_INPUT_A_TO_SB] = 1;
            flags[SET_INPUT_B_TO_DB] = 1;
            flags[SET_ALU_CARRY_TO_PSR_CARRY] = 1;
            
            //Add them together
            flags[ALU_ADD] = 1;
            flags[LOAD_ALU] = 1;
            //SET FLAGS
            flags[SET_PSR_CARRY_TO_ALU_CARRY_OUT] = 1;
        end
        T1: begin
            //Move ALU to DOR
            flags[SET_SB_TO_ALU] = 1;
            flags[SET_DB_TO_SB] = 1;
            flags[LOAD_DOR] = 1;

            //Set PSR FLAGS
            flags[WRITE_ZERO_FLAG] = 1;
            flags[WRITE_NEGATIVE_FLAG] = 1;

            //Get ready to write
            flags[SET_WRITE_FLAG] = 1;
        end
        T2: begin
            //write modified data
            flags[SET_WRITE_FLAG] = 1;

            //Increment PC
            flags[PC_INC] = 1;

            //set ABH and ABL to PC
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;
        end
        T3: begin
            //Increment PC
            flags[PC_INC] = 1;

            //set ABH and ABL to PC
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;
        end
        default: flags = 0;
    endcase
end
    
endmodule

module ROR (
    input logic [2:0] state,
    output logic [NUMFLAGS-1:0] flags
);

always_comb begin
    flags = 0;
    case (state)
        T0: begin
            //Set A to DATA
            flags[SET_DB_TO_DATA] = 1;
            flags[SET_SB_TO_DB] = 1;
            flags[SET_INPUT_A_TO_SB] = 1;
            flags[SET_ALU_CARRY_TO_PSR_CARRY] = 1;
            
            //Rotate
            flags[ALU_R_SHIFT] = 1;
            flags[LOAD_ALU] = 1;
            
            //SET FLAGS
            flags[SET_PSR_CARRY_TO_ALU_CARRY_OUT] = 1;
        end
        T1: begin
            //Move ALU to DOR
            flags[SET_SB_TO_ALU] = 1;
            flags[SET_DB_TO_SB] = 1;
            flags[LOAD_DOR] = 1;

            //Set PSR FLAGS
            flags[WRITE_ZERO_FLAG] = 1;
            flags[WRITE_NEGATIVE_FLAG] = 1;

            //Get ready to write
            flags[SET_WRITE_FLAG] = 1;
        end
        T2: begin
            //write modified data
            flags[SET_WRITE_FLAG] = 1;

            //Increment PC
            flags[PC_INC] = 1;

            //set ABH and ABL to PC
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;
        end
        T3: begin
            //Increment PC
            flags[PC_INC] = 1;

            //set ABH and ABL to PC
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;
        end
        default: flags = 0;
    endcase
end
    
endmodule

module LSR(
    input logic [2:0] state,
    output logic [NUMFLAGS-1:0] flags
);

always_comb begin
    flags = 0;
    case (state)
        T0: begin
            //Set A to DATA
            flags[SET_DB_TO_DATA] = 1;
            flags[SET_SB_TO_DB] = 1;
            flags[SET_INPUT_A_TO_SB] = 1;
            
            //Shift
            flags[ALU_R_SHIFT] = 1;
            flags[LOAD_ALU] = 1;
            
            //SET FLAGS
            flags[SET_PSR_CARRY_TO_ALU_CARRY_OUT] = 1;
        end
        T1: begin
            //Move ALU to DOR
            flags[SET_SB_TO_ALU] = 1;
            flags[SET_DB_TO_SB] = 1;
            flags[LOAD_DOR] = 1;

            //Set PSR FLAGS
            flags[WRITE_ZERO_FLAG] = 1;
            flags[WRITE_NEGATIVE_FLAG] = 1;

            //Get ready to write
            flags[SET_WRITE_FLAG] = 1;
        end
        T2: begin
            //write modified data
            flags[SET_WRITE_FLAG] = 1;

            //Increment PC
            flags[PC_INC] = 1;

            //set ABH and ABL to PC
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;
        end
        T3: begin
            //Increment PC
            flags[PC_INC] = 1;

            //set ABH and ABL to PC
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;
        end
        default: flags = 0;
    endcase
end
    
endmodule

module DEC(
    input logic [2:0] state,
    output logic [NUMFLAGS-1:0] flags
);

always_comb begin
    flags = 0;
    case (state)
        T0: begin
            //Set B and A to be FF and Data
            flags[SET_DB_HIGH] = 1;
            flags[SET_INPUT_A_TO_SB] = 1;
            flags[SET_INPUT_B_TO_DB] = 1;
            
            //What to decrement
            flags[SET_ADH_TO_DATA] = 1;
            flags[SET_SB_TO_ADH] = 1;
            
            //Add them together
            flags[ALU_ADD] = 1;
            flags[LOAD_ALU] = 1;
        end
        T1: begin
            //Move ALU to DOR
            flags[SET_SB_TO_ALU] = 1;
            flags[SET_DB_TO_SB] = 1;
            flags[LOAD_DOR] = 1;

            //Set PSR FLAGS
            flags[WRITE_ZERO_FLAG] = 1;
            flags[WRITE_NEGATIVE_FLAG] = 1;

            //Get ready to write
            flags[SET_WRITE_FLAG] = 1;
        end
        T2: begin
            //write modified data
            flags[SET_WRITE_FLAG] = 1;

            //Increment PC
            flags[PC_INC] = 1;

            //set ABH and ABL to PC
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;
        end
        T3: begin
            //Increment PC
            flags[PC_INC] = 1;

            //set ABH and ABL to PC
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;
        end
        default: flags = 0;
    endcase
end
    
endmodule

module INC(
    input logic [2:0] state,
    output logic [NUMFLAGS-1:0] flags
);

always_comb begin
    flags = 0;
    case (state)
        T0: begin
            //Set C B and A to be 1 Data and 0
            flags[SET_DB_TO_DATA] = 1;
            flags[SET_INPUT_B_TO_DB] = 1;
            flags[SET_ALU_CARRY_HIGH] = 1;
            flags[SET_INPUT_A_TO_LOW] = 1;
            
            //Add them together
            flags[ALU_ADD] = 1;
            flags[LOAD_ALU] = 1;
        end
        T1: begin
            //Move ALU to DOR
            flags[SET_SB_TO_ALU] = 1;
            flags[SET_DB_TO_SB] = 1;
            flags[LOAD_DOR] = 1;

            //Set PSR FLAGS
            flags[WRITE_ZERO_FLAG] = 1;
            flags[WRITE_NEGATIVE_FLAG] = 1;

            //Get ready to write
            flags[SET_WRITE_FLAG] = 1;
        end
        T2: begin
            //write modified data
            flags[SET_WRITE_FLAG] = 1;

            //Increment PC
            flags[PC_INC] = 1;

            //set ABH and ABL to PC
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;
        end
        T3: begin
            //Increment PC
            flags[PC_INC] = 1;

            //set ABH and ABL to PC
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;
        end
        default: flags = 0;
    endcase
end
    
endmodule

module PHP(
    input logic [2:0] state,
    output logic [NUMFLAGS-1:0] flags
);

always_comb begin
    flags = 0;
    case (state)
        T0: begin
            //Decrement PC
            flags[PC_DEC] = 1;

            //Go to Stack
            flags[SET_ADH_TO_ONE] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_SP] = 1;
            flags[LOAD_ABL] = 1;

            //Load PSR to DOR
            flags[SET_DB_TO_PSR] = 1;
            flags[SET_PSR_OUTPUT_BRK_HIGH] = 1;
            flags[LOAD_DOR] = 1;
        end
        T1: begin
            //write modified data
            flags[SET_WRITE_FLAG] = 1;
            
            //Increment PC
            flags[PC_INC] = 1;

            //set ABH and ABL to PC
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;

            //Set input A to SP
            flags[SET_SB_TO_SP] = 1;
            flags[SET_INPUT_A_TO_SB] = 1;

            //Set input B to FF
            flags[SET_DB_HIGH] = 1;
            flags[SET_INPUT_B_TO_DB] = 1;

            //Add SP+FF = SP-1
            flags[ALU_ADD] = 1;
            flags[LOAD_ALU] = 1;
        end
        T2: begin
            //Increment PC
            flags[PC_INC] = 1;

            //set ABH and ABL to PC
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;

            //Set SP to SP-1
            flags[SET_SB_TO_ALU] = 1;
            flags[LOAD_SP] = 1;
        end
        default: flags = 0;
    endcase
end
    
endmodule

module PLP(
    input logic [2:0] state,
    output logic [NUMFLAGS-1:0] flags
);

always_comb begin
    flags = 0;
    case (state)
        T0: begin
            //Decrement PC
            flags[PC_DEC] = 1;

            //Set input B to SP
            flags[SET_SB_TO_SP] = 1;
            flags[SET_DB_TO_SB] = 1;
            flags[SET_INPUT_B_TO_DB] = 1;

            //Set A to 0
            flags[SET_INPUT_A_TO_LOW] = 1;

            //Add 1 to SP
            flags[SET_ALU_CARRY_HIGH] = 1;
            flags[ALU_ADD] = 1;
            flags[LOAD_ALU] = 1;
        end
        T1: begin
            //ALU to SP
            flags[SET_SB_TO_ALU] = 1;
            flags[LOAD_SP] = 1;

            //ALU to ABL
            flags[SET_ADL_TO_ALU] = 1;
            flags[LOAD_ABL] = 1;

            //01 to ADH
            flags[SET_ADH_TO_ONE] = 1;
            flags[LOAD_ABH] = 1;
        end
        T2: begin
            //Increment PC
            flags[PC_INC] = 1;

            //set ABH and ABL to PC
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;

            //Set PSR
            flags[SET_DB_TO_DATA] = 1;
            flags[SET_PSR_TO_DB] = 1;
        end
        T3: begin
            //Increment PC
            flags[PC_INC] = 1;

            //set ABH and ABL to PC
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;
        end
        default: flags = 0;
    endcase
end
    
endmodule

module PHA(
    input logic [2:0] state,
    output logic [NUMFLAGS-1:0] flags
);

always_comb begin
    flags = 0;
    case (state)
        T0: begin
            //Decrement PC
            flags[PC_DEC] = 1;

            //Go to Stack
            flags[SET_ADH_TO_ONE] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_SP] = 1;
            flags[LOAD_ABL] = 1;

            //Load PSR to DOR
            flags[SET_DB_TO_ACC] = 1;
            flags[SET_PSR_OUTPUT_BRK_HIGH] = 1;
            flags[LOAD_DOR] = 1;
        end
        T1: begin
            //write modified data
            flags[SET_WRITE_FLAG] = 1;
            
            //Increment PC
            flags[PC_INC] = 1;

            //set ABH and ABL to PC
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;

            //Set input A to SP
            flags[SET_SB_TO_SP] = 1;
            flags[SET_INPUT_A_TO_SB] = 1;

            //Set input B to FF
            flags[SET_DB_HIGH] = 1;
            flags[SET_INPUT_B_TO_DB] = 1;

            //Add SP+FF = SP-1
            flags[ALU_ADD] = 1;
            flags[LOAD_ALU] = 1;
        end
        T2: begin
            //Increment PC
            flags[PC_INC] = 1;

            //set ABH and ABL to PC
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;

            //Set SP to SP-1
            flags[SET_SB_TO_ALU] = 1;
            flags[LOAD_SP] = 1;
        end
        default: flags = 0;
    endcase
end
    
endmodule

module PLA(
    input logic [2:0] state,
    output logic [NUMFLAGS-1:0] flags
);

always_comb begin
    flags = 0;
    case (state)
        T0: begin
            //Decrement PC
            flags[PC_DEC] = 1;

            //Set input B to SP
            flags[SET_SB_TO_SP] = 1;
            flags[SET_DB_TO_SB] = 1;
            flags[SET_INPUT_B_TO_DB] = 1;

            //Set A to 0
            flags[SET_INPUT_A_TO_LOW] = 1;

            //Add 1 to SP
            flags[SET_ALU_CARRY_HIGH] = 1;
            flags[ALU_ADD] = 1;
            flags[LOAD_ALU] = 1;
        end
        T1: begin
            //ALU to SP
            flags[SET_SB_TO_ALU] = 1;
            flags[LOAD_SP] = 1;

            //ALU to ABL
            flags[SET_ADL_TO_ALU] = 1;
            flags[LOAD_ABL] = 1;

            //01 to ADH
            flags[SET_ADH_TO_ONE] = 1;
            flags[LOAD_ABH] = 1;
        end
        T2: begin
            //Increment PC
            flags[PC_INC] = 1;

            //set ABH and ABL to PC
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;

            //Set ACC
            flags[SET_DB_TO_DATA] = 1;
            flags[SET_SB_TO_DB] = 1;
            flags[LOAD_ACC] = 1;
        end
        T3: begin
            //Increment PC
            flags[PC_INC] = 1;

            //set ABH and ABL to PC
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;
        end
        default: flags = 0;
    endcase
end
    
endmodule

module BRK(
    input logic [2:0] state,
    input logic NMI, IRQ, RESET,
    output logic [NUMFLAGS-1:0] flags
);

always_comb begin
    flags = 0;
    case (state)
        T0: begin
            //Go to Stack
            flags[SET_ADH_TO_ONE] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_SP] = 1;
            flags[LOAD_ABL] = 1;
            
            //Set input A to FF
            flags[SET_SB_HIGH] = 1;
            flags[SET_INPUT_A_TO_SB] = 1;

            //Set input B to SP
            flags[SET_INPUT_B_TO_ADL] = 1;

            //Add SP+FF = SP-1
            flags[ALU_ADD] = 1;
            flags[LOAD_ALU] = 1;

            //Get PCH to DOR
            flags[SET_DB_TO_PCH] = 1;
            flags[LOAD_DOR] = 1;
            
        end
        T1: begin
            //Write DOR
            flags[SET_WRITE_FLAG] = ~RESET;

            //Go to next Stack
            flags[SET_ADL_TO_ALU] = 1;
            flags[LOAD_ABL] = 1;
            
            //Set input A to FF
            flags[SET_SB_HIGH] = 1;
            flags[SET_INPUT_A_TO_SB] = 1;

            //Set input B to SP
            flags[SET_INPUT_B_TO_ADL] = 1;

            //Add SP+FF = SP-1
            flags[ALU_ADD] = 1;
            flags[LOAD_ALU] = 1;

            //Get PCL to DOR
            flags[SET_DB_TO_PCL] = 1;
            flags[LOAD_DOR] = 1;
            
        end
        T2: begin
            //Write DOR
            flags[SET_WRITE_FLAG] = ~RESET;

            //Go to next Stack
            flags[SET_ADL_TO_ALU] = 1;
            flags[LOAD_ABL] = 1;
            
            //Set input A to FF
            flags[SET_SB_HIGH] = 1;
            flags[SET_INPUT_A_TO_SB] = 1;

            //Set input B to SP
            flags[SET_INPUT_B_TO_ADL] = 1;

            //Add SP+FF = SP-1
            flags[ALU_ADD] = 1;
            flags[LOAD_ALU] = 1;

            //Get PSR to DOR
            flags[SET_DB_TO_PSR] = 1;
            flags[SET_PSR_OUTPUT_BRK_HIGH] = ~(NMI|IRQ|RESET);
            flags[LOAD_DOR] = 1;
        end
        T3: begin
            //Write DOR
            flags[SET_WRITE_FLAG] = ~RESET;

            //set ABH and ABL to presets
            flags[SET_ADH_FF] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_FA] = NMI;
            flags[SET_ADL_FC] = RESET;
            flags[SET_ADL_FE] = ~(NMI|RESET);
            flags[LOAD_ABL] = 1;

            //Get ALU ouput to SP Reg
            flags[SET_SB_TO_ALU] = 1;    
            flags[LOAD_SP] = 1;    
        end
        T4: begin
            //set ABH and ABL to presets
            flags[SET_ADH_FF] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_FA] = NMI;
            flags[SET_ADL_FC] = RESET;
            flags[SET_ADL_FE] = ~(NMI|RESET);
            flags[LOAD_ABL] = 1;

            //set B to Data
            flags[SET_DB_TO_DATA] = 1;
            flags[SET_INPUT_B_TO_DB] = 1;

            //add data + 0
            flags[SET_INPUT_A_TO_LOW] = 1;
            flags[ALU_ADD] = 1;
            flags[LOAD_ALU] = 1;
        end
        T5: begin
            //Update ABL
            flags[SET_ADL_TO_ALU] = 1;
            flags[LOAD_ABL] = 1;

            //Update ABH
            flags[SET_ADH_TO_DATA] = 1;
            flags[LOAD_ABH] = 1;

            //Update PC
            flags[LOAD_PC] = 1;
            flags[PC_INC] = 1;
        end
        T6:  begin
            //Increment PC
            flags[PC_INC] = 1;

            //set ABH and ABL to PC
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;
        end
        default: flags = 0;
    endcase
end
    
endmodule

module JSR(
    input logic [2:0] state,
    output logic [NUMFLAGS-1:0] flags
);

always_comb begin
    flags = 0;
    case (state)
        T0: begin
            //Set input B and ABL to SP
            flags[SET_ADL_TO_SP] = 1;
            flags[SET_INPUT_B_TO_ADL] = 1;
            flags[LOAD_ABL] = 1;

            //Add 0 to SP
            flags[SET_INPUT_A_TO_LOW] = 1;
            flags[ALU_ADD] = 1;
            flags[LOAD_ALU] = 1;

            //Get PCH to DOR
            flags[SET_DB_TO_PCH] = 1;
            flags[LOAD_DOR] = 1;

            //Set SP to Data
            flags[SET_ADH_TO_DATA] = 1;
            flags[SET_SB_TO_ADH] = 1;
            flags[LOAD_SP] = 1;
            
        end
        T1: begin
            //ABH to 01
            flags[SET_ADH_TO_ONE] = 1;
            flags[LOAD_ABH] = 1;

            //ALU to Input A
            flags[SET_SB_TO_ALU] = 1;
            flags[SET_INPUT_A_TO_SB] = 1;

            //FF to Input B
            flags[SET_DB_HIGH] = 1;
            flags[SET_INPUT_B_TO_DB] = 1;

            //Add FF to SP
            flags[ALU_ADD] = 1;
            flags[LOAD_ALU] = 1;
        end
        T2: begin
            //Write DOR
            flags[SET_WRITE_FLAG] = 1;

            //Get PCL to DOR
            flags[SET_DB_TO_PCL] = 1;
            flags[LOAD_DOR] = 1;

            //ALU to ABL
            flags[SET_ADL_TO_ALU] = 1;
            flags[LOAD_ABL] = 1;
        end
        T3: begin
            //Write DOR
            flags[SET_WRITE_FLAG] = 1;

            //set ABH and ABL to PC
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;

            //ALU to Input A
            flags[SET_SB_TO_ALU] = 1;
            flags[SET_INPUT_A_TO_SB] = 1;

            //FF to Input B
            flags[SET_DB_HIGH] = 1;
            flags[SET_INPUT_B_TO_DB] = 1;

            //Add FF to SP
            flags[ALU_ADD] = 1;
            flags[LOAD_ALU] = 1;
        end
        T4: begin
            //Update ABL
            flags[SET_ADL_TO_SP] = 1;
            flags[LOAD_ABL] = 1;

            //Update ABH
            flags[SET_ADH_TO_DATA] = 1;
            flags[LOAD_ABH] = 1;

            //Update PC
            flags[LOAD_PC] = 1;
            flags[PC_INC] = 1;

            //Update SP Reg
            flags[SET_SB_TO_ALU] = 1;
            flags[LOAD_SP] = 1;
        end
        T5: begin
            //Increment PC
            flags[PC_INC] = 1;

            //set ABH and ABL to PC
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;
        end
        default: flags = 0;
    endcase
end
    
endmodule

module RTI(
    input logic [2:0] state,
    output logic [NUMFLAGS-1:0] flags
);

always_comb begin
    flags = 0;
    case (state)
        T0: begin
            //Set input B to SP
            flags[SET_SB_TO_SP] = 1;
            flags[SET_DB_TO_SB] = 1;
            flags[SET_INPUT_B_TO_DB] = 1;

            //Set A to 0
            flags[SET_INPUT_A_TO_LOW] = 1;

            //Add 1 to SP
            flags[SET_ALU_CARRY_HIGH] = 1;
            flags[ALU_ADD] = 1;
            flags[LOAD_ALU] = 1;
        end
        T1: begin
            //ALU to SP
            flags[SET_SB_TO_ALU] = 1;
            flags[LOAD_SP] = 1;

            //Set input B to SP
            flags[SET_ADL_TO_SP] = 1;
            flags[SET_INPUT_B_TO_ADL] = 1;

            //Set A to 0
            flags[SET_INPUT_A_TO_LOW] = 1;

            //Add 1 to SP
            flags[SET_ALU_CARRY_HIGH] = 1;
            flags[ALU_ADD] = 1;
            flags[LOAD_ALU] = 1;
        end
        T2: begin
            //ALU to SP
            flags[SET_SB_TO_ALU] = 1;
            flags[LOAD_SP] = 1;
            
            //Set input B to SP
            flags[SET_ADL_TO_SP] = 1;
            flags[SET_INPUT_B_TO_ADL] = 1;

            //Set A to 0
            flags[SET_INPUT_A_TO_LOW] = 1;

            //Add 1 to SP
            flags[SET_ALU_CARRY_HIGH] = 1;
            flags[ALU_ADD] = 1;
            flags[LOAD_ALU] = 1;

            //Set PSR
            flags[SET_DB_TO_DATA] = 1;
            flags[SET_PSR_TO_DB] = 1;
            
        end
        T3: begin
            //ALU to SP
            flags[SET_SB_TO_ALU] = 1;
            flags[LOAD_SP] = 1;
            
            //Set input B to Data
            flags[SET_DB_TO_DATA] = 1;
            flags[SET_INPUT_B_TO_DB] = 1;//goofy forgot what was happening here

            //Set A to 0
            flags[SET_INPUT_A_TO_LOW] = 1;

            //Save Data in ALU
            flags[ALU_ADD] = 1;
            flags[LOAD_ALU] = 1;
        end
        T4: begin
            //Update ABL
            flags[SET_ADL_TO_ALU] = 1;
            flags[LOAD_ABL] = 1;

            //Update ABH
            flags[SET_ADH_TO_DATA] = 1;
            flags[LOAD_ABH] = 1;

            //Update PC
            flags[LOAD_PC] = 1;
            flags[PC_INC] = 1;
        end
        T5: begin
            //Increment PC
            flags[PC_INC] = 1;

            //set ABH and ABL to PC
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;
        end
        default: flags = 0;
    endcase
end
    
endmodule

module JMP(
    input logic [2:0] state,
    output logic [NUMFLAGS-1:0] flags
);

always_comb begin
    flags = 0;
    case (state)
        T0: begin
            //Update ABL
            flags[SET_ADL_TO_ALU] = 1;
            flags[LOAD_ABL] = 1;

            //Update ABH
            flags[SET_ADH_TO_DATA] = 1;
            flags[LOAD_ABH] = 1;

            //Update PC
            flags[LOAD_PC] = 1;
            flags[PC_INC] = 1;
        end
        T1: begin
            //Increment PC
            flags[PC_INC] = 1;

            //set ABH and ABL to PC
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;
        end
        default: flags = 0;
    endcase
end
    
endmodule

module BCC(
    input logic [2:0] state,
    input logic breek,
    input logic carry_to_high_op,
    output logic [NUMFLAGS-1:0] flags,
    output logic carry_from_low_op
);

always_comb begin
    flags = 0;
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
            //ALU to SP
            flags[SET_SB_TO_ALU] = 1;
            flags[LOAD_SP] = 1;

            //Set input B to SP
            flags[SET_ADL_TO_SP] = 1;
            flags[SET_INPUT_B_TO_ADL] = 1;

            //Set A to 0
            flags[SET_INPUT_A_TO_LOW] = 1;

            //Add 1 to SP
            flags[SET_ALU_CARRY_HIGH] = 1;
            flags[ALU_ADD] = 1;
            flags[LOAD_ALU] = 1;
        end
        T2: begin
            //ALU to SP
            flags[SET_SB_TO_ALU] = 1;
            flags[LOAD_SP] = 1;
            
            //Set input B to SP
            flags[SET_ADL_TO_SP] = 1;
            flags[SET_INPUT_B_TO_ADL] = 1;

            //Set A to 0
            flags[SET_INPUT_A_TO_LOW] = 1;

            //Add 1 to SP
            flags[SET_ALU_CARRY_HIGH] = 1;
            flags[ALU_ADD] = 1;
            flags[LOAD_ALU] = 1;
        end
        T3: begin
            //Increment PC
            flags[PC_INC] = 1;

            //set ABH and ABL to PC
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;
        end
        default: flags = 0;
    endcase
end
    
endmodule