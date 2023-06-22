module internalDataflow(
    input logic nrst, clk,
    input logic flags[100:0],
    output logic [7:0] externalAddressBusLowOutput, externalAddressBusHighOutput
);
    //outputs from registers
    //ABL = address bus low
    //ABH = address bus high
    //SB = stack bus
    //DB = data bus
    //DOR = data output register
    logic [7:0] xRegToSB, //X Register Outputs
                yRegToSB, //Y Register Outputs
                abhRegToExternalADH, //ABH Register Outputs
                ablRegToExternalADL,  //ABL Register Outputs
                pchRegToADH, pchRegToDB, pchRegToPcIncrementer, //PCH Register Outputs
                pclRegToADL, pclRegToDB, pclRegToPcIncrementer, //PCL Register Outputs
                stackPointerRegToADL, stackPointerRegToSB, //Stack Pointer Register Outputs
                aluRegToADL, aluRegToSB, //ALU Register Outputs
                accRegToDB, accRegToSB, //Accumulator Register Outputs
                dorRegToExternalDB, //DOR Register Outputs
                pcIncrementerToPchReg, pcIncrementerToPclReg;//PCIncrementer Outputs
                adlADHIncrementerToPchReg, adlADHIncrementerToPclReg,//PCIncrementer Outputs from the ADH,ADL lines
                aluOutput, aluCarryOut, aluOverflowOut; //Output line from ALU

    
    //current bus lines to be used as inputs to registers and other modules
    logic [7:0] dataBus, addressLowBus, addressHighBus, stackBus;
    
    internalBus #(
        .INPUT_COUNT(3)
    ) dataBusModule (
        .nrst(nrst),
        .clk(clk),
        .busInputs({pchRegToDB, pclRegToDB, accRegToDB}),
        .busOutput(dataBus)
    );

    internalBus #(
        .INPUT_COUNT(3)
    ) addressLowBusModule (
        .nrst(nrst),
        .clk(clk),
        .busInputs({stackPointerRegToADL, aluRegToADL, pclRegToADL}),
        .busOutput(addressLowBus)
    );

    internalBus #(
        .INPUT_COUNT(1)
    ) addressHighBusModule (
        .nrst(nrst),
        .clk(clk),
        .busInputs({pchRegToADH}),
        .busOutput(addressHighBus)
    );

    internalBus #(
        .INPUT_COUNT(5)
    ) stackBus (
        .nrst(nrst),
        .clk(clk),
        .busInputs({xRegToSB, yRegToSB, stackPointerRegToSB, aluRegToSB, accRegToSB}),
        .busOutput(stackBus)
    );

    //X Register
    register #(
        .INPUT_COUNT(2'd1), 
        .OUTPUT_COUNT(2'd1),
        .DEFAULT_VALUE(8'b0)
    ) xRegister (
        .nrst(nrst),
        .clk(clk), 
        .busInputs(stackBus), 
        .busOutputs(xRegToSB), 
        .busReadEnable(flags[LOAD_X]), 
        .busWriteEnable(flags[SET_SB_TO_X])
    );

    //Y Register
    register #(
        .INPUT_COUNT(2'd1), 
        .OUTPUT_COUNT(2'd1),
        .DEFAULT_VALUE(8'b0)
    ) yRegister (
        .nrst(nrst),
        .clk(clk), 
        .busInputs(stackBus), 
        .busOutputs(yRegToSB), 
        .busReadEnable(flags[LOAD_Y]), 
        .busWriteEnable(flags[SET_SB_TO_Y])
    );

    //ABH Register
    register #(
        .INPUT_COUNT(2'd1), 
        .OUTPUT_COUNT(2'd1),
        .DEFAULT_VALUE(8'0)
    ) abhRegister (
        .nrst(nrst),
        .clk(clk), 
        .busInputs(addressHighBus), 
        .busOutputs(abhRegToExternalADH), 
        .busReadEnable(flags[LOAD_ABH]), 
        .busWriteEnable(1'b1)//always write
    );

    //ABL Register
    register #(
        .INPUT_COUNT(2'd1), 
        .OUTPUT_COUNT(2'd1),
        .DEFAULT_VALUE(8'0)
    ) ablRegister (
        .nrst(nrst),
        .clk(clk), 
        .busInputs(addressHighBus), 
        .busOutputs(abhRegToExternalADL), 
        .busReadEnable(flags[LOAD_ABL]), 
        .busWriteEnable(1'b1)//always write
    );

    //PCH Register
    register #(
        .INPUT_COUNT(2'd2), 
        .OUTPUT_COUNT(2'd3),
        .DEFAULT_VALUE(8'0)
    ) pchRegister (
        .nrst(nrst),
        .clk(clk), 
        .busInputs(pcIncrementerToPchReg, adlADHIncrementerToPchReg), 
        .busOutputs({pchRegToADH, pchRegToDB, pchRegToPcIncrementer}), 
        .busReadEnable({~flags[LOAD_PC], flags[LOAD_PC]}), //If load_pc is high, load from ADL/ADH, else load from PC
        .busWriteEnable({flags[SET_ADH_TO_PCH], flags[SET_DB_TO_PCH], 1'b1})//always write to the incrementer
    );

    //PCL Register
    register #(
        .INPUT_COUNT(2'd2), 
        .OUTPUT_COUNT(2'd3),
        .DEFAULT_VALUE(8'0)
    ) pclRegister (
        .nrst(nrst),
        .clk(clk), 
        .busInputs(pcIncrementerToPclReg, adlADHIncrementerToPclReg), 
        .busOutputs({pclRegToADL, pclRegToDB, pclRegToPcIncrementer}), 
        .busReadEnable({~flags[LOAD_PC], flags[LOAD_PC]}), //If load_pc is high, load from ADL/ADH, else load from PC
        .busWriteEnable({flags[SET_ADL_TO_PCL], flags[SET_DB_TO_PCL], 1'b1})//always write to the incrementer
    );

    //Stack Pointer Register
    register #(
        .INPUT_COUNT(2'd1), 
        .OUTPUT_COUNT(2'd2),
        .DEFAULT_VALUE(8'0)
    ) stackPointerRegister (
        .nrst(nrst),
        .clk(clk), 
        .busInputs(stackBus), 
        .busOutputs({stackPointerRegToSB,stackPointerRegToADL}), 
        .busReadEnable(flags[LOAD_SP]), 
        .busWriteEnable({flags[SET_SB_TO_SP],flags[SET_ADL_TO_SP]})
    );

    //ALU Register
    register #(
        .INPUT_COUNT(2'd1), 
        .OUTPUT_COUNT(2'd2),
        .DEFAULT_VALUE(8'0)
    ) aluRegister (
        .nrst(nrst),
        .clk(clk), 
        .busInputs(aluOutput), 
        .busOutputs({aluRegToADL, aluRegToSB}), 
        .busReadEnable(flags[LOAD_ALU]), 
        .busWriteEnable({flags[SET_ADL_TO_ALU],flags[SET_SB_TO_ALU]})
    );

    //Accumulator Register
    register #(
        .INPUT_COUNT(2'd1), 
        .OUTPUT_COUNT(2'd2),
        .DEFAULT_VALUE(8'0)
    ) accumulatorRegister (
        .nrst(nrst),
        .clk(clk), 
        .busInputs(stackBus), 
        .busOutputs({accRegToDB, accRegToSB}), 
        .busReadEnable(flags[LOAD_ACC]), 
        .busWriteEnable({flags[SET_DB_TO_ACC], flags[SET_SB_TO_ACC]})
    );

    //DOR Register
    register #(
        .INPUT_COUNT(2'd1), 
        .OUTPUT_COUNT(2'd1),
        .DEFAULT_VALUE(8'0)
    ) dorRegister (
        .nrst(nrst),
        .clk(clk), 
        .busInputs(dataBus), 
        .busOutputs(dorRegToExternalDB), 
        .busReadEnable(flags[LOAD_DOR]), 
        .busWriteEnable(1'b1)
    );

    //PC Incrementer
    programCounterLogic pcIncrementor (
        .input_lowbyte(pclRegToPcIncrementer), 
        .input_highbyte(pchRegToPcIncrementer),
        .increment(PC_INC), 
        .decrement(PC_DEC),
        .output_lowbyte(pcIncrementerToPclReg), 
        .output_highbyte(pcIncrementerToPchReg)
    );

    //ADL/ADH Incrementor
    programCounterLogic adlADHIncrementor (
        .input_lowbyte(addressHighBus), 
        .input_highbyte(addressHighBus),
        .increment(PC_INC), 
        .decrement(PC_DEC),
        .output_lowbyte(adlADHIncrementerToPclReg), 
        .output_highbyte(adlADHIncrementerToPchReg)
    );

    //ALU
    ALU alu(
        .DB_input(dataBus),
        .ADL_input(addressLowBus),
        .SB_input(stackBus),
        .ldb_inv_db(flags[SET_INPUT_B_TO_NOT_DB]),
        .ldb_db(flags[SET_INPUT_B_TO_DB]),
        .ldb_adl(flags[SET_INPUT_B_TO_ADL]),
        .lda_sb(flags[SET_INPUT_A_TO_SB]),
        .lda_zero(flags[SET_INPUT_A_TO_LOW]),
        .enable_dec(flags[SET_ALU_DEC_TO_PSR_DEC]),
        .carry_in(flags[SET_ALU_CARRY_HIGH]),
        .e_sum(flags[ALU_ADD]),
        .e_and(flags[ALU_AND]),
        .e_eor(flags[ALU_XOR]),
        .e_or(flags[ALU_OR]),
        .e_shiftr(flags[ALU_R_SHIFT]),
        .carry_out(aluCarryOut),
        .overflow(aluOverflowOut),
        .alu_out(aluOutput)
    );

    //SB/ADH Bridge

    //SB/DB Bridge

endmodule