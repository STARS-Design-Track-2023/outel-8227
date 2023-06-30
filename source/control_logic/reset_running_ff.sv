module resetRunningFF (
    input logic clk, nrst, enableFFs,
    input logic processStatusRegIFlag,
    input logic resetInitiated,
    output logic resetRunning
);

    logic nextResetRunning;

    always_comb begin : resetRunningNextStateLogic
        if(resetInitiated)
            nextResetRunning = 1'b1; //If a reset was started, set this control FF
        else if(~processStatusRegIFlag)
            nextResetRunning = 1'b0; //Once the I flag drives low, clear this control FF
        else
            nextResetRunning = resetRunning; //Otherwise hold the current value
        if(~enableFFs)
            nextResetRunning = resetRunning;
    end

    always_ff @(posedge clk, negedge nrst) begin : nmiAssignment
        if(~nrst)
            resetRunning <= 1'b0;
        else
            resetRunning <= nextResetRunning;
    end

endmodule
