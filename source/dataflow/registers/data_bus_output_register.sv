module DataBusOutputRegister
#(
  parameter defaultValue = 8'b0
)
(
  input logic nrst, clk,
  input logic dataBusReadEnable, externalDataBusWriteEnable,
  input logic [7:0] dataBusInput,
  output logic [7:0] externalDataBusOutput
);

logic [7:0] storedValue, nextStoredValue;

always_comb begin : nextStateLogic
    //Read from the data bus if enabled
    if(dataBusReadEnable)
        nextStoredValue = dataBusInput;
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
    
    //Write to external data bus if enabled
    if(externalDataBusWriteEnable)
        externalDataBusOutput = storedValue;
    else
        externalDataBusOutput = 8'bz;
end

endmodule