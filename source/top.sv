`default_nettype none


// `include "source/control_logic/state_machine.sv" 
// `include "source/param_file.sv" 

//`include "source/constants.sv"

// `include "source/dataflow/alu.sv"
// `include "source/dataflow/bridge.sv"
// `include "source/dataflow/bus_interface.sv"
// `include "source/dataflow/bus_preset_logic.sv"
// // `include "source/dataflow/bus2.sv"
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

  top8227 top8227(
    .clk(hwclk), 
    .nrst(~pb[19]), 
    .nonMaskableInterrupt(pb[18]), 
    .interruptRequest(pb[17]), 
    .dataBusInput(pb[7:0]),
    .dataBusOutput({ss7[7], ss6[7], ss5[7], ss4[7], ss3[7], ss2[7], ss1[7], ss0[7]}),
    .AddressBusHigh(left),
    .AddressBusLow(right)
  );
    
endmodule


// module timing_generator (
//   input logic clk, rst,
//   input logic [2:0] addressTimingCode, opTimingCode,
//   output logic [2:0] timeOut,
//   output logic isAddressing
// );

// logic [2:0] negTime, nextTime;

// always_comb begin : comb_timingGenerator
//     nextTime = 3'b000;
//     timeOut = 3'b000;
//     if(negTime == 3'b000) begin

//       if(isAddressing)
//         nextTime = opTimingCode; // goes from addressing to operations
//       else
//         nextTime = addressTimingCode; // goes from operations to addressing

//     end
//     else 
//         nextTime = negTime - 3'b001; // default behavior, decrements the next time


//     if(isAddressing)
//         timeOut = addressTimingCode - negTime; // conversion for addressing, adapts to count up behavior
//     else
//         timeOut = opTimingCode - negTime; // conversion for operations, see above
// end

// always_ff @( posedge clk, negedge rst ) begin : ff_timingGenerator
//         if(rst == 1'b0) begin
//             negTime = addressTimingCode;
//         end
//         else
//             negTime = nextTime; // sets the next time
        
// end 

// always_ff @( posedge clk, negedge rst ) begin : ff_start_timingGenerator
//     if(rst == 1'b0) 
//         isAddressing = 1'b1;
//     else if(negTime == 3'b000)
//         isAddressing = ~isAddressing; // transition from addressing to operations and vice versa
// end

// endmodule

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
