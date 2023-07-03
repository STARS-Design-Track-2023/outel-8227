`ifndef NUMFLAGS
`include "source/param_file.sv"
`endif

module top8227 (
    input  logic clk, nrst, nonMaskableInterrupt, interruptRequest, dataBusEnable, ready, setOverflow,
    input  logic [7:0] dataBusInput,
    output logic [7:0] dataBusOutput,
    output logic [7:0] addressBusHigh,
    output logic [7:0] addressBusLow,
    output logic sync, readNotWrite,
    output logic functionalClockOut,
    output logic dataBusSelect,
    output logic M10ClkOut
);
    logic [7:0] PSRCurrentValue;
    logic [7:0] opcodeCurrentValue;
    logic [3:0] addressingCode;
    logic [5:0] instructionCode;
    logic       aluCarryOut, freeCarry;
    logic       nmiRunning, nmiGenerated, resetRunning;
    logic [`NUMFLAGS-1:0] flags, preFlags;
    logic getInstructionPreInjection, getInstructionPostInjection;
    logic setIFlag;
    logic enableFFs;
    logic slow_pulse; // used to slow down the cpu so it can access memory
    logic pclMSB;
    logic branchBackward, branchForward;
    logic load_psr_I, psr_data_to_load;
    logic initiateInterruptWithPCDecrement;
    logic setOverflowEdge;

    assign M10ClkOut = clk; //10MHz ClockOut

    assign dataBusSelect = readNotWrite | ~dataBusEnable; //High if supposed to be reading or if dbe is low (disabling the drivers)

    assign functionalClockOut = slow_pulse & clk;

    assign enableFFs = (ready | ~readNotWrite) & slow_pulse;
    
    assign sync = flags[`END_INSTRUCTION];

    //Disable all flags
    always_comb begin
        if(enableFFs)
        begin
            flags = preFlags;
        end
        else
            flags = 0;
    end

    negEdgeDetector negEdgeDetector (
        .clk(clk),
        .nrst(nrst),
        .enableFFs(enableFFs),
        .in(setOverflow),
        .out(setOverflowEdge)
    );

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
        .setOverflow(setOverflowEdge & enableFFs),//Only set when enableFFs is true
        .load_psr_I(load_psr_I), 
        .psr_data_to_load(psr_data_to_load),
        .initiateInterruptWithPCDecrement(initiateInterruptWithPCDecrement)
    );

    

    instructionLoader instructionLoader(
        .clk(clk), 
        .nrst(nrst),
        .enableFFs(enableFFs),
        .nonMaskableInterrupt(~nonMaskableInterrupt), 
        .interruptRequest(~interruptRequest), 
        .processStatusRegIFlag(PSRCurrentValue[2]), 
        .loadNextInstruction(getInstructionPreInjection),
        .externalDB(dataBusInput),
        .nextInstruction(opcodeCurrentValue),
        .enableIFlag(setIFlag),//Output
        .nmiRunning(nmiRunning),
        .nmiGenerated(nmiGenerated),
        .resetRunning(resetRunning),
        .instructionRegReadEnable(getInstructionPostInjection),
        .initiateInterruptWithPCDecrement(initiateInterruptWithPCDecrement),
        .interruptFlagWasSet(load_psr_I) //Input

    );

    //If supposed to load a new instruction (getInstructionPreInjection) and it is a zero due to an interrupt

    decoder decoder(
        .opcode(opcodeCurrentValue),
        .cmd(instructionCode),
        .address(addressingCode)
    );

    demux demux(
        .preFFInstructionCode(instructionCode),
        .preFFAddressingCode(addressingCode),
        .nrst(nrst), 
        .clk(clk), 
        .enableFFs(enableFFs),
        .nmi(nmiGenerated), 
        .irq(setIFlag & ~resetRunning), //High I flag in PSR, reset not running
        .reset(resetRunning), 
        .PSR_C(PSRCurrentValue[0]), 
        .PSR_N(PSRCurrentValue[7]), 
        .PSR_V(PSRCurrentValue[6]), 
        .PSR_Z(PSRCurrentValue[1]),
        .getInstructionPostInjection(getInstructionPostInjection),
        .getInstructionPreInjection(getInstructionPreInjection),
        .outflags(preFlags),
        .setInterruptFlag(setIFlag), //Input
        .branchForwardFF(branchForward),
        .branchBackwardFF(branchBackward),
        .load_psr_I(load_psr_I), //Output
        .psr_data_to_load(psr_data_to_load),
        .readNotWrite(readNotWrite)
    );

    free_carry_ff free_carry_ff (
        .clk(clk),
        .nrst(nrst),
        .enableFFs(enableFFs),
        .ALUcarry(aluCarryOut),
        .en(flags[`SET_FREE_CARRY_FLAG_TO_ALU]),
        .freeCarry(freeCarry)
    );

    branch_ff branch_ff (
        .clk(clk),
        .nrst(nrst),
        .branchForwardIn(  pclMSB & ~dataBusInput[7] &  aluCarryOut),
        .branchBackwardIn(~pclMSB &  dataBusInput[7] & ~aluCarryOut),
        .enable(flags[`SET_BRANCH_PAGE_CROSS_FLAGS]),
        .enableFFs(enableFFs),
        .branchForward(branchForward),
        .branchBackward(branchBackward)
    );


endmodule
