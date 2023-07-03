module instructionLoader (
    input logic clk, nrst, enableFFs,
    input logic nonMaskableInterrupt, interruptRequest, processStatusRegIFlag, loadNextInstruction,
    input logic [7:0] externalDB,
    // output logic [7:0] currentInstruction,
    output logic enableIFlag,
    output logic nmiRunning, nmiGenerated, resetRunning, instructionRegReadEnable, //instructionRegReadEnable: Normally the same as 'loadNextInstruction' but needs to go high if a reset is detected
    output logic [7:0] nextInstruction,
    output logic initiateInterruptWithPCDecrement,
    input logic interruptFlagWasSet
);

    logic resetDetected, irqGenerated;


    //Interrupt
    interruptInjector interruptInjector(
        .clk(clk),
        .nrst(nrst),
        .enableFFs(enableFFs),
        .nonMaskableInterrupt(nonMaskableInterrupt),
        .interruptRequest(interruptRequest), //Inputs from exterior (could be buttons outside IC)
        .processStatusRegIFlag(processStatusRegIFlag),
        .irqGenerated(irqGenerated), 
        .nmiGenerated(nmiGenerated), 
        .nmiRunning(nmiRunning),
        .resetRunning(resetRunning),
        .resetDetected(resetDetected),
        .interruptStarted(interruptFlagWasSet), //Input saying that the I flag has been written
        .pendingInterrupt(enableIFlag) //Output saying that the I flag should be written
    );

    //Instruction Register Loading Logic
    always_comb begin
        nextInstruction = externalDB; //Normally, the next Instruction is read from the external db
        instructionRegReadEnable = loadNextInstruction;
        
        //If a reset is detected load a break instruction on the next 
        if (resetDetected)
        begin
            instructionRegReadEnable = 1'b1;
            nextInstruction = 8'b0;//Load a break instruction
        end

        if (irqGenerated|nmiGenerated)
        begin
            nextInstruction = 8'b0;//Load a break instruction when the next opcode is requested
        end
    end

    //Set the PSR I flag to high if a reset is detected or an interrupt is beginning its instruction cycle
    //assign enableIFlag = resetDetected | ((irqGenerated | nmiGenerated) & instructionRegReadEnable);

    assign initiateInterruptWithPCDecrement = (irqGenerated | nmiGenerated) & instructionRegReadEnable;
    //Instruction Register
    // register #(
    //     .INPUT_COUNT(1),
    //     .OUTPUT_COUNT(1),
    //     .DEFAULT_VALUE(8'b0)
    // ) instructionRegister (
    //     .nrst(nrst),
    //     .clk(clk),
    //     .busInputs(nextInstruction),
    //     .busOutputs(currentInstruction),
    //     .busReadEnable(instructionRegReadEnable)
    // );

endmodule
