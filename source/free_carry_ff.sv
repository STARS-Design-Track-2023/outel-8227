module free_carry_ff (
input logic clk, rst, ALUcarry, en,
output logic freeCarry
);

logic freeCarryNext;
always_comb begin : comb_free_carry_ff
    if(en == 1'b1)                      // if the input is enabled
        freeCarryNext = ALUcarry;
    else 
        freeCarryNext = freeCarry;      // do not update
end

always_ff @( posedge clk, negedge rst ) begin : ff_free_carry_ff
    if(rst == 0'b1)         // resets to 0
        freeCarry = 1'b0;
    else
        freeCarry = freeCarryNext;
end

endmodule