module resetDetector (
    input logic clk, nrst,
    output logic resetInection
);

    logic state, nextState;

    always_ff @(posedge clk, negedge nrst) begin : nextStateAssignment
        if(~nrst)
            state = 1'b1;
        else
            state = nextState;
    end

    assign nextState = 1'b0;

    always_comb begin : outputLogic
        resetInection = state;
    end

endmodule