module timingGenerator (
    input logic clk, rst, passAddressing,
    input logic [2:0] addressTimingCode, opTimingCode,
    output logic [2:0] timeOut,
    output logic isAddressing
);

logic [2:0] negTime, nextTime;

always_comb begin : comb_timingGenerator
    nextTime = 3'b000;
    timeOut = 3'b000;
    if(negTime == 3'b000) begin

        if(isAddressing & ~passAddressing) // passAddressing is needed for functions that don't do addressing
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

always_ff @( posedge clk, negedge rst) begin : ff_start_timingGenerator
    if(rst == 1'b0) 
        isAddressing = 1'b1;
    else if(passAddressing == 1'b1) // needed for passing addressing
        isAddressing = 1'b0;
    else if(negTime == 3'b000)
        isAddressing = ~isAddressing; // transition from addressing to operations and vice versa
end

endmodule

// module exampleAddressing (
//     input logic [2:0] Time,
//     input logic enable,
//     output logic [40:0] flags
// );
// 
// always_comb begin : blockName
//     flag[40:0] = 40'd0;
// 
//     case(Time)
//     010: begin
//     flag[nameofflag] = 1'b1;
//     flag2= 1'b0;
//     flag3 = 1'b1;
//     flag4 = 1'b0;
//     end
// 
//     001: begin
//     flag1 = 1'b0;
//     flag2= 1'b1;
//     flag3 = 1'b0;
//     flag4 = 1'b1;
//     end
//     
//     010: begin
//     flag1 = 1'b0;
//     flag2= 1'b0;
//     flag3 = 1'b1;
//     flag4 = 1'b1;
//     end
//     endcase
// end
// endmodule