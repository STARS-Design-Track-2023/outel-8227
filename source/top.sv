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

  logic clk, nrst, nmi, irq, dbe, rdy, sv, sync, rnw;
  logic [7:0] addressBusHigh, addressBusLow, dataBusOut, dataBusIn;
  logic [7:0] romOut, ramOut;

  assign left = addressBusHigh;
  assign right = addressBusLow; 

  assign clk = hwclk; 
  assign nrst = ~reset;
  assign nmi = 1'b0;
  //assign irq = |pb[15:0]; 
  assign dbe = 1'b0;
  assign rdy = 1'b1;
  assign sv = pb[16];
  assign red = sync;

  edgeDetector edgeDetector (
    .clk(clk),
    .nrst(nrst),
    .in(|pb[15:0]),
    .out(irq)
  );

  top8227 top8227 (
    .clk(clk),
    .nrst(nrst),
    .nonMaskableInterrupt(nmi),
    .interruptRequest(irq),
    .dataBusEnable(dbe),
    .ready(rdy),
    .setOverflow(sv),
    .dataBusInput(dataBusIn),
    .dataBusOutput(dataBusOut),
    .addressBusHigh(addressBusHigh),
    .addressBusLow(addressBusLow),
    .sync(sync),
    .readNotWrite(rnw)
  );

  demo_mapped_io demo_mapped_io (
    .clk(hwclk),
    .nrst(nrst),
    .addr({addressBusHigh, addressBusLow}),
    .din(dataBusOut),
    .read_en(rnw),
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

module edgeDetector (
  input logic clk, nrst,
  input logic in,
  output logic out
);

  logic q1, nextQ1;

  always_comb begin : nextStateLogic
    nextQ1 = in;
  end

  always_ff @( posedge clk, negedge nrst ) begin : nextStateAssignment
    if(~nrst)
    begin
      q1 <= 1'b0;
    end
    else
    begin
      q1 <= nextQ1;

    end
  end

  assign out = ~q1 & in;

endmodule
