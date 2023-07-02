module nmiGeneratedFF (
    input logic clk, nrst, enableFFs,
    input logic processStatusRegIFlag,
    input logic synchronizedNMI,
    input logic interruptAcknowleged,
    input logic nmiRunning,
    output logic nmiGenerated
);

    logic nextNMIGenerated;

    always_comb begin : NMInextStateLogic
        if(~nmiRunning & ~nmiGenerated)
        begin
            //No NMI (normal operation)
            //If one is generated, set nmiG high.  nmiR will be set high once the interrupt is injected
            nextNMIGenerated = synchronizedNMI;
        end
        else if(nmiGenerated & interruptAcknowleged)
        begin
            //NMI was waiting to be injected and will be injected this clock cycle
            nextNMIGenerated = 1'b0;
        end
        else if(~processStatusRegIFlag & ~nmiGenerated)
        begin
            //Since nmiGenerated is low, the interrupt was already received
            //sice PSRi is also low, the interrupt was finished processing
            nextNMIGenerated = 1'b0;
        end
        else
        begin
            nextNMIGenerated = nmiGenerated;
        end
        if(~enableFFs & ~(~nmiRunning & ~nmiGenerated)) //Only freeze when not listening for a signal
            nextNMIGenerated = nmiGenerated;
    end

    always_ff @(posedge clk, negedge nrst) begin : nmiAssignment
        if(~nrst)
            nmiGenerated <= 1'b0;
        else
            nmiGenerated <= nextNMIGenerated;
    end

endmodule
