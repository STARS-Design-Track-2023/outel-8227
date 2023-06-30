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
`define RAM_MEMORY_MAP 16'b0000_000?_????_????
`define ROM_MEMORY_MAP 16'b1111_111?_????_????

`define RAM_CS 1
`define ROM_CS 2

`define ROM_FILE_NAME "source/program.mem"

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

  //assign {ss7[7], ss6[7], ss5[7], ss4[7], ss3[7], ss2[7], ss1[7], ss0[7]} = dataBusOut;
  assign left = addressBusHigh;
  assign right = addressBusLow;

  assign clk = pb[16]; 
  assign nrst = ~reset;
  assign nmi = 1'b0;
  assign irq = 1'b0;
  assign dbe = 1'b0;
  assign rdy = 1'b1;
  assign sv = 1'b0;
  assign red = sync;

  //assign {ss7[0], ss6[0], ss5[0], ss4[0], ss3[0], ss2[0], ss1[0], ss0[0]} = dataBusIn;

  top8227 top8227 (
    .clk(hwclk),
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
    .debug(),
    .debug2(),
    .debugRed()
  );

  

  fpga_seven_seg_driver fpga_seven_seg_driver
  (
    .clk(hwclk),
    .nrst(nrst),
    .writeEnable(~rnw),
    .addressbusHigh(addressBusHigh), 
    .addressbusLow(addressBusLow),
    .databus(dataBusOut),
    .ss0(ss0), 
    .ss1(ss1), 
    .ss2(ss2), 
    .ss3(ss3), 
    .ss4(ss4), 
    .ss5(ss5), 
    .ss6(ss6), 
    .ss7(ss7) 
  );

  demo_mapped_io memory(
    hwclk, 
    {addressBusHigh, addressBusLow},
    dataBusIn,
    rnw,
    dataBusOut
  );
    
endmodule



module demo_mapped_io (
    input logic clk,
    input logic [15:0] addr,
    input logic [7:0] din,
    input logic read_en,
    output logic [7:0] dout
);

  logic [1:0] cs; // Chip select
  logic [7:0] ram_dout, rom_dout;

  ram ram (
      .clk(clk),
      .din(din),
      .addr(addr[8:0]),
      .write_en(~read_en && (cs == `RAM_CS)),
      .dout(ram_dout)
  );

  rom rom (
      .clk(clk),
      .data(rom_dout),
      .addr(addr[8:0])
  );

  always_comb begin
    casez (addr)
      `RAM_MEMORY_MAP: cs = `RAM_CS;
      `ROM_MEMORY_MAP: cs = `ROM_CS;
      default: cs = 0;
    endcase
  end

  always_comb begin
    casez (cs)
      `RAM_CS: dout = ram_dout;
      `ROM_CS: dout = rom_dout;
      default: dout = 0;
    endcase
  end
    
endmodule

module ram (din, addr, write_en, clk, dout); // 512x8
  parameter addr_width = 9;
  parameter data_width = 8;
  input [addr_width-1:0] addr;
  input [data_width-1:0] din;
  input write_en, clk;
  output [data_width-1:0] dout;

  reg [data_width-1:0] dout; // Register for output.
  reg [data_width-1:0] mem [(1<<addr_width)-1:0];
  always @(posedge clk)
  begin
    if (write_en)
    mem[(addr)] <= din;
    dout = mem[addr]; // Output register controlled by clock.
  end
endmodule

module rom (
  input clk,
  input [8:0] addr,
  output reg [7:0] data
);
    
  reg [7:0] Rom [511:0];
  initial $readmemh(`ROM_FILE_NAME, Rom);

  always @(posedge clk)
      data <= Rom[addr];
endmodule

// //Memory Select (only 01 and 00 can be written to and overlap)
//   always_comb begin : memory_select
//     if(rnw)
//     begin
//       if(addressBusHigh > 8'H7F)
//       begin
//         dataBusIn = romOut;
//       end
//       else
//         dataBusIn = ramOut;//Note that all these pages overlap and writing will only affect pages 01 and 00
//     end
//     else
//     begin
//       dataBusIn = 8'H00;
//     end
//   end


//   //assign ramOut = 8'H00;
//   logic [127:0] ram, ramNext;
//   always_comb begin : RAM
//     ramNext = ram;
//     if(~rnw)
//     begin
//       //If writing, only write to the zero page and 1st page
//       if(addressBusHigh == 8'H00 || addressBusHigh == 8'H01)
//         ramNext[8*addressBusLow[3:0]+:8] = dataBusOut;
//     end
//   end

//   // If we are writing, the memory doesn't need to appear until the next clock cycle
//   always_ff @(posedge clk, negedge nrst) begin : RAM_next_state
//     if(~nrst)
//       ram <= 128'b0;
//     else
//       begin
//         ram <= ramNext;
//       end
//   end

//   //Set ramOut (01 and 00 pages will overlap)
//   assign ramOut = ram[8*addressBusLow[3:0]+:8] & {8{rnw}};//only set if reading

//   //Set RomOut
//   always_comb begin : RomOut
//     if(rnw)
//     begin
//       case({addressBusHigh, addressBusLow})
//         16'HFFFC: romOut = 8'H00;//ADL
//         16'HFFFD: romOut = 8'HFF;//ADH

//         16'HFF00: romOut = 8'HA2;
//         16'HFF01: romOut = 8'H00;
//         16'HFF02: romOut = 8'H8A;
//         16'HFF03: romOut = 8'HC9;
//         16'HFF04: romOut = 8'H08;
//         16'HFF05: romOut = 8'H10;
//         16'HFF06: romOut = 8'H06;
//         16'HFF07: romOut = 8'H8A;
//         16'HFF08: romOut = 8'H95;
//         16'HFF09: romOut = 8'H00;
//         16'HFF0A: romOut = 8'HE8;
//         16'HFF0B: romOut = 8'H4C;
//         16'HFF0C: romOut = 8'H03;
//         16'HFF0D: romOut = 8'HFF;
//         16'HFF0E: romOut = 8'H00;
//         16'HFF0F: romOut = 8'H00;

//         default:  romOut = 8'H00;
//       endcase
//     end
//     else
//     begin
//       romOut = 8'H00;
//     end
//   end