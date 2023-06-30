`default_nettype none
`define RAM_MEMORY_MAP 16'b0000_000?_????_????
`define ROM_MEMORY_MAP 16'b1111_111?_????_????

`define RAM_CS 1
`define ROM_CS 2

`define ROM_FILE_NAME "source/demo/program.mem"

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

// // Character ROM.
// module rom (
//   input logic ROMCLK,// Read clock

//   output logic [7:0] ROM_OUT,// Data output

//   input logic [8:0] ROM_ADDR // Read address
// );// Read enable
	
//   // E paper fonts.
//   reg [7:0] fonts [511:0];// Font bitmap, Inferring to BRAM.

//   initial $readmemh("source/demo/program.bin", fonts);
  
//   // initial begin
//   //   // Write font data to BRAM rom.
//   //   $display("Reading from program file...");
//   //   $readmemh(`, fonts);// read file data from same location of this Verilog file. I used this binary data to initialize the BRAM as a character bitmap ROM.
//   // end

//   always@(posedge ROMCLK) begin
//     ROM_OUT <= fonts[ROM_ADDR];	
//   end	

// endmodule
