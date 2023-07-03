`default_nettype none

// `include "source/control_logic/state_machine.sv" 
// `include "source/param_file.sv" 

//`include "source/constants.sv"

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

`default_nettype none

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

  logic clk, nrst, nmi, irq, irqNot, dbe, rdy, sv, sync, rnw;
  logic [7:0] addressBusHigh, addressBusLow, dataBusOut, dataBusIn;
  logic [7:0] romOut, ramOut;
  logic dataBusSelect;
  logic functionalClockOut, M10ClkOut;

  assign clk = hwclk; 
  assign nrst = ~reset;
  assign nmi = 1'b1;
  //assign irq = |pb[15:0]; 
  assign dbe = pb[18];
  assign rdy = pb[17];
  assign sv = ~pb[16];

  posEdgeDetector posEdgeDetector (
    .clk(clk),
    .nrst(nrst),
    .in(|pb[15:0]),
    .out(irq)
  );

  assign left[7] = clk;
  assign left[6] = functionalClockOut;

  assign irqNot = ~irq;

  top8227 top8227 (
    .clk(clk),
    .nrst(nrst),
    .nonMaskableInterrupt(nmi),
    .interruptRequest(irqNot),
    .dataBusEnable(dbe),
    .ready(rdy),
    .setOverflow(sv),
    .dataBusInput(dataBusIn),
    .dataBusOutput(dataBusOut),
    .addressBusHigh(addressBusHigh),
    .addressBusLow(addressBusLow),
    .sync(sync),
    .readNotWrite(rnw),
    .functionalClockOut(functionalClockOut),
    .dataBusSelect(dataBusSelect),
    .M10ClkOut(M10ClkOut)
  );

  demo_mapped_io demo_mapped_io (
    .clk(hwclk),
    .nrst(nrst),
    .addr({addressBusHigh, addressBusLow}),
    .din(dataBusOut),
    .read_en(dataBusSelect),
    .dout(dataBusIn),
    .pb(pb),
    .ss0(ss0), 
    .ss1(ss1), 
    .ss2(ss2), 
    .ss3(ss3), 
    .ss4(ss4), 
    .ss5(ss5), 
    .ss6(ss6), 
    .ss7(ss7),
    .left(), 
    .right() 
);
    
endmodule
