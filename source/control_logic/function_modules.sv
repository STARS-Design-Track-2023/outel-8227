`include "param_file.sv"

/*
* Finished Modules:
* 1. Single byte instructions: ALL, BUT THE FLAGS ARE NOT DONE!!!!!!!!!!!!!!!!!!!!!!!!
* 2. Internal Execution on Memory Data: ALL
* 3. Store Operations: ALL
* 4. Read Modify Write: none
* 5. Misc.: none
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
            flags[SET_SB_TO_X] = 1;
            flags[SET_INPUT_A_TO_SB] = 1;
            flags[SET_INPUT_B_TO_DB] = 1;
            
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
            flags[SET_SB_TO_Y] = 1;
            flags[SET_INPUT_A_TO_SB] = 1;
            flags[SET_INPUT_B_TO_DB] = 1;
            
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


///////////////////////////////////////NOT DONE\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
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

            //Subtract ACC-M
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