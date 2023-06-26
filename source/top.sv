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
  logic [7:0] psrRegCurrentState;
  logic nrst;
  logic synchronizedLoad, edgeDetectLoad;
  logic synchronizedFinishInterrupt, edgeDetectFinishInterrupt;
  logic [7:0] externalDBRead;
  logic setIFlag;

  assign nrst = ~pb[19];
  assign externalDBRead = 8'b11001010;

  synchronizer loadSync(
    .nrst(nrst),
    .clk(hwclk),
    .in(pb[2]),
    .out(synchronizedLoad)
  ); 

  edgeDetector loadEdgeDetector(
    .clk(hwclk),
    .nrst(nrst),
    .in(synchronizedLoad),
    .out(edgeDetectLoad)
  );

  synchronizer finishInterruptSync(
    .nrst(nrst),
    .clk(hwclk),
    .in(pb[3]),
    .out(synchronizedFinishInterrupt)
  ); 

  edgeDetector finishInterruptEdgeDetector(
    .clk(hwclk),
    .nrst(nrst),
    .in(synchronizedFinishInterrupt),
    .out(edgeDetectFinishInterrupt)
  );

  internalDataflow dataflow(
    .nrst(nrst), 
    .clk(hwclk),
    .flags(flags),
    .externalDBRead(externalDBRead),
    .externalAddressBusLowOutput(),
    .externalAddressBusHighOutput(), 
    .externalDBWrite(),
    .psrRegToLogicController(psrRegCurrentState)
  );

  instructionLoader instructionLoader(
    .clk(hwclk),
    .nrst(nrst),
    .nonMaskableInterrupt(pb[0]),
    .interruptRequest(pb[1]),
    .processStatusRegIFlag(psrRegCurrentState[2]),
    .loadNextInstruction(edgeDetectLoad),
    .externalDB(externalDBRead),
    .currentInstruction(right),
    .enableIFlag(setIFlag),
    .nmiRunning(left[7]),
    .resetRunning(left[6])
  );

  assign flags[SET_PSR_I_TO_DB2] = 1'b0;

  always_comb begin
    if(setIFlag)
    begin
      flags[PSR_DATA_TO_LOAD] = 1'b1;
      flags[LOAD_INTERUPT_PSR_FLAG] = 1'b1;
    end
    else if(edgeDetectFinishInterrupt)
    begin
      flags[PSR_DATA_TO_LOAD] = 1'b0;
      flags[LOAD_INTERUPT_PSR_FLAG] = 1'b1;
    end
    else
    begin
      flags[PSR_DATA_TO_LOAD] = 1'b0;
      flags[LOAD_INTERUPT_PSR_FLAG] = 1'b0;
    end
  end

endmodule