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

  assign {ss7[7], ss6[7], ss5[7], ss4[7], ss3[7], ss2[7], ss1[7], ss0[7]} = dataBusOut;
  //assign left = addressBusHigh;
  //assign right = addressBusLow;

  assign clk = pb[16]; 
  assign nrst = ~reset;
  assign nmi = 1'b0;
  assign irq = 1'b0;
  assign dbe = 1'b0;
  assign rdy = 1'b1;
  assign sv = 1'b0;
  //assign red = sync;
  assign blue = rnw;

  assign {ss7[0], ss6[0], ss5[0], ss4[0], ss3[0], ss2[0], ss1[0], ss0[0]} = dataBusIn;

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
    .readNotWrite(rnw),
    .debug(left),
    .debug2(right)
  );

  //Memory Select (only 01 and 00 can be written to and overlap)
  always_comb begin : memory_select
    if(rnw)
    begin
      if(addressBusHigh > 8'H7F)
      begin
        dataBusIn = romOut;
      end
      else
        dataBusIn = ramOut;//Note that all these pages overlap and writing will only affect pages 01 and 00
    end
    else
    begin
      dataBusIn = 8'H00;
    end
  end

  logic [2047:0] ram, ramNext;
  always_comb begin : RAM
    ramNext = ram;
    red = 1'b0;
    if(~rnw)
    begin
      //If writing, only write to the zero page and 1st page
      if(addressBusHigh == 8'H00 || addressBusHigh == 8'H01)
        ramNext[8*addressBusLow+:8] = dataBusOut;
    end
  end

  // If we are writing, the memory doesn't need to appear until the next clock cycle
  always_ff @(posedge clk, negedge nrst) begin : RAM_next_state
    if(~nrst)
      ram = 2048'b0;
    else
      begin
        ram = ramNext;
      end
  end

  //Set ramOut (01 and 00 pages will overlap)
  assign ramOut = ram[8*addressBusLow+:8] & {8{rnw}};//only set if reading

  //Set RomOut
  always_comb begin : RomOut
    if(rnw)
    begin
      case({addressBusHigh, addressBusLow})
        16'HFFFE: romOut = 8'HFF;
        16'HFFFF: romOut = 8'HFF;
        default:  romOut = 8'H00;
      endcase
    end
    else
    begin
      romOut = 8'H00;
    end
  end
    
endmodule