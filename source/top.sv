`default_nettype none


`include "source/constants.sv"

// `include "source/dataflow/alu.sv"
// `include "source/dataflow/bridge.sv"
// `include "source/dataflow/bus_interface.sv"
// `include "source/dataflow/bus_preset_logic.sv"
// `include "source/dataflow/internal_bus.sv"
// `include "source/dataflow/internal_dataflow.sv"
// `include "source/dataflow/process_status_register_wrapper.sv"
// `include "source/dataflow/process_status_register.sv"
// `include "source/dataflow/program_counter_logic.sv"
// `include "source/dataflow/register.sv"

module top 
(
  // I/O ports
  input  logic hwclk, reset,
  input  logic [20:0] pb,
  output logic [7:0] left, right,
         ss7, ss6, ss5, ss4, ss3, ss2, ss1, ss0,
  output logic red, green, blue,

  // UART ports
  output logic [7:0] txdata,
  input  logic [7:0] rxdata,
  output logic txclk, rxclk,
  input  logic txready, rxready
);

  // logic [1:0] o1, o2, o3, o4;
  // logic [1:0] i1, i2, i3, i4;
  // logic [1:0] select; 

  // internalBus #(4, 2) bus (
  //   .bus_select(select),
  //   .bus_inputs({i1, i2, i3, i4}),
  //   .bus_outputs({o1, o2, o3, o4})
  // );

  // assign left[1:0] = o1;
  // assign left[3:2] = o2;
  // assign left[5:4] = o3;
  // assign left[7:6] = o4;

  // assign i1 = pb[1:0];
  // assign i2 = pb[3:2];
  // assign i3 = pb[5:4];
  // assign i4 = pb[7:6];

  // assign select = pb[9:8];

  logic [100:0] flags;

  assign flags[SET_ADH_TO_DATA] = pb[0];
  assign flags[LOAD_ABH] = pb[1];
  assign flags[SET_ADH_FF] = pb[2];

  assign flags[SET_SB_TO_ADH] = pb[3];
  always_comb begin
    flags = 101'b0;

    
    
    // flags[LOAD_X] = pb[2];

    // flags[SET_SB_TO_X] = pb[3];
    // flags[LOAD_ACC] = pb[4];
    
    // flags[SET_DB_TO_ACC] = pb[5];
    // flags[LOAD_DOR] = pb[6];
  end

  internalDataflow dataflow(
    .nrst(~pb[19]), 
    .clk(hwclk),
    .flags(flags),
    .externalDBRead(8'b10101010),
    .externalAddressBusLowOutput(),
    .externalAddressBusHighOutput(left), 
    .externalDBWrite()
  );

    timing_generator u1(.clk(pb[0]), .addressTimingCode(3'b100), .opTimingCode(3'b001), .rst(pb[4]), .timeOut(right[2:0]), .isAddressing(red) );

endmodule


module timing_generator (
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

// module timingGenerator (
//     input logic clk, rst,
//     input logic [2:0] addressTimingCode, opTimingCode,
//     output logic [2:0] timeOut,
//     output logic isAddressing
// );

// logic [2:0] negTime, nextTime;
// logic start;

// always_comb begin : comb_timingGenerator
//     if(negTime == 3'b000) begin

//         if(start) begin
//             nextTime = opTimingCode; // goes from addressing to operations
//             timeOut = addressTimingCode - negTime; // conversion for addressing, adapts to count up behavior
//         end
//         else begin
//             nextTime = addressTimingCode; // goes from operations to addressing
//             timeOut = opTimingCode - negTime; // conversion for operations, see above
//         end
//     end
//     else 
//         nextTime = negTime - 3'b001; // default behavior, decrements the next time

// end

// always_ff @( posedge clk, negedge rst ) begin : blockName
//         if(rst == 1'b0) begin
//             negTime = addressTimingCode;
//             start = 1'b1;
//         end
//         else
//             negTime = nextTime; // sets the next time
        
//         if(negTime == 3'b000)
//             start = ~start; // transition from addressing to operations and vice versa
// end 

// endmodule