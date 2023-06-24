module internalDataflow(
    input logic nrst, clk,
    input logic flags[100:0],
    input logic [7:0] externalDBRead,
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
                aluOutput, aluCarryOut, aluOverflowOut, //Output line from ALU
                psrRegToLogicController, psrRegToDB,//Output from Process Status Register
                dbPresetOutput, sbPresetOutput, adlPresetOutput, adhPresetOutput,//Preset Outputs
                sbToADH, adhToSB,//SB/ADH Bridge Outputs
                sbToDB, dbToSB,//SB/DB Bridge Outputs
                dataToDB, dataToADL, dataToADH;//External DB Interface Outputs

    
    //current bus lines to be used as inputs to registers and other modules
    logic [7:0] dataBusDisconnected, addressLowBus, addressHighBusDisconnected, stackBusDisconnected;
    logic [7:0] dataBus, addressLowBus, addressHighBus, stackBus;

    module bridge(
        .bus1Input(dataBusDisconnected),
        .bus2Input(stackBusDisconnected),
        .bus3Input(addressHighBusDisconnected),
        .bus1Output(dataBus),
        .bus2Output(stackBus),
        .bus3Output(addressHighBus),
        .open2To1(flags[SET_DB_TO_SB]),
        .open1To2(flags[SET_SB_TO_DB]),
        .open2To3(flags[SET_ADH_TO_SB]),
        .open3To2(flags[SET_SB_TO_ADH])
    );
    
    internalBus #(
        .INPUT_COUNT(5)
    ) dataBusModule (
        .nrst(nrst),
        .clk(clk),
        .busInputs({dbPresetOutput, psrRegToDB, pchRegToDB, pclRegToDB, accRegToDB}),
        .busOutput(dataBusDisconnected)
    );

    internalBus #(
        .INPUT_COUNT(4)
    ) addressLowBusModule (
        .nrst(nrst),
        .clk(clk),
        .busInputs({adlPresetOutput, stackPointerRegToADL, aluRegToADL, pclRegToADL}),
        .busOutput(addressLowBus)
    );

    internalBus #(
        .INPUT_COUNT(2)
    ) addressHighBusModule (
        .nrst(nrst),
        .clk(clk),
        .busInputs({adhPresetOutput, pchRegToADH}),
        .busOutput(addressHighBusDisconnected)
    );

    internalBus #(
        .INPUT_COUNT(6)
    ) stackBus (
        .nrst(nrst),
        .clk(clk),
        .busInputs({sbPresetOutput, xRegToSB, yRegToSB, stackPointerRegToSB, aluRegToSB, accRegToSB}),
        .busOutput(stackBusDisconnected)
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

    // Process Status Register
    processStatusRegisterWrapper psr(
        .clk(clk),
        .nrst(nrst),
        .DB_in(dataBus),
        .manual_set(flags[PSR_DATA_TO_LOAD]),
        .carry(aluCarryOut),
        .overflow(aluOverflowOut),
        .DB0_C(flags[SET_PSR_C_TO_DB0]),
        .DB1_Z(flags[SET_PSR_Z_TO_DB1]),
        .DB2_I(flags[SET_PSR_I_TO_DB2]),
        .DB3_D(flags[SET_PSR_D_TO_DB3]),
        .DB6_V(flags[SET_PSR_V_TO_DB6]),
        .DB7_N(flags[SET_PSR_N_TO_DB7]),
        .manual_C(flags[LOAD_CARRY_PSR_FLAG]),
        .manual_I(flags[LOAD_INTERUPT_PSR_FLAG]),
        .manual_D(flags[LOAD_DECIMAL_PSR_FLAG]),
        .carry_C(flags[SET_PSR_CARRY_TO_ALU_CARRY]),
        .DBall_Z(flags[WRITE_ZERO_FLAG]),//NOR databus (equivalent to databus=0)
        .overflow_V(flags[SET_PSR_OVERFLOW_TO_ALU_OVERFLOW]),//Flag to tell PSR to grab overflow from ALU
        .rcl_V(flags[LOAD_OVERFLOW_PSR_FLAG]),//Flag to tell PSR to set overflow high
        .break_set(SET_PSR_OUTPUT_BRK_HIGH),
        .PSR_RCL(psrRegToLogicController),
        .PSR_DB(psrRegToDB),
        .enableDBWrite(flags[SET_DB_TO_PSR])
    );

    //Data Bus Preset
    busPreset dbPreset(
        .set_FF(flags[SET_DB_HIGH]),
        .set_FE(1'b0),
        .set_FD(1'b0),
        .set_FC(1'b0),
        .set_FB(1'b0),
        .set_FA(1'b0),
        .set_00(1'b0),
        .set_01(1'b0),
        .bus_out(dbPresetOutput)
    );

    //Stack Bus Preset
    busPreset sbPreset(
        .set_FF(flags[SET_SB_HIGH]),
        .set_FE(1'b0),
        .set_FD(1'b0),
        .set_FC(1'b0),
        .set_FB(1'b0),
        .set_FA(1'b0),
        .set_00(1'b0),
        .set_01(1'b0),
        .bus_out(sbPresetOutput)
    );

    //ADL Preset
    busPreset adlPreset(
        .set_FF(flags[SET_ADL_FF]),
        .set_FE(flags[SET_ADL_FE]),
        .set_FD(flags[SET_ADL_FD]),
        .set_FC(flags[SET_ADL_FC]),
        .set_FB(flags[SET_ADL_FB]),
        .set_FA(flags[SET_ADL_FA]),
        .set_00(flags[SET_ADL_00]),
        .set_01(1'b0),
        .bus_out(adlPresetOutput)
    );

    //ADH Preset
    busPreset adhPreset(
        .set_FF(flags[SET_ADH_FF]),
        .set_FE(1'b0),
        .set_FD(1'b0),
        .set_FC(1'b0),
        .set_FB(1'b0),
        .set_FA(1'b0),
        .set_00(flags[SET_ADH_00]),
        .set_01(flags[SET_ADL_01]),
        .bus_out(adhPresetOutput)
    );

    //Input Latch to DB
    busInterface externalDBToDB(
        .interfaceInput(externalDBRead),
        .enable(flags[SET_DB_TO_DATA]),
        .interfaceOutput(dataToDB)
    );

    //Input Latch to ADL
    busInterface externalDBToADL(
        .interfaceInput(externalDBRead),
        .enable(flags[SET_ADL_TO_DATA]),
        .interfaceOutput(dataToADL)
    );

    //Input Latch to ADH
    busInterface externalDBToADH(
        .interfaceInput(externalDBRead),
        .enable(flags[SET_ADH_TO_DATA]),
        .interfaceOutput(dataToADH)
    );


endmodule