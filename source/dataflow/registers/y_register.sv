module yRegister
#(
  parameter defaultValue = 8'b0
)
(
  input logic nrst, clk,
  input logic stackBusReadEnable, stackBusWriteEnable,
  input logic [7:0] stackBusInput,
  output logic [7:0] stackBusOutput
);

logic [7:0] storedValue, nextStoredValue;

always_comb begin : nextStateLogic
  if(stackBusReadEnable)
    nextStoredValue = stackBusInput;
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
  if(stackBusWriteEnable)
    stackBusOutput = storedValue;
else
    stackBusOutput = 8'bz;
end

endmodule