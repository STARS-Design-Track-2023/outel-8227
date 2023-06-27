`default_nettype none
module insert_project_name_here (
    // HW
    input logic clk, nrst,
    
    // Wrapper
    input logic cs, // Chip Select (Active Low)
    inout logic [33:0] gpio // Breakout Board Pins
);

  top8227 top8227(
    .clk(hwclk), 
    .nrst(~pb[19]), 
    .nonMaskableInterrupt(pb[18]), 
    .interruptRequest(pb[17]), 
    .dataBusInput(pb[7:0]),
    .dataBusOutput({ss7[7], ss6[7], ss5[7], ss4[7], ss3[7], ss2[7], ss1[7], ss0[7]}),
    .AddressBusHigh(left),
    .AddressBusLow(right),
  );

endmodule