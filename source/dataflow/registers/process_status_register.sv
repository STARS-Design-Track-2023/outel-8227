module ProcessStatusRegister
#(
  parameter defaultValue = 8'b0
)
(
  input logic nrst, clk,
  input logic dataBusReadEnable, dataBusWriteEnable,
  input logic [7:0] dataBusInput,
  output logic [7:0] dataBusOutput
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
    
    //Write to data bus if enabled
    if(dataBusWriteEnable)
        dataBusOutput = storedValue;
    else
        dataBusOutput = 8'bz;
end

endmodule