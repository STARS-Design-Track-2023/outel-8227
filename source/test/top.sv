`default_nettype none
//`include "source/dataflow/internal_dataflow.sv"
// Empty top module

module top (
  // I/O ports
  input  logic hz100, reset,
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

  register #(
    .INPUT_COUNT(2'd2), 
    .OUTPUT_COUNT(2'd1),
    .DEFAULT_VALUE(8'b11111111)
  ) testRegister(
    .nrst(~pb[19]), .clk(hz100), 
    .busInputs(pb[15:0]), 
    .busOutputs(right), 
    .busReadEnable(pb[18:17]), 
    .busWriteEnable(pb[16]),
    .debug(red)
  );

endmodule


module busInterface(
  input logic [7:0] interfaceInput,
  input logic enable,
  output logic [7:0] interfaceOutput
);
  always_comb begin
    if(enable)
      interfaceOutput = interfaceInput;
    else
      interfaceOutput = 8'bzzzzzzzz;
  end
endmodule


module register
#(
  parameter INPUT_COUNT = 0,
  parameter OUTPUT_COUNT = 0,
  parameter DEFAULT_VALUE = 8'b0,
  parameter INPUT_BIT_COUNT = 8*INPUT_COUNT,
  parameter OUTPUT_BIT_COUNT = 8*OUTPUT_COUNT
)
(
  input logic nrst, clk,
  input logic [INPUT_BIT_COUNT-1:0] busInputs, //Create 'input_count' bytes for input
  output logic [OUTPUT_BIT_COUNT-1:0] busOutputs, //Create 'output_count' bytes for output
  input logic [INPUT_COUNT-1:0] busReadEnable, //create enable signals for each input
  input logic [OUTPUT_COUNT-1:0] busWriteEnable, //create enable signals for each output
  output logic debug
);

  logic [7:0] currentState, nextState;
  logic [7:0] readByte;//This is the byte that every bus interface is reading to. (It kind of acts like one of the internal buses in dataflow)

  //Generate the input busInterfaces
  generate
    for(genvar i = 0; i < INPUT_COUNT; i++)
    begin
      //i=0 -> first 8 bits
      //i=1 -> second 8 bits
      //...
      //One for each input signal
      busInterface busInterface(.interfaceInput(busInputs[8*(i+1)-1:8*i]), .enable(busReadEnable[i]), .interfaceOutput(readByte));
    end
  endgenerate

  //Update the current state on the clock edge or the reset signal
  always_ff @(posedge clk, negedge nrst) begin
    if(~nrst)
    begin
      currentState = DEFAULT_VALUE;
    end
    else
    begin
      currentState = nextState;
    end
  end

  //if the bus is supposed to read a signal, then input the signal
  always_comb begin
    if(|busReadEnable)
      nextState = readByte;
    else
      nextState = currentState;
  end

  //Generate the output busInterfaces
  generate
    for(genvar i = 0; i < OUTPUT_COUNT; i++)
    begin
      //i=0 -> first 8 bits -> [7:0]
      //i=1 -> second 8 bits -> [15:8]
      //...
      //One for each input signal
      busInterface busInterface(.interfaceInput(currentState), .enable(busWriteEnable[i]), .interfaceOutput(busOutputs[8*(i+1)-1:8*i]));
    end
  endgenerate

endmodule
