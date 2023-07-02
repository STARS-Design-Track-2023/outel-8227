`ifndef NUMFLAGS
`include "source/param_file.sv"
`endif
module internalDataflow(
    input logic nrst, clk,
    input logic freeCarry, psrCarry,
    input logic setOverflow,
    input logic [`NUMFLAGS-1:0] flags,
    input logic [7:0] externalDBRead,
    input logic load_psr_I, psr_data_to_load,
    output logic [7:0] externalDBWrite,
    output logic [7:0] externalAddressBusLowOutput, externalAddressBusHighOutput,
    output logic [7:0] psrRegToLogicController,
    output logic aluCarryOut,
    output logic pclMSB,
    input logic initiateInterruptWithPCDecrement
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
                pcIncrementerToPchReg, pcIncrementerToPclReg,//PCIncrementer Outputs
                adlADHIncrementerToPchReg, adlADHIncrementerToPclReg,//PCIncrementer Outputs from the ADH,ADL lines
                aluOutput, //Output line from ALU
                psrRegToDB,//Output from Process Status Register
                dbPresetOutput, sbPresetOutput, adlPresetOutput, adhPresetOutput;//Preset Outputs

    assign pclMSB = pclRegToDB[7];//Assign this to the MSB of the PCL's current value to pass to control logic

    logic aluOverflowOut;

    logic dbPresetWriteEnable, adhPresetWriteEnable, adlPresetWriteEnable, sbPresetWriteEnable;

    assign externalDBWrite = dorRegToExternalDB;
    assign externalAddressBusLowOutput = ablRegToExternalADL;
    assign externalAddressBusHighOutput = abhRegToExternalADH;

    //current bus lines to be used as inputs to registers and other modules
    logic [7:0] dataBusDisconnected, addressLowBus, addressHighBusDisconnected, stackBusDisconnected;
    logic [7:0] dataBus, addressHighBus, stackBus;

    bridge bridge(
        .bus1Input(dataBusDisconnected),
        .bus2Input(stackBusDisconnected),
        .bus3Input(addressHighBusDisconnected),
        .bus1Output(dataBus),
        .bus2Output(stackBus),
        .bus3Output(addressHighBus),
        .open2To1(flags[`SET_DB_TO_SB]),
        .open1To2(flags[`SET_SB_TO_DB]),
        .open2To3(flags[`SET_ADH_TO_SB]),
        .open3To2(flags[`SET_SB_TO_ADH])
    );
    
    internalBus #(
        .INPUT_COUNT(6)
    ) dataBusModule (
        .busSelect({flags[`SET_DB_TO_PSR], flags[`SET_DB_TO_PCH], flags[`SET_DB_TO_PCL], flags[`SET_DB_TO_ACC], flags[`SET_DB_TO_DATA], dbPresetWriteEnable}),
        .busInputs({psrRegToDB, pchRegToDB, pclRegToDB, accRegToDB, externalDBRead, dbPresetOutput}),
        .busOutput(dataBusDisconnected)
    );

    internalBus #(
        .INPUT_COUNT(5)
    ) addressLowBusModule (
        .busSelect({flags[`SET_ADL_TO_SP], flags[`SET_ADL_TO_ALU], flags[`SET_ADL_TO_PCL], flags[`SET_ADL_TO_DATA], adlPresetWriteEnable}),
        .busInputs({stackPointerRegToADL, aluRegToADL, pclRegToADL, externalDBRead, adlPresetOutput}),
        .busOutput(addressLowBus)
    );

    internalBus #(
        .INPUT_COUNT(3)
    ) addressHighBusModule (
        .busSelect({flags[`SET_ADH_TO_PCH], flags[`SET_ADH_TO_DATA], adhPresetWriteEnable}),
        .busInputs({pchRegToADH, externalDBRead, adhPresetOutput}),
        .busOutput(addressHighBusDisconnected)
    );

    internalBus #(
        .INPUT_COUNT(6)
    ) stackBusModule (
        .busSelect({flags[`SET_SB_TO_X], flags[`SET_SB_TO_Y], flags[`SET_SB_TO_SP], flags[`SET_SB_TO_ALU], flags[`SET_SB_TO_ACC], sbPresetWriteEnable}),
        .busInputs({xRegToSB, yRegToSB, stackPointerRegToSB, aluRegToSB, accRegToSB, sbPresetOutput}),
        .busOutput(stackBusDisconnected)
    );

    //X Register
    register #(
        .INPUT_COUNT(1), 
        .OUTPUT_COUNT(1),
        .DEFAULT_VALUE(8'b0)
    ) xRegister (
        .nrst(nrst),
        .clk(clk), 
        .busInputs(stackBus), 
        .busOutputs(xRegToSB), 
        .busReadEnable(flags[`LOAD_X])
    );

    //Y Register
    register #(
        .INPUT_COUNT(1), 
        .OUTPUT_COUNT(1),
        .DEFAULT_VALUE(8'b0)
    ) yRegister (
        .nrst(nrst),
        .clk(clk), 
        .busInputs(stackBus), 
        .busOutputs(yRegToSB), 
        .busReadEnable(flags[`LOAD_Y])
    );

    //ABH Register
    register #(
        .INPUT_COUNT(1), 
        .OUTPUT_COUNT(1),
        .DEFAULT_VALUE(0)
    ) abhRegister (
        .nrst(nrst),
        .clk(clk), 
        .busInputs(addressHighBus), 
        .busOutputs(abhRegToExternalADH), 
        .busReadEnable(flags[`LOAD_ABH])
    );

    //ABL Register
    register #(
        .INPUT_COUNT(1), 
        .OUTPUT_COUNT(1),
        .DEFAULT_VALUE(0)
    ) ablRegister (
        .nrst(nrst),
        .clk(clk), 
        .busInputs(addressLowBus), 
        .busOutputs(ablRegToExternalADL), 
        .busReadEnable(flags[`LOAD_ABL])
    );

    //PCH Register
    register #(
        .INPUT_COUNT(2), 
        .OUTPUT_COUNT(3),
        .DEFAULT_VALUE(8'H00)
    ) pchRegister (
        .nrst(nrst),
        .clk(clk), 
        .busInputs({pcIncrementerToPchReg, adlADHIncrementerToPchReg}), 
        .busOutputs({pchRegToADH, pchRegToDB, pchRegToPcIncrementer}), 
        .busReadEnable({~flags[`LOAD_PC], flags[`LOAD_PC]}) //If load_pc is high, load from ADL/ADH, else load from PC
    );

    //PCL Register
    register #(
        .INPUT_COUNT(2), 
        .OUTPUT_COUNT(3),
        .DEFAULT_VALUE(8'H00)
    ) pclRegister (
        .nrst(nrst),
        .clk(clk), 
        .busInputs({pcIncrementerToPclReg, adlADHIncrementerToPclReg}), 
        .busOutputs({pclRegToADL, pclRegToDB, pclRegToPcIncrementer}), 
        .busReadEnable({~flags[`LOAD_PC], flags[`LOAD_PC]}) //If load_pc is high, load from ADL/ADH, else load from PC
    );

    //Stack Pointer Register
    register #(
        .INPUT_COUNT(1), 
        .OUTPUT_COUNT(2),
        .DEFAULT_VALUE(0)
    ) stackPointerRegister (
        .nrst(nrst),
        .clk(clk), 
        .busInputs(stackBus), 
        .busOutputs({stackPointerRegToSB,stackPointerRegToADL}), 
        .busReadEnable(flags[`LOAD_SP])
    );

    //ALU Register
    register #(
        .INPUT_COUNT(1), 
        .OUTPUT_COUNT(2),
        .DEFAULT_VALUE(0)
    ) aluRegister (
        .nrst(nrst),
        .clk(clk), 
        .busInputs(aluOutput), 
        .busOutputs({aluRegToADL, aluRegToSB}), 
        .busReadEnable(flags[`LOAD_ALU])
    );

    //Accumulator Register
    register #(
        .INPUT_COUNT(1), 
        .OUTPUT_COUNT(2),
        .DEFAULT_VALUE(0)
    ) accumulatorRegister (
        .nrst(nrst),
        .clk(clk), 
        .busInputs(stackBus), 
        .busOutputs({accRegToDB, accRegToSB}), 
        .busReadEnable(flags[`LOAD_ACC])
    );

    //DOR Register
    register #(
        .INPUT_COUNT(1), 
        .OUTPUT_COUNT(1),
        .DEFAULT_VALUE(0)
    ) dorRegister (
        .nrst(nrst),
        .clk(clk), 
        .busInputs(dataBus), 
        .busOutputs(dorRegToExternalDB), 
        .busReadEnable(flags[`LOAD_DOR])
    );

    //PC Incrementer
    programCounterLogic pcIncrementor (
        .input_lowbyte(pclRegToPcIncrementer), 
        .input_highbyte(pchRegToPcIncrementer),
        .increment(flags[`PC_INC] & ~initiateInterruptWithPCDecrement), 
        .decrement(flags[`PC_DEC] | initiateInterruptWithPCDecrement),
        .output_lowbyte(pcIncrementerToPclReg), 
        .output_highbyte(pcIncrementerToPchReg)
    );

    //ADL/ADH Incrementor
    programCounterLogic adlADHIncrementor (
        .input_lowbyte(addressLowBus), 
        .input_highbyte(addressHighBus),
        .increment(flags[`PC_INC] & ~initiateInterruptWithPCDecrement), 
        .decrement(flags[`PC_DEC] | initiateInterruptWithPCDecrement),
        .output_lowbyte(adlADHIncrementerToPclReg), 
        .output_highbyte(adlADHIncrementerToPchReg)
    );

    //ALU
    alu alu(
        .DB_input(dataBus),
        .ADL_input(addressLowBus),
        .SB_input(stackBus),
        .ldb_inv_db(flags[`SET_INPUT_B_TO_NOT_DB]),
        .ldb_db(flags[`SET_INPUT_B_TO_DB]),
        .ldb_adl(flags[`SET_INPUT_B_TO_ADL]),
        .lda_sb(flags[`SET_INPUT_A_TO_SB]),
        .lda_zero(flags[`SET_INPUT_A_TO_LOW]),
        .enable_dec(flags[`SET_ALU_DEC_TO_PSR_DEC] & psrRegToLogicController[3]),
        .carry_in(flags[`SET_ALU_CARRY_HIGH] | (flags[`SET_ALU_CARRY_TO_FREE_CARRY] & freeCarry) | (flags[`SET_ALU_CARRY_TO_PSR_CARRY] & psrCarry)),
        .e_sum(flags[`ALU_ADD]),
        .e_and(flags[`ALU_AND]),
        .e_eor(flags[`ALU_XOR]),
        .e_or(flags[`ALU_OR]),
        .e_shiftr(flags[`ALU_R_SHIFT]),
        .carry_out(aluCarryOut),
        .overflow(aluOverflowOut),
        .alu_out(aluOutput),
        .subtracting(flags[`SET_ALU_DEC_TO_PSR_DEC]&flags[`SET_INPUT_B_TO_NOT_DB])
    );
    // Process Status Register
    processStatusRegisterWrapper psr(
        .clk(clk),
        .nrst(nrst),
        .DB_in(dataBus),
        .manual_set(flags[`PSR_DATA_TO_LOAD] | psr_data_to_load),
        .carry(aluCarryOut),
        .overflow(aluOverflowOut),
        .DB0_C(flags[`SET_PSR_C_TO_DB0] | flags[`SET_PSR_TO_DB]),
        .DB1_Z(flags[`SET_PSR_Z_TO_DB1] | flags[`SET_PSR_TO_DB]),
        .DB2_I(flags[`SET_PSR_I_TO_DB2] | flags[`SET_PSR_TO_DB]),
        .DB3_D(flags[`SET_PSR_D_TO_DB3] | flags[`SET_PSR_TO_DB]),
        .DB6_V(flags[`SET_PSR_V_TO_DB6] | flags[`SET_PSR_TO_DB]),
        .DB7_N(flags[`SET_PSR_N_TO_DB7] | flags[`SET_PSR_TO_DB]),
        .manual_C(flags[`LOAD_CARRY_PSR_FLAG]),
        .manual_I(flags[`LOAD_INTERUPT_PSR_FLAG]),
        .man_I(load_psr_I),
        .manual_D(flags[`LOAD_DECIMAL_PSR_FLAG]),
        .carry_C(flags[`SET_PSR_CARRY_TO_ALU_CARRY]),
        .DBall_Z(flags[`WRITE_ZERO_FLAG]),//NOR databus (equivalent to databus=0)
        .overflow_V(flags[`SET_PSR_OVERFLOW_TO_ALU_OVERFLOW]),//Flag to tell PSR to grab overflow from ALU
        .rcl_V(flags[`LOAD_OVERFLOW_PSR_FLAG]),//Flag to tell PSR to set overflow high
        .break_set(flags[`SET_PSR_OUTPUT_BRK_HIGH]),
        .PSR_RCL(psrRegToLogicController),
        .PSR_DB(psrRegToDB),
        .setOverflow(setOverflow)
    );

    //Data Bus Preset
    busPreset dbPreset(
        .set_FF(flags[`SET_DB_HIGH]),
        .set_FE(1'b0),
        .set_FD(1'b0),
        .set_FC(1'b0),
        .set_FB(1'b0),
        .set_FA(1'b0),
        .set_00(1'b0),
        .set_01(1'b0),
        .bus_out(dbPresetOutput)
    );
    assign dbPresetWriteEnable = flags[`SET_DB_HIGH];


    //Stack Bus Preset
    busPreset sbPreset(
        .set_FF(flags[`SET_SB_HIGH]),
        .set_FE(1'b0),
        .set_FD(1'b0),
        .set_FC(1'b0),
        .set_FB(1'b0),
        .set_FA(1'b0),
        .set_00(1'b0),
        .set_01(1'b0),
        .bus_out(sbPresetOutput)
    );
    assign sbPresetWriteEnable = flags[`SET_SB_HIGH];

    //ADL Preset
    busPreset adlPreset(
        .set_FF(flags[`SET_ADL_FF]),
        .set_FE(flags[`SET_ADL_FE]),
        .set_FD(flags[`SET_ADL_FD]),
        .set_FC(flags[`SET_ADL_FC]),
        .set_FB(flags[`SET_ADL_FB]),
        .set_FA(flags[`SET_ADL_FA]),
        .set_00(flags[`SET_ADL_00]),
        .set_01(1'b0),
        .bus_out(adlPresetOutput)
    );
    assign adlPresetWriteEnable =   flags[`SET_ADL_FF] | flags[`SET_ADL_FE] | flags[`SET_ADL_FD] | 
                                    flags[`SET_ADL_FC] | flags[`SET_ADL_FB] | flags[`SET_ADL_FA] | 
                                    flags[`SET_ADL_00];

    //ADH Preset
    busPreset adhPreset(
        .set_FF(flags[`SET_ADH_FF]),
        .set_FE(1'b0),
        .set_FD(1'b0),
        .set_FC(1'b0),
        .set_FB(1'b0),
        .set_FA(1'b0),
        .set_00(flags[`SET_ADH_LOW]),
        .set_01(flags[`SET_ADH_TO_ONE]),
        .bus_out(adhPresetOutput)
    );
    assign adhPresetWriteEnable = flags[`SET_ADH_FF] | flags[`SET_ADH_LOW] | flags[`SET_ADH_TO_ONE];

endmodule
