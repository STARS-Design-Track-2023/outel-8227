module internalDataflow(
    input logic nrst, clk,
    input logic flags[40:0],
    output logic [7:0] externalAddressBusLowOutput, externalAddressBusHighOutput
);
    //outputs from registers
    //ABL = address bus low
    //ABH = address bus high
    //SB = stack bus
    //DB = data bus
    logic [7:0] xRegToSB, //X Register Outputs
                yRegToSB, //Y Register Outputs
                abhRegToExternalABH, //ABH Register Outputs
                ablRegToExternalABL,  //ABL Register Outputs
                pchRegToADH, pchRegToDB, chRegToPCH//PCH Register Outputs
                //PCL Register Outputs
                stackPointerRegToADL, stackPointerRegToSB//Stack Pointer Register Outputs
                aluRegToADL, aluRegToSB//ALU Register Outputs
                //Accumulator Register Outputs
                //DOR Register Outputs
                externalAddressBusLowOutput, programCounterLowRegOutput, 
                programCounterHighRegOutput, aluRegOutput, stackPointerRegOutut, 
                accumulatorRegOutput, dataOututRegOutut;
    
    //current bus lines to be used as inputs to registers and other modules
    logic [7:0] dataBus, addressLowBus, addressHighBus, stackBus;
    
    internalBus #(
        .INPUT_COUNT(3)
    ) dataBusModule (
        .nrst(nrst),
        .clk(clk),
        .busInputs({programCounterLowRegOutput, programCounterHighRegOutput, accumulatorRegOutput}),
        .busOutput(dataBus)
    );

    internalBus #(
        .INPUT_COUNT(2)
    ) addressLowBusModule (
        .nrst(nrst),
        .clk(clk),
        .busInputs({programCounterLowRegOutput, aluRegOutput}),
        .busOutput(addressLowBus)
    );

    internalBus #(
        .INPUT_COUNT(1)
    ) addressHighBusModule (
        .nrst(nrst),
        .clk(clk),
        .busInputs({programCounterHighRegOutput}),
        .busOutput(addressHighBus)
    );

    internalBus #(
        .INPUT_COUNT(5)
    ) stackBus (
        .nrst(nrst),
        .clk(clk),
        .busInputs({stackPointerRegOutut, aluRegOutput, xRegOutput, yRegOutput, accumulatorRegOutput}),
        .busOutput(stackBus)
    );

    register #(
        .INPUT_COUNT(2'd1), 
        .OUTPUT_COUNT(2'd1),
        .DEFAULT_VALUE(8'b0)
    ) xRegister (
        .nrst(nrst),
        .clk(clk), 
        .busInputs(stackBus), 
        .busOutputs(stackBus), 
        .busReadEnable(flags[LOAD_X]), 
        .busWriteEnable(flags[SET_SB_TO_X])
    );

    register #(
        .INPUT_COUNT(2'd1), 
        .OUTPUT_COUNT(2'd1),
        .DEFAULT_VALUE(8'b0)
    ) yRegister (
        .nrst(nrst),
        .clk(clk), 
        .busInputs(stackBus), 
        .busOutputs(stackBus), 
        .busReadEnable(flags[LOAD_Y]), 
        .busWriteEnable(flags[SET_SB_TO_Y])
    );
    
    register #(
        .INPUT_COUNT(2'd1), 
        .OUTPUT_COUNT(2'd2),
        .DEFAULT_VALUE(8'0)
    ) stackPointerRegister (
        .nrst(nrst),
        .clk(clk), 
        .busInputs(stackBus), 
        .busOutputs({stackBus,addressLowBus}), 
        .busReadEnable(), 
        .busWriteEnable({1'b1,pb[17]})
    );

endmodule