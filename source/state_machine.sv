parameter A0 = 2'b00;
parameter A1 = 2'b01;
parameter A2 = 2'b10;
parameter A3 = 2'b11;

parameter T0 = 3'b000;
parameter T1 = 3'b001;
parameter T2 = 3'b010;
parameter T3 = 3'b011;
parameter T4 = 3'b100;
parameter T5 = 3'b101;
parameter T6 = 3'b110; // DONT FORGET TO REPLACE THIS WITH A #include param_file in the future

parameter INSTRUCTION = 1'b1;
parameter ADDRESS= 1'b0;

module newTimingGenerator(
input logic clk, rst, noAddressing, getInstruction, endAddressing,
input logic [5:0] decodedInstruction,
input logic [3:0] decodedAddress,
output logic [5:0] currentInstruction,
output logic [3:0] currentAddress,
output logic [2:0] timeState,
output logic mode
);

logic nextMode;
logic [2:0] nextTime;
always_comb begin : comb_timingGeneration
    if(endAddressing | noAddressing) begin // it is on the last stage of addressing
        nextMode = INSTRUCTION;
        nextTime = T0;
    end
    else if(getInstruction) begin // it is on the last stage of the instruction
        nextMode = ADDRESS; 
        nextTime = T0;
    end
    else begin
        nextMode = mode; // default behavior, remains in the loop

        case(timeState) // state machine proper, increases until it hits the max time in the instruction then resets
        T0: nextTime = T1;
        T1: nextTime = T2;
        T2: nextTime = T3;
        T3: nextTime = T4;
        T4: nextTime = T5;
        T5: nextTime = T6;
        default: nextTime = T0;
        endcase
    end

end

logic [5:0] nextInstruction;
logic [3:0] nextAddress;
always_comb begin : comb_OPCode

    if(getInstruction) begin
        nextInstruction = decodedInstruction; // code that is an input from the decoder, decoder runs continuously.
        nextAddress = decodedAddress; 
    end
    else begin
        nextInstruction = currentInstruction; 
        nextAddress = currentAddress; 
    end
end

always_ff @( posedge clk, negedge rst) begin : ff_timingGeneration_mode
    if(rst == 1'b0)
        mode = ADDRESS;
    else
        mode = nextMode;
end

always_ff @( posedge clk, negedge rst) begin : ff_timingGeneration_timeState
    if(rst == 1'b0)
        timeState = T0;
    else
        timeState = nextTime;
end

always_ff @( posedge clk, negedge rst) begin : ff_OPCode
    if(rst == 1'b0) begin
    // DO RESET BEHAVIOR: THIS HASN'T BEEN DETERMINED QUITE YET
    end
    else begin
        currentInstruction = nextInstruction;
        currentAddress = nextAddress;
    end
end

endmodule