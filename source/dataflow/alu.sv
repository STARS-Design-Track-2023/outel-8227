module alu(
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
    input logic subtracting,
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

    logic [7:0] sum;                                    //buffer to hold sum and cout
    logic sum_carry_out;              //holds the carry out from sum function
    logic [6:0] rot_buffer;                             //buffer to hold shifted part of rotate

    logic [3:0] lo_nib_a, hi_nib_a;                         //for bcd ops
    logic [3:0] lo_nib_b, hi_nib_b;                         //for bcd ops
    logic [3:0] lo_nib_c, hi_nib_c;                         //for bcd ops
    logic half_carry;

    logic garbage;
    //NOTE: ALU is only directly responsible for outputting carry and overflow

    //Constant selects in Always_* processes are unsupported so much of this is done outside of always_comb blocks
    
    //Assign the output and carryout from the sum 
    assign {sum_carry_out, sum} = a + b + {7'b0000000, carry_in};
    //assign {garbage, sum} = a + b + {7'b0000000, carry_in};
    //assign sum_carry_out = 1'b0;
    //Set the overflow flag (right now it is only set in sum, it might need to be selected later)
    assign overflow = (a[7] ^ sum[7]) & (b[7] ^ sum[7]) & (~(enable_dec && e_sum));
    
    always_comb begin
        alu_out = 0;                                    //default to 0
        carry_out = 0;
        rot_buffer = 0;
        lo_nib_a = 0;
        hi_nib_a = 0;                         //for bcd ops
        lo_nib_b = 0;
        hi_nib_b = 0;                         //for bcd ops
        lo_nib_c = 0;
        hi_nib_c = 0;                         //for bcd ops
        half_carry = 0;

        if(e_sum) begin                                 //handle addition with carry and overflow
            alu_out = sum;
            carry_out = sum_carry_out;
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
            {alu_out, carry_out} = {carry_in, a};
        end

        if(enable_dec && e_sum) begin                            //handle add/subtract in bcd
            {hi_nib_a, lo_nib_a} = a;
            {hi_nib_b, lo_nib_b} = b;
            //Determine Low Nibble
            if(({1'b0, lo_nib_a} + {1'b0, lo_nib_b} + {4'b0, carry_in} > 5'b01001) & (lo_nib_a + lo_nib_b + {3'b0, carry_in} < 5'b10000)) begin
                if(~subtracting)
                    lo_nib_c = lo_nib_a + lo_nib_b + {3'b0, carry_in} + 4'b0110;
                else
                    lo_nib_c = lo_nib_a + lo_nib_b + {3'b0, carry_in} + 4'b1010;
            end else
                lo_nib_c = lo_nib_a + lo_nib_b + {3'b0, carry_in};

            //Set half_Carry
            if(lo_nib_a + lo_nib_b + {3'b0, carry_in} > 5'b01001)
                half_carry = 1;
            
            
            //Determine Low Nibble
            if(({1'b0, hi_nib_a} + {1'b0, hi_nib_b} + {4'b0, half_carry} > 5'b01001) & (hi_nib_a + hi_nib_b + {3'b0, half_carry} < 5'b10000)) begin
                if(~subtracting)
                    hi_nib_c = hi_nib_a + hi_nib_b + {3'b0, half_carry} + 4'b0110;
                else
                    hi_nib_c = hi_nib_a + hi_nib_b + {3'b0, half_carry} + 4'b1010;
            end else
                hi_nib_c = hi_nib_a + hi_nib_b + {3'b0, half_carry};

            //Set Carry Out
            if(hi_nib_a + hi_nib_b + {3'b0, half_carry} > 5'b01001)
                carry_out = 1;

            alu_out = {hi_nib_c, lo_nib_c};
         end
    end
endmodule