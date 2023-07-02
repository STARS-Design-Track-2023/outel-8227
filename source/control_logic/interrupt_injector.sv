module interruptInjector (
    input logic clk, nrst, enableFFs,
    input logic nonMaskableInterrupt, interruptRequest, //Inputs from exterior (could be buttons outside IC)
    input logic processStatusRegIFlag,
    output logic irqGenerated, nmiGenerated, nmiRunning, resetRunning, resetDetected, //output signals that state whether an interrupt has been generated and whether a nonmaskable interrupt is running
    input logic interruptStarted, //Input saying that the I flag has been written
    output logic pendingInterrupt //Output saying that the I flag should be written
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
        .enableFFs(enableFFs),
        .processStatusRegIFlag(processStatusRegIFlag | pendingInterrupt),
        .synchronizedNMI(synchronizedNMI),
        .interruptAcknowleged(interruptStarted),
        .nmiGenerated(nmiGenerated),
        .nmiRunning(nmiRunning)
    );

    //Needed for NMI Implementation
    nmiRunningFF nmiRunningFF(
        .clk(clk),
        .nrst(nrst),
        .enableFFs(enableFFs),
        .processStatusRegIFlag(processStatusRegIFlag | pendingInterrupt),
        .interruptAcknowleged(interruptStarted),
        .nmiGenerated(nmiGenerated),
        .nmiRunning(nmiRunning)
    );

    //NMI Detection
    irqGeneratedFF irqGeneratedFF(
        .clk(clk),
        .nrst(nrst),
        .enableFFs(enableFFs),
        .processStatusRegIFlag(processStatusRegIFlag | pendingInterrupt),
        .synchronizedIRQ(synchronizedIRQ),
        .interruptAcknowleged(interruptStarted),
        .irqGenerated(irqGenerated)
    );

    //Reset detection
    resetDetector resetDetector(
        .nrst(nrst),
        .clk(clk),
        .enableFFs(enableFFs),
        .resetInection(resetDetected)
    );

    //High if a reset is currently being processed
    resetRunningFF resetRunningFF(
        .clk(clk),
        .nrst(nrst),
        .enableFFs(enableFFs),
        .processStatusRegIFlag(processStatusRegIFlag | pendingInterrupt),
        .resetInitiated(resetDetected),
        .resetRunning(resetRunning)
    );

    interruptStartedFF interruptStartedFF (
        .clk(clk),
        .nrst(nrst),
        .enableFFs(enableFFs),
        .set(nmiGenerated | irqGenerated | resetDetected),
        .reset(interruptStarted),
        .out(pendingInterrupt)
    );

endmodule
