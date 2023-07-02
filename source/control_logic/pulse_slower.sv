
module pulse_slower(
input logic clk, nrst, 
output logic slow_pulse
);

logic [1:0] currentEnableState; // enableFFs logic
logic [1:0] nextEnableState;


always_comb begin : comb_enableFFs

    if(currentEnableState == 2'b00) // only sets enableFFs high 1/3rd the time, halts the other 2/3rds
        slow_pulse = 1'b1;
    else
        slow_pulse = 1'b0;

    case(currentEnableState) // current enable state cycles through 3 clock cycles
    2'b00: nextEnableState = 2'b01;
    2'b01: nextEnableState = 2'b10;
    2'b10: nextEnableState = 2'b00;
    default: nextEnableState = 2'b00;
    endcase

end

always_ff @( posedge clk, negedge nrst ) begin : ff_enableFFs
    if(nrst == 1'b0)
        currentEnableState <= 2'b00;
    else
        currentEnableState <= nextEnableState;
end

endmodule
