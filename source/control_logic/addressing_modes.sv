`include "param_file.sv"

module Imediate
(
    input logic [4:0] state,
    input logic [7:0] opCode,
    output logic [NUMFLAGS:0] flags
);
assign flags = 0;
endmodule

module Implied
(
    input logic [4:0] state,
    input logic [7:0] opCode,
    output logic [NUMFLAGS:0] flags
);
assign flags = 0;
endmodule

module ZPG
(
    input logic [3:0] state,
    input logic [7:0] opCode,
    output logic [NUMFLAGS:0] flags
);

always_comb begin
    if(state == A0)begin
        //go to zero page
        flags[SET_ADH_LOW] = 1;
        flags[SET_ADL_TO_DATA] = 1;
        flags[LOAD_ABH] = 1;
        flags[LOAD_ABL] = 1;
    end else begin
        flags = 0;
    end
end
endmodule

module Absolute(
    input logic [3:0] state,
    input logic [7:0] opCode,
    output logic [NUMFLAGS:0] flags
);

always_comb begin
    if(state == A0)begin
        //update address 
        flags[PC_INC] = 1;
        flags[SET_ADL_TO_PCL] = 1;
        flags[LOAD_ABL] = 1;
        flags[SET_ADH_TO_PCH] = 1;
        flags[LOAD_ABH] = 1;
        //save lower address to ALU
        flags[SET_DB_TO_DATA] = 1;
        flags[SET_INPUT_B_TO_DB] = 1;
    end else if(state == A1)begin
        //set low address
        flags[LOAD_ABL] = 1;
        flags[SET_ADL_TO_ALU] = 1;
        //set high address
        flags[SET_DB_TO_DATA] = 1;
        flags[SET_SB_TO_DB] = 1;
        flags[SET_ADH_TO_SB] = 1;
        flags[LOAD_ABH] = 1;
    end else 
        flags = 0;
end
endmodule

module Absolute_X(
    input logic [3:0] state,
    input logic [7:0] opCode,
    output logic [NUMFLAGS:0] flags
);

always_comb begin
    if(state == A0)begin
        //Increment position
        flags[PC_INC] = 1;
        flags[LOAD_ABH] = 1;
        flags[LOAD_ABL] = 1;
        flags[SET_ADH_TO_PCH] = 1;
        flags[SET_ADL_TO_PCL] = 1;
        //Add data to X
        flags[LOAD_ALU] = 1;
        flags[ALU_ADD] = 1;
        flags[SET_DB_TO_DATA] = 1;
        flags[SET_INPUT_B_TO_DB] = 1;
        flags[SET_SB_TO_X] = 1;
        flags[SET_INPUT_A_TO_SB] = 1;
    end else if(state == A1)begin
        //Move ALU output to ABL
        flags[SET_ADL_TO_ALU] = 1;
        flags[LOAD_ABL] = 1;
        //Add data to X
        flags[LOAD_ALU] = 1;
        flags[ALU_ADD] = 1;
        flags[SET_DB_TO_DATA] = 1;
        flags[SET_INPUT_B_TO_DB] = 1;
        flags[SET_SB_TO_X] = 1;
        flags[SET_INPUT_A_TO_SB] = 1;
    end else if(state == A2)begin
        //Move ALU output to ADL
        flags[SET_SB_TO_ALU] = 1;
        flags[SET_ADH_TO_SB] = 1;
        flags[LOAD_ABH] = 1;
    end else begin
        flags = 0;
    end
end
endmodule

module Absolute_Y(
    input logic [3:0] state,
    input logic [7:0] opCode,
    output logic [NUMFLAGS:0] flags
);

always_comb begin
    if(state == A0)begin
        //Increment position
        flags[PC_INC] = 1;
        flags[LOAD_ABH] = 1;
        flags[LOAD_ABL] = 1;
        flags[SET_ADH_TO_PCH] = 1;
        flags[SET_ADL_TO_PCL] = 1;
        //Add data to X
        flags[LOAD_ALU] = 1;
        flags[ALU_ADD] = 1;
        flags[SET_DB_TO_DATA] = 1;
        flags[SET_INPUT_B_TO_DB] = 1;
        flags[SET_SB_TO_Y] = 1;
        flags[SET_INPUT_A_TO_SB] = 1;
    end else if(state == A1)begin
        //Move ALU output to ABL
        flags[SET_ADL_TO_ALU] = 1;
        flags[LOAD_ABL] = 1;
        //Add data to Y
        flags[LOAD_ALU] = 1;
        flags[ALU_ADD] = 1;
        flags[SET_DB_TO_DATA] = 1;
        flags[SET_INPUT_B_TO_DB] = 1;
        flags[SET_SB_TO_Y] = 1;
        flags[SET_INPUT_A_TO_SB] = 1;
    end else if(state == A2)begin
        //Move ALU output to ADL
        flags[SET_SB_TO_ALU] = 1;
        flags[SET_ADH_TO_SB] = 1;
        flags[LOAD_ABH] = 1;
    end else begin
        flags = 0;
    end
end
endmodule

module ZPG_X
(
    input logic [3:0] state,
    input logic [7:0] opCode,
    output logic [NUMFLAGS:0] flags
);

always_comb begin
    if(state == A0)begin
        //Add data to X
        flags[LOAD_ALU] = 1;
        flags[ALU_ADD] = 1;
        flags[SET_DB_TO_DATA] = 1;
        flags[SET_INPUT_B_TO_DB] = 1;
        flags[SET_SB_TO_X] = 1;
        flags[SET_INPUT_A_TO_SB] = 1;
    end else if(state == A1)begin
        //Set Zero Page
        flags[SET_ADH_LOW] = 1;
        flags[LOAD_ABH] = 1;
        flags[SET_ADL_TO_ALU] = 1;
        flags[LOAD_ABL] = 1;
    end else begin
        flags = 0;
    end
end
endmodule

module ZPG_Y
(
    input logic [3:0] state,
    input logic [7:0] opCode,
    output logic [NUMFLAGS:0] flags
);

always_comb begin
    if(state == A0)begin
        //Add data to Y
        flags[LOAD_ALU] = 1;
        flags[ALU_ADD] = 1;
        flags[SET_DB_TO_DATA] = 1;
        flags[SET_INPUT_B_TO_DB] = 1;
        flags[SET_SB_TO_Y] = 1;
        flags[SET_INPUT_A_TO_SB] = 1;
    end else if(state == A1)begin
        //Set Zero Page
        flags[SET_ADH_LOW] = 1;
        flags[LOAD_ABH] = 1;
        flags[SET_ADL_TO_ALU] = 1;
        flags[LOAD_ABL] = 1;
    end else begin
        flags = 0;
    end
end
endmodule

module Indrect_X(
    input logic [3:0] state,
    input logic [7:0] opCode,
    output logic [NUMFLAGS:0] flags
);

always_comb begin
    if(state == A0)begin
        //Increment PC
        flags[PC_INC] = 1;
        //Add data to X
        flags[LOAD_ALU] = 1;
        flags[ALU_ADD] = 1;
        flags[SET_DB_TO_DATA] = 1;
        flags[SET_INPUT_B_TO_DB] = 1;
        flags[SET_SB_TO_X] = 1;
        flags[SET_INPUT_A_TO_SB] = 1;
    end else if(state == A1)begin
        //Set Zero Page
        flags[SET_ADH_LOW] = 1;
        flags[LOAD_ABH] = 1;
        flags[SET_ADL_TO_ALU] = 1;
        flags[LOAD_ABL] = 1;
        //Increment position through ALU
          //bring ALU output to B
        flags[SET_SB_TO_ALU] = 1;
        flags[SET_DB_TO_SB] = 1;
        flags[SET_INPUT_B_TO_DB] = 1;
          //Add B to 1
        flags[SET_INPUT_A_TO_LOW] = 1;
        flags[SET_ALU_CARRY_HIGH] = 1;
        flags[ALU_ADD] = 1;
        flags[LOAD_ALU] = 1;
    end else if(state == A2)begin
        //Set Zero Page
        flags[SET_ADH_LOW] = 1;
        flags[LOAD_ABH] = 1;
        flags[SET_ADL_TO_ALU] = 1;
        flags[LOAD_ABL] = 1;
        //Store data in ALU
        flags[SET_DB_TO_DATA] = 1;
        flags[SET_INPUT_B_TO_DB] = 1;
        flags[SET_INPUT_A_TO_LOW] = 1;
        flags[LOAD_ALU] = 1;
        flags[ALU_ADD] = 1;
    end else if(state == A3)begin
        //Load read data values
        flags[SET_ADH_TO_DATA] = 1;
        flags[LOAD_ABH] = 1;
        flags[SET_ADL_TO_ALU] = 1;
        flags[LOAD_ABL] = 1;
    end else begin
        flags = 0;
    end
end
endmodule