module alu (
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
        a = 0;
        b = 0;

        if(ldb_inv_db) b = ~DB_input;
        if(ldb_db) b = DB_input;
        if(ldb_adl) b = ADL_input;

        if(lda_sb) a = SB_input;
        if(lda_zero) a = 8'b00000000;
    end

    logic [8:0] sum;                                    //buffer to hold sum and cout
    logic [7:0] rot_buffer;                             //buffer to hold shifted part of rotate

    logic [3:0] lo_nib, hi_nib;                         //for bcd ops
    logic [7:0] bcd_buffer;

    //NOTE: ALU is only directly responsible for outputting carry and overflow
    always_comb begin
        alu_out = 0;                                    //default to 0
        carry_out = 0;
        overflow = 0;
        sum = 0;
        rot_buffer = 0;
        lo_nib = 0;
        hi_nib = 0;
        bcd_buffer = 0;

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
            alu_out = {carry_in, rot_buffer[6:0]};
        end

        if(enable_dec) begin                            //handle add/subtract in bcd
            if(carry_in) begin
                if(e_sum) begin
                    bcd_buffer = a - b;
                    lo_nib = bcd_buffer[3:0];
                    hi_nib = bcd_buffer[7:4];
                    if(lo_nib > 4'b1001) begin
                        lo_nib = lo_nib + 4'b1010;
                    end
                    if(hi_nib > 4'b1001) begin
                        hi_nib = hi_nib + 4'b1010;
                        carry_out = 1;
                    end

                    alu_out = {hi_nib, lo_nib};
                end

            end else begin
                if(e_sum) begin
                    bcd_buffer = a + b;
                    lo_nib = bcd_buffer[3:0];
                    hi_nib = bcd_buffer[7:4];
                    if(lo_nib > 4'b1001) begin
                        lo_nib = lo_nib + 4'b0110;
                    end
                    if(hi_nib > 4'b1001) begin
                        hi_nib = hi_nib + 4'b0110;
                        carry_out = 1;
                    end

                    alu_out = {hi_nib, lo_nib};
                end
            end
        end
    end
endmodule
