module XRegister
#(
  parameter defaultValue = 8'b0;
)
(
  input logic nrst, clk,
  input logic readStackBus, stackBusWriteEnable, stackBusInput,
  output logic stackBusOutput
);

logic [7:0] storedValue, nextStoredValue;

always_comb begin : nextStateLogic
  if(readStackBus)
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
    stackBusOutput = 1;
else
    stackBusOutput = z;
end

endmodule