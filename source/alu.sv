module ALU(
    input logic [7:0] DB_input, ADL_input, SB_input,    //input data
    input logic ldb_inv_db,                             //input data bus not on b
    input logic ldb_db,                                 //input data bus on b
    input logic ldb_adl,                                //input adl on b
    input logic lda_sb,                                 //input sb on a
    input logic lda_zero,                               //input zeroes on a
    input logic enable_dec,                             //enable bcd mode
    input logic carry_in,                               //carry in input
    input logic e_sum,                                  //output a+b
    input logic e_and,                                  //output a&b
    input logic e_eor,                                  //output a^b
    input logic e_or,                                   //output a|b
    input logic e_shiftr,                               //output a >>
    output logic carry_out,                             //carry out of alu
    output logic overflow,                              //overflow from alu
    output logic [7:0] alu_out                          //output bus going to alu register
);

    logic [7:0] a, b;
    always_comb begin //comb to determine inputs
        if(ldb_inv_db) b = ~DB_input;
        if(ldb_db) b = DB_input;
        if(ldb_adl) b = ADL_input;

        if(lda_sb) a = SB_input;
        if(lda_zero) a = 8'b00000000;
    end
                                    
    logic [8:0] sum;
    logic [7:0] rot_buffer;                                    
    always_comb begin                                   //NOTE: ALU is only directly responsible for outputting carry and overflow 
        alu_out = 0;                                    //default to 0
        carry_out = 0;
        overflow = 0;

        if(e_sum) begin                                 //handle addition with carry and overflow
            sum = a + b + {7'b0000000, carry_in};
            alu_out = sum[7:0];
            carry_out = sum[8];
            if(sum[8] ^ sum[7]) overflow = 1;
        end
        if(e_and) begin                                 //other ops are simple
            alu_out = a & b;
        end
        if(e_eor) begin
            alu_out = a ^ b;
        end
        if(e_or) begin
            alu_out = a | b;
        end
        if(e_shiftr) begin
            carry_out = a[0];
            rot_buffer = a >> 1;
            alu_out = {carry_in, rot_buffer[6:0]}
        end

        if(enable_dec) begin

        end
    end
endmodule