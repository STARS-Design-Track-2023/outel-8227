module AddressBusHighRegister
#(
  parameter defaultValue = 8'b0
)
(
  input logic nrst, clk,
  input logic addressBusHighReadEnable,
  input logic [7:0] addressBusHighInput,
  output logic [7:0] externalAddressBusHighOutput
);

logic [7:0] storedValue, nextStoredValue;

always_comb begin : nextStateLogic
  if(addressBusHighReadEnable)
    nextStoredValue = addressBusHighInput;
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
    externalAddressBusHighOutput = storedValue;
end

endmodule