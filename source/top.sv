`default_nettype none


`include "source/constants.sv"

// `include "source/dataflow/alu.sv"
// `include "source/dataflow/bridge.sv"
// `include "source/dataflow/bus_interface.sv"
// `include "source/dataflow/bus_preset_logic.sv"
// // `include "source/dataflow/bus2.sv"
// `include "source/dataflow/internal_bus.sv"
// `include "source/dataflow/internal_dataflow.sv"
// `include "source/dataflow/process_status_register_wrapper.sv"
// `include "source/dataflow/process_status_register.sv"
// `include "source/dataflow/program_counter_logic.sv"
// `include "source/dataflow/register.sv"

module top 
(
  // I/O ports
  input  logic hwclk, reset,
  input  logic [20:0] pb,
  output logic [7:0] left, right,
         ss7, ss6, ss5, ss4, ss3, ss2, ss1, ss0,
  output logic red, green, blue,

  // UART ports
  output logic [7:0] txdata,
  input  logic [7:0] rxdata,
  output logic txclk, rxclk,
  input  logic txready, rxready
);

  logic [100:0] flags;

  always_comb begin
    flags = 101'b0;

    flags[SET_ADH_TO_DATA] = pb[0];
    flags[LOAD_ABH] = pb[1];
    flags[SET_ADH_FF] = pb[2];

     flags[SET_SB_TO_ADH] = pb[3];
    // flags[LOAD_X] = pb[2];

    // flags[SET_SB_TO_X] = pb[3];
    // flags[LOAD_ACC] = pb[4];
    
    // flags[SET_DB_TO_ACC] = pb[5];
    // flags[LOAD_DOR] = pb[6];
  end

  internalDataflow dataflow(
    .nrst(~pb[19]), 
    .clk(hwclk),
    .flags(flags),
    .externalDBRead(8'b10101010),
    .externalAddressBusLowOutput(),
    .externalAddressBusHighOutput(), 
    .externalDBWrite()
  );

  interruptInjector interruptInjector(
    .clk(hwclk),
    .nrst(~pb[19]),
    .nonMaskableInterrupt(),
    .interruptRequest(), //Inputs from exterior (could be buttons outside IC)
    .processStatusRegIFlag(),
    .interruptAcknowleged(), //Should be high going into the clock cycle when the Instruction Register is loaded
    .irqGenerated(),
    .nmiGenerated(),
    .nmiRunning(),
    .resetRunning() //output signals that state whether an interrupt has been generated and whether a nonmaskable interrupt is running
  );

endmodule