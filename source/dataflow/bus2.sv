//If no input is high, then bus will default to zeroes
module bus2
(
  input logic [15:0] busInputs, //Create 'input_count' bytes for input
  output logic [7:0] busOutput //Create 'output_count' bytes for output
);

  assign busOutput = {
    busInputs[15] | busInputs[7],
    busInputs[14] | busInputs[6],
    busInputs[13] | busInputs[5],
    busInputs[12] | busInputs[4],
    busInputs[11] | busInputs[3],
    busInputs[10] | busInputs[2],
    busInputs[9] | busInputs[1],
    busInputs[8] | busInputs[0]
  };
  
endmodule