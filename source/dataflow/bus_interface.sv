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