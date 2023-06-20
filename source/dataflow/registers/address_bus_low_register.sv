module AddressBusLowRegister
#(
  parameter defaultValue = 8'b0
)
(
  input logic nrst, clk,
  input logic addressBusLowReadEnable,
  input logic [7:0] addressBusLowInput,
  output logic [7:0] externalAddressBusLowOutput
);

logic [7:0] storedValue, nextStoredValue;

always_comb begin : nextStateLogic
  if(addressBusLowReadEnable)
    nextStoredValue = addressBusLowInput;
  else
    nextStoredValue = storedValue;
end

always_ff @( posedge clk, negedge nrst ) begin : flipFlopAssignment
  if(~nrst)
    storedValue = defaultValue;
  else
    storedValue = nextStoredValue;
end

always_comb begin : outputLogic
    externalAddressBusLowOutput = storedValue;
end

endmodule