module top8227 (
    input  logic clk, nrst, nonMaskableInterrupt, interruptRequest, dataBusEnable, ready, setOverflow,
    input  logic [7:0] dataBusInput,
    output logic [7:0] dataBusOutput,
    output logic [7:0] addressBusHigh,
    output logic [7:0] addressBusLow,
    output logic sync, readNotWrite,
    output logic [7:0] debug, debug2,
    output logic debugRed
);
    logic [7:0] PSRCurrentValue;
    logic [7:0] opcodeCurrentValue;
    logic [3:0] addressingCode;
    logic [5:0] instructionCode;
    logic       getInstruction;
    logic       aluCarryOut, freeCarry;
    logic       nmiRunning, resetRunning;
    logic [NUMFLAGS-1:0] flags, preFlags;
    logic getInstructionPreInjection, getInstructionPostInjection;
    logic setIFlag;
    logic enableFFs;
    logic slow_pulse; // used to slow down the cpu so it can access memory
    logic pclMSB;
    logic branchBackward, branchForward;

    assign readNotWrite = ~preFlags[SET_WRITE_FLAG];
    assign enableFFs = (ready | ~readNotWrite) & slow_pulse;
    
    assign sync = flags[END_INSTRUCTION];

    //Disable all flags
    always_comb begin
        if(enableFFs)
        begin
            flags = preFlags;
            flags[LOAD_OVERFLOW_PSR_FLAG] = setOverflow;
        end
        else
            flags = 0;
    end

 pulse_slower pulse_slower(
.clk(clk), 
.nrst(nrst), 
.slow_pulse(slow_pulse)
);

    internalDataflow internalDataflow(
        .nrst(nrst),
        .clk(clk),
        .flags(flags),
        .freeCarry(freeCarry),
        .psrCarry(PSRCurrentValue[0]),
        .externalDBRead(dataBusInput),
        .externalDBWrite(dataBusOutput),
        .externalAddressBusLowOutput(addressBusLow),
        .externalAddressBusHighOutput(addressBusHigh),
        .psrRegToLogicController(PSRCurrentValue),
        .aluCarryOut(aluCarryOut),
        .pclMSB(pclMSB),
        .debug()
    );

    instructionLoader instructionLoader(
        .clk(clk), 
        .nrst(nrst),
        .enableFFs(enableFFs),
        .nonMaskableInterrupt(nonMaskableInterrupt), 
        .interruptRequest(interruptRequest), 
        .processStatusRegIFlag(PSRCurrentValue[2]), 
        .loadNextInstruction(getInstructionPreInjection),
        .externalDB(dataBusInput),
        .nextInstruction(opcodeCurrentValue),
        .enableIFlag(setIFlag),
        .nmiRunning(nmiRunning), 
        .resetRunning(resetRunning),
        .instructionRegReadEnable(getInstructionPostInjection)
    );

    decoder decoder(
        .opcode(opcodeCurrentValue),
        .cmd(instructionCode),
        .address(addressingCode)
    );

    assign debug[3:0] = addressingCode;
    assign debug2[1] = slow_pulse;

    demux demux(
        .preFFInstructionCode(instructionCode),
        .preFFAddressingCode(addressingCode),
        .nrst(nrst), 
        .clk(clk), 
        .enableFFs(enableFFs),
        .free_carry(freeCarry), 
        .nmi(nmiRunning), 
        .irq(PSRCurrentValue[2] & ~resetRunning), //High I flag in PSR, reset not running
        .reset(resetRunning), 
        .PSR_C(PSRCurrentValue[0]), 
        .PSR_N(PSRCurrentValue[7]), 
        .PSR_V(PSRCurrentValue[6]), 
        .PSR_Z(PSRCurrentValue[1]),
        .getInstructionPostInjection(getInstructionPostInjection),
        .getInstructionPreInjection(getInstructionPreInjection),
        .outflags(preFlags),
        .setInterruptFlag(setIFlag),
        .branchForwardFF(branchForward),
        .branchBackwardFF(branchBackward),
        .debug(),
        .debug2(/*debug2*/),
        .debugRed(debugRed)
    );

    free_carry_ff free_carry_ff (
        .clk(clk),
        .nrst(nrst),
        .enableFFs(enableFFs),
        .ALUcarry(aluCarryOut),
        .en(flags[SET_FREE_CARRY_FLAG_TO_ALU]),
        .freeCarry(freeCarry)
    );

    branch_ff branch_ff (
        .clk(clk),
        .nrst(nrst),
        .branchForwardIn(  pclMSB & ~dataBusInput[7] &  aluCarryOut),
        .branchBackwardIn(~pclMSB &  dataBusInput[7] & ~aluCarryOut),
        .enable(flags[SET_BRANCH_PAGE_CROSS_FLAGS]),
        .enableFFs(enableFFs),
        .branchForward(branchForward),
        .branchBackward(branchBackward)
    );


endmodule