module timingGenerator (
    input logic start, clk,
    input logic [2:0] addressTimingCode, opTimingCode,
    output logic [2:0] TimeOut
);
logic [2:0] nextTime;


always_comb begin : comb_timingGenerator
    
    if(start == 1'b1)          // signal to start timing the Op Code
        nextTime = addressTimingCode;
    else if(timeOut == 3'b000) // start operation timing when the addressing has finished
        nextTime = opTimingCode
    else                       // default behavior. decrement Timeout by one.
        nextTime = TimeOut - 3'b001;
end

always_ff @( posedge clk, negedge rst) begin : ff_timingGenerator
    if(rst == 1'b0) begin
        // DO RESET THINGS: WILL BE ESTABLISHED LATER
    end
    else begin
        timeOut = nextTime;
    end
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