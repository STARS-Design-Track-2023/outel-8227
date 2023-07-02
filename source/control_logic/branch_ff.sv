module branch_ff (
    input logic clk, nrst, branchForwardIn, branchBackwardIn, enable, enableFFs,
    output logic branchForward, branchBackward
);

logic branchForwardNext, branchBackwardNext;

always_comb begin : nextStateLogic
    if(enable == 1'b1) begin                     // if the input is enabled
        branchForwardNext = branchForwardIn;
        branchBackwardNext = branchBackwardIn;
    end else begin 
        branchForwardNext = branchForward;
        branchBackwardNext = branchBackward;
    end
    
    if(~enableFFs) begin
        branchForwardNext = branchForward;
        branchBackwardNext = branchBackward;
    end
end

always_ff @( posedge clk, negedge nrst ) begin : nextStateAssignment
    if(nrst == 1'b0) begin         // resets to 0
        branchForward <= 1'b0;
        branchBackward <= 1'b0;
    end else begin
        branchForward <= branchForwardNext;
        branchBackward <= branchBackwardNext;
    end
end

endmodule
