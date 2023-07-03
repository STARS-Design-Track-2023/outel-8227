// parameter NUMFLAGS = 40;
// parameter SET_ADH_LOW = 0;
// parameter SET_ADL_TO_DATA = 1;
// parameter LOAD_ABL = 2;
// parameter LOAD_ABH = 3;
// parameter PC_INC = 4;
// parameter PC_DEC = 5;
// parameter SET_ADL_TO_PCL = 6;
// parameter SET_ADH_TO_PCH = 7;
// parameter SET_DB_TO_DATA = 8;
// parameter SET_INPUT_B_TO_DB = 9;
// parameter SET_SB_TO_DB = 10;
// parameter SET_ADL_TO_ALU = 11;
// parameter SET_ADH_TO_SB = 12;
// parameter SET_INPUT_A_TO_SB = 13;
// parameter SET_SB_TO_X = 14;
// parameter SET_SB_TO_Y = 15;
// parameter SET_SB_TO_ACC = 16;
// parameter SET_SB_TO_ALU = 17;
// parameter ALU_ADD = 18;


// parameter A0 = 4'b000;
// parameter A1 = 4'b001;
// parameter A2 = 4'b010;
// parameter A3 = 4'b011;
// parameter A4 = 4'b100;
// parameter A5 = 4'b101;

// module Imediate
// (
//     input logic [4:0] state,
//     input logic [7:0] opCode,
//     output logic [NUMFLAGS:0] flags
// );
// endmodule

// module Implied
// (
//     input logic [4:0] state,
//     input logic [7:0] opCode,
//     output logic [NUMFLAGS:0] flags
// );
// endmodule

// module ZPG
// (
//     input logic [3:0] state,
//     input logic [7:0] opCode,
//     output logic [NUMFLAGS:0] flags
// );

// always_comb begin
//     if(state == A0)begin
//         //go to zero page
//         flags[SET_ADH_LOW] = 1;
//         flags[SET_ADL_TO_DATA] = 1;
//         flags[LOAD_ABH] = 1;
//         flags[LOAD_ABL] = 1;
//     end else begin
//         flags = 0;
//     end
// end
// endmodule

// module Absolute(
//     input logic [3:0] state,
//     input logic [7:0] opCode,
//     output logic [NUMFLAGS:0] flags
// );

// always_comb begin
//     if(state == A0)begin
//         //update address 
//         flags[PC_INC] = 1;
//         flags[SET_ADL_TO_PCL] = 1;
//         flags[LOAD_ABL] = 1;
//         flags[SET_ADH_TO_PCH] = 1;
//         flags[LOAD_ABH] = 1;
//         //save lower address to ALU
//         flags[SET_DB_TO_DATA] = 1;
//         flags[SET_INPUT_B_TO_DB] = 1;
//     end else if(state == A1)begin
//         //set low address
//         flags[LOAD_ABL] = 1;
//         flags[SET_ADL_TO_ALU] = 1;
//         //set high address
//         flags[SET_DB_TO_DATA] = 1;
//         flags[SET_SB_TO_DB] = 1;
//         flags[SET_ADH_TO_SB] = 1;
//         flags[LOAD_ABH] = 1;
//     end else 
//         flags = 0;
// end
// endmodule

// module Absolute_X(
//     input logic [3:0] state,
//     input logic [7:0] opCode,
//     output logic [NUMFLAGS:0] flags
// );

// always_comb begin
//     if(state == A0)begin
//         //Increment position
//         flags[PC_INC] = 1;
//         flags[LOAD_ABH] = 1;
//         flags[LOAD_ABL] = 1;
//         flags[SET_ADH_TO_PCH] = 1;
//         flags[SET_ADL_TO_PCL] = 1;
//         //Add data to X
//         flags[ALU_ADD] = 1;
//         flags[SET_DB_TO_DATA] = 1;
//         flags[SET_INPUT_B_TO_DB] = 1;
//         flags[SET_SB_TO_X] = 1;
//         flags[SET_INPUT_A_TO_SB] = 1;
//     end else if(state == A1)begin
//         //Increment position
//         flags[SET_ADH_TO_PCH] = 1;
//         flags[SET_ADL_TO_PCL] = 1;
//         //Move ALU output to ABL
//         flags[SET_ADL_TO_ALU] = 1;
//         flags[LOAD_ABL] = 1;
//         //Add data to X
//         flags[ALU_ADD] = 1;
//         flags[SET_DB_TO_DATA] = 1;
//         flags[SET_INPUT_B_TO_DB] = 1;
//         flags[SET_SB_TO_X] = 1;
//         flags[SET_INPUT_A_TO_SB] = 1;
//     end else if(state == A2)begin
//         //Move ALU output to ADL
//         flags[SET_SB_TO_ALU] = 1;
//         flags[SET_ADH_TO_SB] = 1;
//         flags[LOAD_ABH] = 1;
//     end else begin
//         flags = 0;
//     end
// end
// endmodule

// module Absolute_Y(
//     input logic [3:0] state,
//     input logic [7:0] opCode,
//     output logic [NUMFLAGS:0] flags
// );

// always_comb begin
//     if(state == A0)begin
//         //Increment position
//         flags[PC_INC] = 1;
//         flags[LOAD_ABH] = 1;
//         flags[LOAD_ABL] = 1;
//         flags[SET_ADH_TO_PCH] = 1;
//         flags[SET_ADL_TO_PCL] = 1;
//         //Add data to X
//         flags[ALU_ADD] = 1;
//         flags[SET_DB_TO_DATA] = 1;
//         flags[SET_INPUT_B_TO_DB] = 1;
//         flags[SET_SB_TO_Y] = 1;
//         flags[SET_INPUT_A_TO_SB] = 1;
//     end else if(state == A1)begin
//         //Increment position
//         flags[SET_ADH_TO_PCH] = 1;
//         flags[SET_ADL_TO_PCL] = 1;
//         //Move ALU output to ABL
//         flags[SET_ADL_TO_ALU] = 1;
//         flags[LOAD_ABL] = 1;
//         //Add data to Y
//         flags[ALU_ADD] = 1;
//         flags[SET_DB_TO_DATA] = 1;
//         flags[SET_INPUT_B_TO_DB] = 1;
//         flags[SET_SB_TO_Y] = 1;
//         flags[SET_INPUT_A_TO_SB] = 1;
//     end else if(state == A2)begin
//         //Move ALU output to ADL
//         flags[SET_SB_TO_ALU] = 1;
//         flags[SET_ADH_TO_SB] = 1;
//         flags[LOAD_ABH] = 1;
//     end else begin
//         flags = 0;
//     end
// end
// endmodule

// module ZPG_X
// (
//     input logic [3:0] state,
//     input logic [7:0] opCode,
//     output logic [NUMFLAGS:0] flags
// );

// always_comb begin
//     if(state == A0)begin
//         //Add data to X
//         flags[ALU_ADD] = 1;
//         flags[SET_DB_TO_DATA] = 1;
//         flags[SET_INPUT_B_TO_DB] = 1;
//         flags[SET_SB_TO_X] = 1;
//         flags[SET_INPUT_A_TO_SB] = 1;
//     end else if(state == A1)begin
//         //Set Zero Page
//         flags[SET_ADH_LOW] = 1;
//         flags[SET_ADL_TO_ALU] = 1;
//         flags[LOAD_ABH] = 1;
//         flags[LOAD_ABL] = 1;
//     end else begin
//         flags = 0;
//     end
// end
// endmodule

// module ZPG_Y
// (
//     input logic [3:0] state,
//     input logic [7:0] opCode,
//     output logic [NUMFLAGS:0] flags
// );

// always_comb begin
//     if(state == A0)begin
//         //Add data to Y
//         flags[ALU_ADD] = 1;
//         flags[SET_DB_TO_DATA] = 1;
//         flags[SET_INPUT_B_TO_DB] = 1;
//         flags[SET_SB_TO_Y] = 1;
//         flags[SET_INPUT_A_TO_SB] = 1;
//     end else if(state == A1)begin
//         //Set Zero Page
//         flags[SET_ADH_LOW] = 1;
//         flags[SET_ADL_TO_ALU] = 1;
//         flags[LOAD_ABH] = 1;
//         flags[LOAD_ABL] = 1;
//     end else begin
//         flags = 0;
//     end
// end
// endmodule

// module Indrect_X(
//     input logic [3:0] state,
//     input logic [7:0] opCode,
//     output logic [NUMFLAGS:0] flags
// );

// always_comb begin
//     if(state == A0)begin
//         //Increment position
//         flags[PC_INC] = 1;
//         flags[LOAD_ABH] = 1;
//         flags[LOAD_ABL] = 1;
//         flags[SET_ADH_TO_PCH] = 1;
//         flags[SET_ADL_TO_PCL] = 1;
//         //Add data to X
//         flags[ALU_ADD] = 1;
//         flags[SET_DB_TO_DATA] = 1;
//         flags[SET_INPUT_B_TO_DB] = 1;
//         flags[SET_SB_TO_X] = 1;
//         flags[SET_INPUT_A_TO_SB] = 1;
//     end else if(state == A1)begin
//         //Increment position
//         flags[SET_ADH_TO_PCH] = 1;
//         flags[SET_ADL_TO_PCL] = 1;
//         //Move ALU output to ABL
//         flags[SET_ADL_TO_ALU] = 1;
//         flags[LOAD_ABL] = 1;
//         //Add data to X
//         flags[ALU_ADD] = 1;
//         flags[SET_DB_TO_DATA] = 1;
//         flags[SET_INPUT_B_TO_DB] = 1;
//         flags[SET_SB_TO_X] = 1;
//         flags[SET_INPUT_A_TO_SB] = 1;
//     end else if(state == A2)begin
//         //Move ALU output to ADL
//         flags[SET_SB_TO_ALU] = 1;
//         flags[SET_ADH_TO_SB] = 1;
//         flags[LOAD_ABH] = 1;
//     end else begin
//         flags = 0;
//     end
// end
// endmodule






