module nmiRunningFF (
    input logic clk, nrst, enableFFs,
    input logic processStatusRegIFlag,
    input logic interruptAcknowleged,
    input logic nmiGenerated,
    output logic nmiRunning
);

    logic nextNMIRunning;

    always_comb begin : NMInextStateLogic
        if(~nmiRunning & ~nmiGenerated)
        begin
            //No NMI (normal operation)
            //If one is generated, set nmiG high.  nmiR will be set high once the interrupt is injected
            nextNMIRunning = 1'b0;
        end
        else if(nmiGenerated & interruptAcknowleged)
        begin
            //NMI was waiting to be injected and will be injected this clock cycle
            nextNMIRunning = 1'b1;
        end
        else if(~processStatusRegIFlag & ~nmiGenerated)
        begin
            //Since nmiGenerated is low, the interrupt was already received
            //sice PSRi is also low, the interrupt was finished processing
            nextNMIRunning = 1'b0;
        end
        else
        begin
            nextNMIRunning = nmiRunning;
        end
        if(~enableFFs)
            nextNMIRunning = nmiRunning;
    end

    always_ff @(posedge clk, negedge nrst) begin : nmiAssignment
        if(~nrst)
            nmiRunning <= 1'b0;
        else
            nmiRunning <= nextNMIRunning;
    end

endmodule
