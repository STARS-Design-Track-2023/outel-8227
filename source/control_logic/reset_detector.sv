module resetDetector (
    input logic clk, nrst, enableFFs,
    output logic resetInection
);

    logic state, nextState;

    always_ff @(posedge clk, negedge nrst) begin : nextStateAssignment
        if(~nrst)
            state <= 1'b1;
        else
            state <= nextState;
    end

    always_comb begin : nextStateLogic
        nextState = 1'b0;
        if(~enableFFs)
            nextState = state;
    end

    always_comb begin : outputLogic
        resetInection = state;
    end

endmodule
