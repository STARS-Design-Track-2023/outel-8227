`include "registers/accumulator_register.sv"
`include "registers/address_bus_high_register.sv"
`include "registers/address_bus_low_register.sv"
`include "registers/alu_register.sv"
`include "registers/data_bus_outut_register.sv"
`include "registers/process_status_register.sv"
`include "registers/stack_pointer_register.sv"
`include "registers/x_register.sv"
`include "registers/y_register.sv"
`include "../constants.sv"

module internalDataflow(
    input logic nrst, clk,
    input logic flags[40:0],
    output logic [7:0] externalAddressBusLowOutput, externalAddressBusHighOutput
);

    logic [7:0] stackBus, addressBusLow, addressBusHigh, dataBus; //Internal data buses
    logic [7:0] aluToAluReg; //connects the alu to the alu register

    accumulatorRegister accumulatorRegister(.nrst(nrst), .clk(clk));
    addressBusHighRegister addressBusHighRegister(.nrst(nrst), .clk(clk), .addressBusHighReadEnable(flags[LOAD_ABH]), .addressBusHighInput(addressBusHigh), .externalAddressBusHighOutput(externalAddressBusHighOutput));
    addressBusLowRegister addressBusLowRegister(.nrst(nrst), .clk(clk), .addressBusLowReadEnable(flags[LOAD_ABL]), .addressBusLowInput(addressBusLow), .externalAddressBusLowOutput(externalAddressBusLowOutput));
    aluRegister aluRegister(.nrst(nrst), .clk(clk), .aluReadEnable(flags[LOAD_ALU]), .stackBusWriteEnable(flags[SET_SB_TO_ALU]), .addressBusLowWriteEnable(flags[SET_ADL_TO_ALU]), .outputFromCombinationalALU(aluToAluReg), .stackBusOutput(stackBus), .addressBusLowOutput(addressBusLow));
    //dataBusOutputRegister dataBusOutputRegister();
    //processStatusRegister processStatusRegister();
    xRegister xRegister(.nrst(nrst), .clk(clk), .stackBusReadEnable(flags[LOAD_X]), .stackBusWriteEnable(flags[SET_SB_TO_X]), .stackBusInput(stackBus), .stackBusOutput(stackBus));
    yRegister yRegister(.nrst(nrst), .clk(clk), .stackBusReadEnable(flags[LOAD_Y]), .stackBusWriteEnable(flags[SET_SB_TO_Y]), .stackBusInput(stackBus), .stackBusOutput(stackBus));

endmodule