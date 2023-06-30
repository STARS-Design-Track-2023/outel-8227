`default_nettype none
`define RAM_MEMORY_MAP 16'b0000_000?_????_???? // RAM: 0x00 - 0x01
`define ROM_MEMORY_MAP 16'b1111_111?_????_???? // ROM: 0xFE - 0xFF
`define IO_MEMORY_MAP  16'b1000_0000_????_???? // FPGA IO: 0x80 page

`define RAM_CS 1
`define ROM_CS 2
`define IO_CS 3

`define ROM_FILE_NAME "source/demo/program.mem"

module demo_mapped_io (
    input logic clk, nrst,
    input logic [15:0] addr,
    input logic [7:0] din,
    input logic read_en,
    input logic [20:0] pb,
    output logic [7:0] dout,
    output logic [7:0] ss0, 
    output logic [7:0] ss1, 
    output logic [7:0] ss2, 
    output logic [7:0] ss3, 
    output logic [7:0] ss4, 
    output logic [7:0] ss5, 
    output logic [7:0] ss6, 
    output logic [7:0] ss7,
    output logic [7:0] left, 
    output logic [7:0] right 
);

  logic [1:0] cs; // Chip select
  logic [7:0] ram_dout, rom_dout, io_dout;

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

  fpga_io_driver fpga_io_driver (
    .clk(clk), .nrst(nrst),
    .read_en(read_en || cs != `IO_CS),
    .addr(addr[7:0]),
    .din(din),
    .pb(pb),
    .dout(io_dout),
    .ss0(ss0), 
    .ss1(ss1), 
    .ss2(ss2), 
    .ss3(ss3), 
    .ss4(ss4), 
    .ss5(ss5), 
    .ss6(ss6), 
    .ss7(ss7),
    .left(left), 
    .right(right)  
  );
  
  always_comb begin
    casez (addr)
      `RAM_MEMORY_MAP: cs = `RAM_CS;
      `ROM_MEMORY_MAP: cs = `ROM_CS;
      `IO_MEMORY_MAP: cs = `IO_CS;
      default: cs = 0;
    endcase
  end

  always_comb begin
    casez (cs)
      `RAM_CS: dout = ram_dout;
      `ROM_CS: dout = rom_dout;
      `IO_CS: dout = io_dout;
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
