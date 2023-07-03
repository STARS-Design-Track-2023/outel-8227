module interruptStartedFF (
    input logic clk, nrst, enableFFs, set, reset,
    output logic out
);
    logic nextState;
    always_comb begin
        if(reset)
            nextState = 1'b0;
        else if(set)
            nextState = 1'b1;
        else
            nextState = out;

        if(~enableFFs)
            nextState = out;
    end

    always_ff @(posedge clk, negedge nrst) begin
        if(~nrst)
            out <= 1'b0;
        else
            out <= nextState;
    end
endmodule
