module interruptInjector (
    input logic clk, nrst,
    input logic nonMaskableInterrupt, interruptRequest, //Inputs from exterior (could be buttons outside IC)
    input logic processStatusRegIFlag,
    input logic interruptAcknowleged, //Should be high going into the clock cycle when the Instruction Register is loaded
    output logic irqGenerated, nmiGenerated, nmiRunning, resetRunning, resetDetected //output signals that state whether an interrupt has been generated and whether a nonmaskable interrupt is running
);

    logic synchronizedNMI, synchronizedIRQ;

    synchronizer nmiSync(
        .nrst(nrst),
        .clk(clk),
        .in(nonMaskableInterrupt),
        .out(synchronizedNMI)
    );

    synchronizer irqSync(
        .nrst(nrst),
        .clk(clk),
        .in(interruptRequest),
        .out(synchronizedIRQ)
    );

    //Flipflops are needed to track if nmi is running or generated

    //NMI Detection
    nmiGeneratedFF nmiGeneratedFF(
        .clk(clk),
        .nrst(nrst),
        .processStatusRegIFlag(processStatusRegIFlag),
        .synchronizedNMI(synchronizedNMI),
        .interruptAcknowleged(interruptAcknowleged),
        .nmiGenerated(nmiGenerated),
        .nmiRunning(nmiRunning)
    );

    //Needed for NMI Implementation
    nmiRunningFF nmiRunningFF(
        .clk(clk),
        .nrst(nrst),
        .processStatusRegIFlag(processStatusRegIFlag),
        .synchronizedNMI(synchronizedNMI),
        .interruptAcknowleged(interruptAcknowleged),
        .nmiGenerated(nmiGenerated),
        .nmiRunning(nmiRunning)
    );

    //NMI Detection
    irqGeneratedFF irqGeneratedFF(
        .clk(clk),
        .nrst(nrst),
        .processStatusRegIFlag(processStatusRegIFlag),
        .synchronizedIRQ(synchronizedIRQ),
        .interruptAcknowleged(interruptAcknowleged),
        .irqGenerated(irqGenerated)
    );

    //Reset detection
    resetDetector resetDetector(
        .nrst(nrst),
        .clk(clk),
        .resetInection(resetDetected)
    );

    //High if a reset is currently being processed
    resetRunningFF resetRunningFF(
        .clk(clk),
        .nrst(nrst),
        .processStatusRegIFlag(processStatusRegIFlag),
        .resetInitiated(resetDetected),
        .resetRunning(resetRunning)
    );

endmodule