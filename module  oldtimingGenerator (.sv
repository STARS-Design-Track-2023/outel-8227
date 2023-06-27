module timingGenerator (
    input logic clk, rst,
    input logic [2:0] addressTimingCode, opTimingCode,
    output logic [2:0] timeOut,
    output logic isAddressing
);

logic [2:0] negTime, nextTime;

always_comb begin : comb_timingGenerator
    nextTime = 3'b000;
    timeOut = 3'b000;
    if(negTime == 3'b000) begin

        if(isAddressing)
            nextTime = opTimingCode; // goes from addressing to operations
        else
            nextTime = addressTimingCode; // goes from operations to addressing

    end
    else 
        nextTime = negTime - 3'b001; // default behavior, decrements the next time


    if(isAddressing)
        timeOut = addressTimingCode - negTime; // conversion for addressing, adapts to count up behavior
    else
        timeOut = opTimingCode - negTime; // conversion for operations, see above
end

always_ff @( posedge clk, negedge rst ) begin : ff_timingGenerator
        if(rst == 1'b0) begin
            negTime = addressTimingCode;
        end
        else
            negTime = nextTime; // sets the next time
        
end 

always_ff @( posedge clk, negedge rst ) begin : ff_start_timingGenerator
    if(rst == 1'b0) 
        isAddressing = 1'b1;
    else if(negTime == 3'b000)
        isAddressing = ~isAddressing; // transition from addressing to operations and vice versa
end

endmodule