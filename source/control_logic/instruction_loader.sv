module instructionLoader (
    input logic clk, nrst,
    input logic nonMaskableInterrupt, interruptRequest, processStatusRegIFlag, loadNextInstruction,
    input loig externalDB,
    output logic [7:0] currentInstruction,
    output logic enableIFlag,
    output logic nmiRunning, resetRunning
);

    logic resetDected, irqGenerated, nmiGenerated;
    logic instructionRegReadEnable; //Normally the same as 'loadNextInstruction' but needs to go high if a reset is detected

    logic [7:0] nextInstruction;

    //Interrupt
    interruptInjector interruptInjector(
        .clk(clk),
        .nrst(nrst),
        .nonMaskableInterrupt(nonMaskableInterrupt),
        .interruptRequest(interruptRequest), //Inputs from exterior (could be buttons outside IC)
        .processStatusRegIFlag(processStatusRegIFlag),
        .interruptAcknowleged(instructionRegReadEnable), //instructionRegReadEnable is high going into the clock cycle where the interrupt request will be processed
        .irqGenerated(irqGenerated), 
        .nmiGenerated(nmiGenerated), 
        .nmiRunning(nmiRunning), 
        .resetRunning(resetRunning)
    );

    //Instruction Register Loading Logic
    always_comb begin
        nextInstruction = externalDB; //Normally, the next Instruction is read from the external db
        instructionRegReadEnable = loadNextInstruction;
        
        //If a reset is detected load a break instruction on the next 
        if (resetDected)
        begin
            instructionRegReadEnable = 1'b1;
            nextInstruction = 8'b0;//Load a break instruction
        end

        if (irqGenerated|nmiGenerated)
        begin
            nextInstruction = 8'b0;//Load a break instruction when the next opcode is requested
        end
    end

    //Instruction Register
    register #(
        .INPUT_COUNT(1),
        .OUTPUT_COUNT(1),
        .DEFAULT_VALUE(8'b0)
    ) instructionRegister (
        .nrst(nrst),
        .clk(clk),
        .busInputs(nextInstruction),
        .busOutputs(currentInstruction),
        .busReadEnable(instructionRegReadEnable)
    );

endmodule