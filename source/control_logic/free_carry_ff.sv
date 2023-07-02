module free_carry_ff (
input logic clk, nrst, ALUcarry, en, enableFFs,
output logic freeCarry
);

logic freeCarryNext;
always_comb begin : comb_free_carry_ff
    if(en == 1'b1)                      // if the input is enabled
        freeCarryNext = ALUcarry;
    else 
        freeCarryNext = freeCarry;      // do not update
    if(~enableFFs)
        freeCarryNext = freeCarry;
end

always_ff @( posedge clk, negedge nrst ) begin : ff_free_carry_ff
    if(nrst == 1'b0)         // resets to 0
        freeCarry <= 1'b0;
    else
        freeCarry <= freeCarryNext;
end

endmodule
