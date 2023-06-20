module aluRegister
#(
  parameter defaultValue = 8'b0
)
(
  input logic nrst, clk,
  input logic aluReadEnable, stackBusWriteEnable, addressBusLowWriteEnable,
  input logic [7:0] outputFromCombinationalALU,
  output logic [7:0] stackBusOutput, addressBusLowOutput
);

logic [7:0] storedValue, nextStoredValue;

always_comb begin : nextStateLogic
  if(aluReadEnable)
    nextStoredValue = outputFromCombinationalALU;
  else
    nextStoredValue = storedValue;
end

always_ff @( posedge clk, negedge nrst ) begin : flipFlopAssignment
  if(~nrst)
    storedValue = defaultValue;
  else
    storedValue = nextStoredValue;
end

always_comb begin : outputSelection

  //Write to the stack bus if enabled
  if(stackBusWriteEnable)
    stackBusOutput = storedValue;
  else
    stackBusOutput = 8'bz;

  //write to the ABL if enabled
  if(addressBusLowWriteEnable)
    addressBusLowOutput = storedValue;
  else
    addressBusLowOutput = 8'bz;
end

endmodule