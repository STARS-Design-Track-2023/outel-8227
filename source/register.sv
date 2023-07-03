//If multiple read signals are high, then the output is the largest indexed signal.  Default->low
module register
#(
  parameter INPUT_COUNT = 1,
  parameter OUTPUT_COUNT = 0,
  parameter WIDTH = 8,
  parameter DEFAULT_VALUE = {WIDTH{1'b0}},
  parameter INPUT_BIT_COUNT = WIDTH*INPUT_COUNT,
  parameter OUTPUT_BIT_COUNT = WIDTH*OUTPUT_COUNT
)
(
  input logic nrst, clk,
  input logic [INPUT_BIT_COUNT-1:0] busInputs, //Create 'input_count' bytes for input
  output logic [OUTPUT_BIT_COUNT-1:0] busOutputs, //Create 'output_count' bytes for output
  input logic [INPUT_COUNT-1:0] busReadEnable //create enable signals for each input
  // input logic [OUTPUT_COUNT-1:0] busWriteEnable //create enable signals for each output
);

  parameter BUS_SELECT_ENCODED_SIZE = (INPUT_COUNT > 1)?$clog2(INPUT_COUNT):1;
  logic [7:0] currentState, nextState;
  
  logic [7:0] muxOutput;

  //Index of bus to pull from input list
  logic [BUS_SELECT_ENCODED_SIZE-1:0] busSelectEncoded;

  //One hot encoder - takes a signal like [01000] and turns it into [011] (three)
  oneHotEncoder #(.INPUT_COUNT(INPUT_COUNT)) encoder (.select(busReadEnable), .encodedSelect(busSelectEncoded));

  logic [WIDTH - 1:0] busOutputUnpacked [INPUT_COUNT];

  genvar i;
  generate // Unpack array
    for (i = 0; i < INPUT_COUNT; i = i + 1) begin
      assign busOutputUnpacked[i] = busInputs[WIDTH*(i+1) - 1:WIDTH*i];
    end
  endgenerate

  assign muxOutput = busOutputUnpacked[busSelectEncoded];
  
  always_ff @(posedge clk, negedge nrst) begin
    if(~nrst)
    begin
      currentState <= DEFAULT_VALUE;
    end
    else
    begin
      currentState <= nextState;
    end
  end

  //if the bus is supposed to read a signal, then input the signal
  always_comb begin
    if(|busReadEnable)
      nextState = muxOutput;
    else
      nextState = currentState;
  end

  assign busOutputs = {OUTPUT_COUNT{currentState}};

endmodule

////////////////////////////////////////////////////////////////////
/////////////////////OLD IMPLEMENTATION/////////////////////////////
////////////////////////////////////////////////////////////////////

  //This stores the bits that are supposed to write to the register (everything else is zero)
  // logic [INPUT_BIT_COUNT-1:0] filteredBytes;//[a0,a1,a2,...a7,b0,b1,b2,...b7,...] where a is one input, b is another,...

  // //To join the inputs together generally, the following array will contain {[a0, a1, ... a7], [a0+b0..., a1+b1..., ... a7+b7...], [a0+b0+c0..., a1+b1+c1..., ... a7+b7+c7...]}
  // logic [INPUT_BIT_COUNT-1:0] accumulatedBytes;
  

// //Generate the input busInterfaces
  // generate
  //   for(genvar i = 0; i < INPUT_COUNT; i++)
  //   begin
  //     //i=0 -> first 8 bits
  //     //i=1 -> second 8 bits
  //     //...
  //     //One for each input signal
  //     busInterface busInterface(.interfaceInput(busInputs[8*(i+1)-1:8*i]), .enable(busReadEnable[i]), .interfaceOutput(filteredBytes[8*(i+1)-1:8*i]));
  //   end
  // endgenerate


  // //Set accumulatedBytes;
  // assign accumulatedBytes[7:0] = filteredBytes[7:0];//Initial condition/base case [a0,a1,a2,...,a7]
  // generate
  //   //Recursive Step to fill readBytes
  //   for(genvar i = 1; i < INPUT_COUNT; i++)
  //   begin
  //     //assign the i'th byte of accumulatedBytes to be the previous byte of accumulatedBytes ORed with the i'th byte of the filtered inputs
  //     assign accumulatedBytes[8*(i+1)-1:8*i] = accumulatedBytes[8*(i)-1:8*(i-1)] | filteredBytes[8*(i+1)-1:8*i];
  //   end
  // endgenerate

  // //Set muxOutput to be the final byte of accumulatedBytes
  // assign muxOutput = accumulatedBytes[8*(INPUT_COUNT)-1:8*(INPUT_COUNT)-8];

  //Update the current state on the clock edge or the reset signal

  //   always_ff @(posedge clk, negedge nrst) begin
  //   if(~nrst)
  //   begin
  //     currentState <= DEFAULT_VALUE;
  //   end
  //   else
  //   begin
  //     currentState <= nextState;
  //   end
  // end

  // //if the bus is supposed to read a signal, then input the signal
  // always_comb begin
  //   if(|busReadEnable)
  //     nextState = muxOutput;
  //   else
  //     nextState = currentState;
  // end

  //Generate the output busInterfaces
  // generate
  //   for(genvar i = 0; i < OUTPUT_COUNT; i++)
  //   begin
  //     //i=0 -> first 8 bits -> [7:0]
  //     //i=1 -> second 8 bits -> [15:8]
  //     //...
  //     //One for each input signal
  //     busInterface busInterface(.interfaceInput(currentState), .enable(busWriteEnable[i]), .interfaceOutput(busOutputs[8*(i+1)-1:8*i]));
  //   end
  // endgenerate






