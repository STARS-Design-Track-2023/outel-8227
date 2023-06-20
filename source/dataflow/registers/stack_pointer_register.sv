module StackPointerRegister
#(
  parameter defaultValue = 8'b0
)
(
  input logic nrst, clk,
  input logic stackBusReadEnable, stackBusWriteEnable, addressBusLowWriteEnable,
  input logic [7:0] stackBusInput,
  output logic [7:0] stackBusOutput, addressBusLowOutput
);

logic [7:0] storedValue, nextStoredValue;

always_comb begin : nextStateLogic
    //Read from the stack bus if enabled
    if(stackBusReadEnable)
        nextStoredValue = stackBusInput;
    else
        nextStoredValue = storedValue;
end

always_ff @( posedge clk, negedge nrst ) begin : flipFlopAssignment
  //Either pass in the default value or the value selected by the MUX
  if(~nrst)
    storedValue = defaultValue;
  else
    storedValue = nextStoredValue;
end

always_comb begin : outputSelection
    
    //Write to stack bus if enabled
    if(stackBusWriteEnable)
        stackBusOutput = storedValue;
    else
        stackBusOutput = 8'bz;

    //Write to ABL if enabled
    if(addressBusLowWriteEnable)
        addressBusLowOutput = storedValue;
    else
        addressBusLowOutput = 8'bz;
end

endmodule