module top8227 (
    input  logic clk, nrst, nonMaskableInterrupt, interruptRequest, dataBusEnable 
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
    logic [NUMFLAGS-1:0] flags;
    logic getInstructionPreInjection, getInstructionPostInjection;
    logic setIFlag;

    assign readNotWrite = ~flags[SET_WRITE_FLAG];

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
        .outflags(flags),
        .setInterruptFlag(setIFlag)
    );

    free_carry_ff free_carry_ff (
        .clk(clk),
        .nrst(nrst),
        .ALUcarry(aluCarryOut),
        .en(flags[SET_FREE_CARRY_FLAG_TO_ALU]),
        .freeCarry(freeCarry)
    );


endmodule