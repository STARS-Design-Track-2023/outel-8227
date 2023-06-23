// //If no input is high, then bus will default to zeroes
// module internalBus
// #(
//   parameter INPUT_COUNT = 0,
//   parameter INPUT_BIT_COUNT = 8*INPUT_COUNT
// )
// (
//   input logic [INPUT_BIT_COUNT-1:0] busInputs, //Create 'input_count' bytes for input
//   output logic [7:0] busOutput //Create 'output_count' bytes for output
// );

//   //To join the inputs together generally, the following array will contain {[a0, a1, ... a7], [a0+b0..., a1+b1..., ... a7+b7...], [a0+b0+c0..., a1+b1+c1..., ... a7+b7+c7...]}
//   logic [INPUT_BIT_COUNT-1:0] accumulatedBytes;

//   //Set accumulatedBytes;
//   assign accumulatedBytes[7:0] = busInputs[7:0];//Initial condition/base case [a0,a1,a2,...,a7]
//   generate
//     //Recursive Step to fill readBytes
//     for(genvar i = 1; i < INPUT_COUNT; i++)
//     begin
//       //assign the i'th byte of accumulatedBytes to be the previous byte of accumulatedBytes ORed with the i'th byte of the filtered inputs
//       assign accumulatedBytes[8*(i+1)-1:8*i] = accumulatedBytes[8*(i)-1:8*(i-1)] | busInputs[8*(i+1)-1:8*i];
//     end
//   endgenerate

//   //Set muxOutput to be the final byte of accumulatedBytes (if no input is high, then bus is all zeroes)
//   assign busOutput = accumulatedBytes[8*(INPUT_COUNT)-1:8*(INPUT_COUNT)-8];
  
// endmodule

module internalBus #(
  parameter INPUTS = 2,
  parameter WIDTH = 8
) 
(
  input logic [INPUTS-1:0] busSelect,
  input logic [WIDTH*INPUTS - 1:0] busInputs,
  output logic [WIDTH - 1:0] busOutput
);

  logic [$clog2(INPUTS)-1:0] busSelectEncoded;

  //One hot encoder
  always_comb begin
     busSelectEncoded = 0;
     for (int i = 0; i < WIDTH; i++) begin
       if (busSelect[i])
         busSelectEncoded = i[$clog2(INPUTS)-1:0];
     end
   end

  logic [WIDTH - 1:0] busOutputUnpacked [INPUTS];

  generate // Unpack array
    for (genvar i = 0; i < INPUTS; i = i + 1) begin
      assign busOutputUnpacked[i] = busInputs[WIDTH*(i+1) - 1:WIDTH*i];
    end
  endgenerate

  assign busOutput = busOutputUnpacked[busSelectEncoded];

endmodule
