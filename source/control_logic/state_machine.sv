`ifndef NUMFLAGS
`include "source/param_file.sv"
`endif
module state_machine(
    input logic clk, nrst, noAddressing, getInstruction, endAddressing,
    input logic [5:0] decodedInstruction,
    input logic [3:0] decodedAddress,
    output logic [5:0] currentInstruction,
    output logic [3:0] currentAddress,
    output logic [2:0] timeState,
    output logic mode,
    input logic enableFFs
);

logic nextMode;
logic [2:0] nextTime;
always_comb begin : comb_timingGeneration
    if(endAddressing) begin // it is on the last stage of addressing
        nextMode = `INSTRUCTION;
        nextTime = `T0;
    end
    else if(getInstruction) begin // it is on the last stage of the instruction
        nextMode = `ADDRESS;
        nextTime = `T0;
    end
    else begin
        nextMode = mode; // default behavior, remains in the loop

        case(timeState) // state machine proper, increases until it hits the max time in the instruction then resets
        `T0: nextTime = `T1;
        `T1: nextTime = `T2;
        `T2: nextTime = `T3;
        `T3: nextTime = `T4;
        `T4: nextTime = `T5;
        `T5: nextTime = `T6;
        default: nextTime = `T0;
        endcase
    end
    if((mode == `ADDRESS) & noAddressing) begin
        nextMode = `INSTRUCTION;
    end
    if(~enableFFs)
    begin
        nextTime = timeState;
        nextMode = mode;
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
    
    if(~enableFFs) // code that disables the state machine when unready
    begin
        nextInstruction = currentInstruction;
        nextAddress = currentAddress;
    end
end

always_ff @( posedge clk, negedge nrst) begin : ff_timingGeneration_mode
    if(nrst == 1'b0)
        mode <= `ADDRESS;
    else
        mode <= nextMode;
end

always_ff @( posedge clk, negedge nrst) begin : ff_timingGeneration_timeState
    if(nrst == 1'b0)
        timeState <= `T0;
    else
        timeState <= nextTime;
end

always_ff @( posedge clk, negedge nrst) begin : ff_OPCode
    if(nrst == 1'b0) begin
        currentInstruction <= 0;
        currentAddress <= 0; 
    end
    else begin
        currentInstruction <= nextInstruction;
        currentAddress <= nextAddress;
    end
end

endmodule
