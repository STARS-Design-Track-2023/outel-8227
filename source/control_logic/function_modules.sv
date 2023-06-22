`include "param_file.sv"

module ASL_A(
    input logic [2:0] state,
    output logic [NUMFLAGS-1:0] flags
);

always_comb begin
    flags = 0;
    case (state)
        3'b000:  begin
            //Set B and A to input data
            flags[SET_DB_TO_ACC] = 1;
            flags[SET_SB_TO_ACC] = 1;
            flags[SET_INPUT_A_TO_SB] = 1;
            flags[SET_INPUT_B_TO_DB] = 1;
            
            //Add them together
            flags[ALU_ADD] = 1;
            flags[LOAD_ALU] = 1;
        end
        3'b001: begin
            //Increment PC and set ABH and ABL to PC
            flags[PC_INC] = 1;
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;
            //Move ALU to ACC
            flags[SET_SB_TO_ALU] = 1;
            flags[SET_ACC_TO_SB] = 1;
        end  
        default: flags = 0;
    endcase
end
    
endmodule

module ROL_A(
    input logic carry_flag,
    input logic [2:0] state,
    output logic [NUMFLAGS-1:0] flags
);

always_comb begin
    flags = 0;
    case (state)
        3'b000: begin
            //Set B and A to input data
            flags[SET_DB_TO_ACC] = 1;
            flags[SET_SB_TO_ACC] = 1;
            flags[SET_INPUT_A_TO_SB] = 1;
            flags[SET_INPUT_B_TO_DB] = 1;
            flags[SET_ALU_CARRY_HIGH] = carry_flag;
            
            //Add them together
            flags[ALU_ADD] = 1;
            flags[LOAD_ALU] = 1;
        end
        3'b001: begin
            //Increment PC and set ABH and ABL to PC
            flags[PC_INC] = 1;
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;
            //Move ALU to ACC
            flags[SET_SB_TO_ALU] = 1;
            flags[SET_ACC_TO_SB] = 1;
        end  
        default: flags = 0;
    endcase
end
    
endmodule

module ROR_A(
    input logic carry_flag,
    input logic [2:0] state,
    output logic [NUMFLAGS-1:0] flags
);

always_comb begin
    flags = 0;
    case (state)
        3'b000: begin
            //Set A to ACC
            flags[SET_SB_TO_ACC] = 1;
            flags[SET_INPUT_A_TO_SB] = 1;
            flags[SET_ALU_CARRY_HIGH] = carry_flag;
            
            //Rotate
            flags[ALU_ROT] = 1;
            flags[LOAD_ALU] = 1;
        end
        3'b001: begin
            //Increment PC and set ABH and ABL to PC
            flags[PC_INC] = 1;
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;
            //Move ALU to ACC
            flags[SET_SB_TO_ALU] = 1;
            flags[SET_ACC_TO_SB] = 1;
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
        3'b000: begin
            //Set A to ACC
            flags[SET_SB_TO_ACC] = 1;
            flags[SET_INPUT_A_TO_SB] = 1;
            
            //Shift
            flags[ALU_ROT] = 1;
            flags[LOAD_ALU] = 1;
        end
        3'b001: begin
            //Increment PC and set ABH and ABL to PC
            flags[PC_INC] = 1;
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;
            //Move ALU to ACC
            flags[SET_SB_TO_ALU] = 1;
            flags[SET_ACC_TO_SB] = 1;
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
        3'b000: begin
            //Set B and A to be FF and Y
            flags[SET_DB_HIGH] = 1;
            flags[SET_SB_TO_X] = 1;
            flags[SET_INPUT_A_TO_SB] = 1;
            flags[SET_INPUT_B_TO_DB] = 1;
            
            //Add them together
            flags[ALU_ADD] = 1;
            flags[LOAD_ALU] = 1;
        end
        3'b001: begin
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
        3'b000: begin
            //Set B and A to be FF and Y
            flags[SET_DB_HIGH] = 1;
            flags[SET_SB_TO_Y] = 1;
            flags[SET_INPUT_A_TO_SB] = 1;
            flags[SET_INPUT_B_TO_DB] = 1;
            
            //Add them together
            flags[ALU_ADD] = 1;
            flags[LOAD_ALU] = 1;
        end
        3'b001: begin
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
        3'b000: begin
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
        3'b001: begin
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
        3'b000: begin
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
        3'b001: begin
            //Increment PC and set ABH and ABL to PC
            flags[PC_INC] = 1;
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;
            //Move ALU to ACC
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
        3'b000: begin
            
        end
        3'b001: begin
            //Increment PC and set ABH and ABL to PC
            flags[PC_INC] = 1;
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;
            //Move ALU to ACC
            flags[SET_SB_TO_ALU] = 1;
            flags[LOAD_X] = 1;
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
        3'b000: begin
            //Set signal on the stack bus
            flags[SET_SB_TO_ACC] = 1;
            
            //update registar
            flags[LOAD_X] = 1;
        end
        3'b001: begin
            //Increment PC and set ABH and ABL to PC
            flags[PC_INC] = 1;
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;
            //Move ALU to ACC
            flags[SET_SB_TO_ALU] = 1;
            flags[LOAD_X] = 1;
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
        3'b000: begin
            //Set signal on the stack bus
            flags[SET_SB_TO_ACC] = 1;
            
            //update registar
            flags[LOAD_Y] = 1;
        end
        3'b001: begin
            //Increment PC and set ABH and ABL to PC
            flags[PC_INC] = 1;
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;
            //Move ALU to ACC
            flags[SET_SB_TO_ALU] = 1;
            flags[LOAD_X] = 1;
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
        3'b000: begin
            //Set signal on the stack bus
            flags[SET_SB_TO_SP] = 1;
            
            //update registar
            flags[LOAD_X] = 1;
        end
        3'b001: begin
            //Increment PC and set ABH and ABL to PC
            flags[PC_INC] = 1;
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;
            //Move ALU to ACC
            flags[SET_SB_TO_ALU] = 1;
            flags[LOAD_X] = 1;
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
        3'b000: begin
            //Set signal on the stack bus
            flags[SET_SB_TO_X] = 1;
            
            //update registar
            flags[LOAD_ACC] = 1;
        end
        3'b001: begin
            //Increment PC and set ABH and ABL to PC
            flags[PC_INC] = 1;
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;
            //Move ALU to ACC
            flags[SET_SB_TO_ALU] = 1;
            flags[LOAD_X] = 1;
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
        3'b000: begin
            //Set signal on the stack bus
            flags[SET_SB_TO_SP] = 1;
            
            //update registar
            flags[LOAD_X] = 1;
        end
        3'b001: begin
            //Increment PC and set ABH and ABL to PC
            flags[PC_INC] = 1;
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;
            //Move ALU to ACC
            flags[SET_SB_TO_ALU] = 1;
            flags[LOAD_X] = 1;
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
        3'b000: begin
            //Set signal on the stack bus
            flags[SET_SB_TO_X] = 1;
            
            //update registar
            flags[LOAD_SP] = 1;
        end
        3'b001: begin
            //Increment PC and set ABH and ABL to PC
            flags[PC_INC] = 1;
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;
            //Move ALU to ACC
            flags[SET_SB_TO_ALU] = 1;
            flags[LOAD_X] = 1;
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
        3'b000: begin
            //Set signal on the stack bus
            flags[SET_SB_TO_Y] = 1;
            
            //update registar
            flags[LOAD_ACC] = 1;
        end
        3'b001: begin
            //Increment PC and set ABH and ABL to PC
            flags[PC_INC] = 1;
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;
            //Move ALU to ACC
            flags[SET_SB_TO_ALU] = 1;
            flags[LOAD_X] = 1;
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
        3'b000: begin
            //Set FLAG
            flags[PSR_DATA_TO_LOAD] = 1;
            flags[LOAD_CARRY_PSR_FLAG] = 1;
        
        end
        3'b001: begin
            //Increment PC and set ABH and ABL to PC
            flags[PC_INC] = 1;
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;
            //Move ALU to ACC
            flags[SET_SB_TO_ALU] = 1;
            flags[LOAD_X] = 1;
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
        3'b000: begin
            //Set FLAG
            flags[PSR_DATA_TO_LOAD] = 1;
            flags[LOAD_DECIMAL_PSR_FLAG] = 1;
        
        end
        3'b001: begin
            //Increment PC and set ABH and ABL to PC
            flags[PC_INC] = 1;
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;
            //Move ALU to ACC
            flags[SET_SB_TO_ALU] = 1;
            flags[LOAD_X] = 1;
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
        3'b000: begin
            //Set FLAG
            flags[PSR_DATA_TO_LOAD] = 1;
            flags[LOAD_INTERUPT_PSR_FLAG] = 1;
        
        end
        3'b001: begin
            //Increment PC and set ABH and ABL to PC
            flags[PC_INC] = 1;
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;
            //Move ALU to ACC
            flags[SET_SB_TO_ALU] = 1;
            flags[LOAD_X] = 1;
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
        3'b000: begin
            //Set FLAG
            flags[PSR_DATA_TO_LOAD] = 1;
            flags[LOAD_CARRY_PSR_FLAG] = 0;
        
        end
        3'b001: begin
            //Increment PC and set ABH and ABL to PC
            flags[PC_INC] = 1;
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;
            //Move ALU to ACC
            flags[SET_SB_TO_ALU] = 1;
            flags[LOAD_X] = 1;
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
        3'b000: begin
            //Set FLAG
            flags[PSR_DATA_TO_LOAD] = 1;
            flags[LOAD_DECIMAL_PSR_FLAG] = 0;
        
        end
        3'b001: begin
            //Increment PC and set ABH and ABL to PC
            flags[PC_INC] = 1;
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;
            //Move ALU to ACC
            flags[SET_SB_TO_ALU] = 1;
            flags[LOAD_X] = 1;
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
        3'b000: begin
            //Set FLAG
            flags[PSR_DATA_TO_LOAD] = 1;
            flags[LOAD_INTERUPT_PSR_FLAG] = 0;
        
        end
        3'b001: begin
            //Increment PC and set ABH and ABL to PC
            flags[PC_INC] = 1;
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;
            //Move ALU to ACC
            flags[SET_SB_TO_ALU] = 1;
            flags[LOAD_X] = 1;
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
        3'b000: begin
            //Set FLAG
            flags[PSR_DATA_TO_LOAD] = 1;
            flags[LOAD_OVERFLOW_PSR_FLAG] = 0;
        
        end
        3'b001: begin
            //Increment PC and set ABH and ABL to PC
            flags[PC_INC] = 1;
            flags[SET_ADH_TO_PCH] = 1;
            flags[LOAD_ABH] = 1;
            flags[SET_ADL_TO_PCL] = 1;
            flags[LOAD_ABL] = 1;
            //Move ALU to ACC
            flags[SET_SB_TO_ALU] = 1;
            flags[LOAD_X] = 1;
        end  
        default: flags = 0;
    endcase
end

endmodule