`default_nettype none
module insert_project_name_here (
    // HW
    input logic clk, nrst,
    
    // Wrapper
    input logic cs, // Chip Select (Active Low)
    inout logic [33:0] gpio // Breakout Board Pins
);

  top8227 top8227(
    .clk(clk), 
    .nrst(nrst), 
    .nonMaskableInterrupt(gpio[33]), 
    .interruptRequest(gpio[32]), 
    .dataBusInput(gpio[31:24]),
    .dataBusOutput(gpio[23:16]),
    .AddressBusHigh(gpio[15:8]),
    .AddressBusLow(gpio[7:0])
  );

endmodule
