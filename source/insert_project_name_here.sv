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
    .nonMaskableInterrupt(pb[18]), 
    .interruptRequest(gpio[7:0]), 
    .dataBusInput(gpio[7:0]),
    .dataBusOutput(gpio[7:0]),
    .AddressBusHigh(gpio[7:0]),
    .AddressBusLow(gpio[7:0]),
  );

endmodule
