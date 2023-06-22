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

  logic nrst;
  assign nrst = ~pb[19];
  logic [7:0] reg1Output;
  logic [7:0] testBusValue;
  
  internalBus #(
    .INPUT_COUNT(2'b1)
  ) testBus (
    .nrst(nrst),
    .clk(hz100),
    .busInputs(reg1Output),
    .busOutput(testBusValue)
  );
  
  register #(
    .INPUT_COUNT(2'd1), 
    .OUTPUT_COUNT(2'd1),
    .DEFAULT_VALUE(8'b10101010)
  ) reg2 (
    .nrst(nrst),
    .clk(hz100), 
    .busInputs(testBusValue), 
    .busOutputs(right), 
    .busReadEnable(pb[16]), 
    .busWriteEnable(1'b1)
  );
  
  register #(
    .INPUT_COUNT(2'd1), 
    .OUTPUT_COUNT(2'd2),
    .DEFAULT_VALUE(8'b10101010)
  ) reg1 (
    .nrst(nrst),
    .clk(hz100), 
    .busInputs(pb[7:0]), 
    .busOutputs({left,reg1Output}), 
    .busReadEnable(pb[18]), 
    .busWriteEnable({1'b1,pb[17]})
  );

endmodule

//If no input is high, then bus will default to zeroes
module internalBus
#(
  parameter INPUT_COUNT = 0,
  parameter INPUT_BIT_COUNT = 8*INPUT_COUNT
)
(
  input logic nrst, clk,
  input logic [INPUT_BIT_COUNT-1:0] busInputs, //Create 'input_count' bytes for input
  output logic [7:0] busOutput //Create 'output_count' bytes for output
);

  //To join the inputs together generally, the following array will contain {[a0, a1, ... a7], [a0+b0..., a1+b1..., ... a7+b7...], [a0+b0+c0..., a1+b1+c1..., ... a7+b7+c7...]}
  logic [INPUT_BIT_COUNT-1:0] accumulatedBytes;

  //Set accumulatedBytes;
  assign accumulatedBytes[7:0] = busInputs[7:0];//Initial condition/base case [a0,a1,a2,...,a7]
  generate
    //Recursive Step to fill readBytes
    for(genvar i = 1; i < INPUT_COUNT; i++)
    begin
      //assign the i'th byte of accumulatedBytes to be the previous byte of accumulatedBytes ORed with the i'th byte of the filtered inputs
      assign accumulatedBytes[8*(i+1)-1:8*i] = accumulatedBytes[8*(i)-1:8*(i-1)] | busInputs[8*(i+1)-1:8*i];
    end
  endgenerate

  //Set muxOutput to be the final byte of accumulatedBytes (if no input is high, then bus is all zeroes)
  assign busOutput = accumulatedBytes[8*(INPUT_COUNT)-1:8*(INPUT_COUNT)-8];
  
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
      interfaceOutput = 8'b0;//These will be 'OR'd together and only assigned if one of the flags is writing
  end
endmodule

//If multiple read signals are high, then the output should be the bitwise OR of the two input buses
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
  input logic [OUTPUT_COUNT-1:0] busWriteEnable //create enable signals for each output
);

  logic [7:0] currentState, nextState;
  
  //This stores the bits that are supposed to write to the register (everything else is zero)
  logic [INPUT_BIT_COUNT-1:0] filteredBytes;//[a0,a1,a2,...a7,b0,b1,b2,...b7,...] where a is one input, b is another,...

  //To join the inputs together generally, the following array will contain {[a0, a1, ... a7], [a0+b0..., a1+b1..., ... a7+b7...], [a0+b0+c0..., a1+b1+c1..., ... a7+b7+c7...]}
  logic [INPUT_BIT_COUNT-1:0] accumulatedBytes;
  
  logic [7:0] muxOutput;
  
  //Generate the input busInterfaces
  generate
    for(genvar i = 0; i < INPUT_COUNT; i++)
    begin
      //i=0 -> first 8 bits
      //i=1 -> second 8 bits
      //...
      //One for each input signal
      busInterface busInterface(.interfaceInput(busInputs[8*(i+1)-1:8*i]), .enable(busReadEnable[i]), .interfaceOutput(filteredBytes[8*(i+1)-1:8*i]));
    end
  endgenerate


  //Set accumulatedBytes;
  assign accumulatedBytes[7:0] = filteredBytes[7:0];//Initial condition/base case [a0,a1,a2,...,a7]
  generate
    //Recursive Step to fill readBytes
    for(genvar i = 1; i < INPUT_COUNT; i++)
    begin
      //assign the i'th byte of accumulatedBytes to be the previous byte of accumulatedBytes ORed with the i'th byte of the filtered inputs
      assign accumulatedBytes[8*(i+1)-1:8*i] = accumulatedBytes[8*(i)-1:8*(i-1)] | filteredBytes[8*(i+1)-1:8*i];
    end
  endgenerate

  //Set muxOutput to be the final byte of accumulatedBytes
  assign muxOutput = accumulatedBytes[8*(INPUT_COUNT)-1:8*(INPUT_COUNT)-8];

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
      nextState = muxOutput;
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