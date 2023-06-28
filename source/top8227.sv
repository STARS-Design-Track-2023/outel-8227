module top8227 (
    input  logic clk, nrst, nonMaskableInterrupt, interruptRequest, dataBusEnable, ready, setOverflow,
    input  logic [7:0] dataBusInput,
    output logic [7:0] dataBusOutput,
    output logic [7:0] AddressBusHigh,
    output logic [7:0] AddressBusLow,
    output logic sync, readNotWrite
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
        .externalDBRead(dataBusInput),
        .externalDBWrite(dataBusOutput),
        .externalAddressBusLowOutput(AddressBusLow),
        .externalAddressBusHighOutput(AddressBusHigh),
        .psrRegToLogicController(PSRCurrentValue),
        .aluCarryOut(aluCarryOut)
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
        .CMD(instructionCode),
        .ADDRESS(addressingCode)
    );

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
        .setInterruptFlag(setIFlag)
    );

    free_carry_ff free_carry_ff (
        .clk(clk),
        .nrst(nrst),
        .enableFFs(enableFFs),
        .ALUcarry(aluCarryOut),
        .en(flags[SET_FREE_CARRY_FLAG_TO_ALU]),
        .freeCarry(freeCarry)
    );


endmodule