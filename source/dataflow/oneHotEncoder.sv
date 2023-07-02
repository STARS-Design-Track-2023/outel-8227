module oneHotEncoder #(
  parameter INPUT_COUNT = 2,
  parameter OUTPUT_SIZE = ($clog2(INPUT_COUNT) == 0)?1:$clog2(INPUT_COUNT)
)(
  input logic [INPUT_COUNT-1:0] select,
  output logic [OUTPUT_SIZE-1:0] encodedSelect
);  
  genvar i;
  genvar j;
  generate
    //for each of the bits in the output signal
    for(i = 0; i < OUTPUT_SIZE; i++) begin
      //See if the binary representation of any one's in the 
      //select signal belong in the ith bit of the output signal 
      logic[INPUT_COUNT-1:0] temp;
        for(j = 0; j < INPUT_COUNT; j++) begin
          assign temp[j] = select[j]&j[i];
        end
      assign encodedSelect[i] = |temp; //After calculating all the ones,
      //or it together to see if the output should have a high bit
    end
  endgenerate

endmodule
