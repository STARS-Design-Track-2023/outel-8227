module irqGeneratedFF (
    input logic clk, nrst,
    input logic processStatusRegIFlag,
    input logic synchronizedIRQ,
    input logic interruptAcknowleged,
    output logic irqGenerated
);

    logic nextIRQGenerated;

    always_comb begin : IRQNextStateLogic
        if(~irqGenerated & ~processStatusRegIFlag)
        begin
            //If IRQ is not waiting to be injected and no interrupt is currently running
            nextIRQGenerated = synchronizedIRQ;
        end
        else if(irqGenerated & interruptAcknowleged)
        begin
            //IRQ was waiting to be injected and will be injected this clock cycle
            nextIRQGenerated = 1'b0;
        end
        else if(~processStatusRegIFlag & ~irqGenerated)
        begin
            //Since irqGenerated is low, the interrupt was already received
            //sice PSRi is also low, the interrupt was finished processing
            nextIRQGenerated = 1'b0;
        end
    end

    always_ff @(posedge clk, negedge nrst) begin : nmiAssignment
        if(~nrst)
            nmiGenerated = 1'b0;
        else
            nmiGenerated = nextNMIGenerated;
    end

endmodule