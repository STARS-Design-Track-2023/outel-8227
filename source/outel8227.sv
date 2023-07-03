`default_nettype none
module outel8227 (
    // HW
    input logic clk, nrst,
    
    // Wrapper
    input logic cs, // Chip Select (Active Low) NOT USED
    input logic [7:0] dataBusIn,
    output logic [7:0] dataBusOut,
    output logic dataBusSelect, //The databus should be writing when this is low INTERNAL SIGNAL TO BE USED BY TAs
    inout logic [25:0] gpio // Breakout Board Pins
);

  top8227 top8227 (
    .clk(clk),
    .nrst(nrst),
    .nonMaskableInterrupt(gpio[16]), //Active Low
    .interruptRequest(gpio[17]), //Active Low
    .dataBusEnable(gpio[18]),
    .ready(gpio[19]),
    .setOverflow(gpio[20]),
    .dataBusInput(dataBusIn),
    .dataBusOutput(dataBusOut),
    .addressBusHigh(gpio[15:8]),
    .addressBusLow(gpio[7:0]),
    .sync(gpio[21]),
    .readNotWrite(gpio[22]),
    .functionalClockOut(gpio[24]),// this is set by: assign functionalClockOut = slow_pulse & clk; IS THIS OKAY??
    .dataBusSelect(dataBusSelect)
  );

  assign gpio[23] = clk; //10MHz ClockOut

endmodule
