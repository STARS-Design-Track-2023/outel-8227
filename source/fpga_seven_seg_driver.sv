// parameter DECODER_BASE_ADDRESS = 16'H00; // for fpga_seven_seg_driver
`ifndef NUMFLAGS
`include "source/param_file.sv"
`endif

module fpga_seven_seg_driver
(
    input logic [7:0] addressbusHigh, addressbusLow, databus,
    input logic clk, nrst, writeEnable,
    output logic [7:0] ss0, 
    output logic [7:0] ss1, 
    output logic [7:0] ss2, 
    output logic [7:0] ss3, 
    output logic [7:0] ss4, 
    output logic [7:0] ss5, 
    output logic [7:0] ss6, 
    output logic [7:0] ss7 
);

logic [7:0] decodedData;
logic [7:0] sevenSegs0;
logic [7:0] sevenSegs1;
logic [7:0] sevenSegs2;
logic [7:0] sevenSegs3;
logic [7:0] sevenSegs4;
logic [7:0] sevenSegs5;
logic [7:0] sevenSegs6;
logic [7:0] sevenSegs7;

logic [7:0] nextSevenSegs0;
logic [7:0] nextSevenSegs1;
logic [7:0] nextSevenSegs2;
logic [7:0] nextSevenSegs3;
logic [7:0] nextSevenSegs4;
logic [7:0] nextSevenSegs5;
logic [7:0] nextSevenSegs6;
logic [7:0] nextSevenSegs7;

// assign sevenSegs0 = ss0;
// assign sevenSegs1 = ss1;
// assign sevenSegs2 = ss2;
// assign sevenSegs3 = ss3;
// assign sevenSegs4 = ss4;
// assign sevenSegs5 = ss5;
// assign sevenSegs6 = ss6;
// assign sevenSegs7 = ss7;

byteTo7Seg byteTo7Seg(.num(databus), .disp(decodedData)); // converts from numbers to 7seg display panels

always_comb begin : comb_7seg_decoder

    
      nextSevenSegs0 = ss0;
      nextSevenSegs1 = ss1;
      nextSevenSegs2 = ss2;
      nextSevenSegs3 = ss3;
      nextSevenSegs4 = ss4;
      nextSevenSegs5 = ss5;
      nextSevenSegs6 = ss6;
      nextSevenSegs7 = ss7;
  
    
    if(writeEnable) begin
        case( {addressbusHigh, addressbusLow} ) // DECODER_BASE_ADDRESS is the address of the first byte used to represent the displays
            (`DECODER_BASE_ADDRESS + 0): nextSevenSegs0 = decodedData;  
            (`DECODER_BASE_ADDRESS + 1): nextSevenSegs1 = decodedData;
            (`DECODER_BASE_ADDRESS + 2): nextSevenSegs2 = decodedData;
            (`DECODER_BASE_ADDRESS + 3): nextSevenSegs3 = decodedData;
            (`DECODER_BASE_ADDRESS + 4): nextSevenSegs4 = decodedData;
            (`DECODER_BASE_ADDRESS + 5): nextSevenSegs5 = decodedData;
            (`DECODER_BASE_ADDRESS + 6): nextSevenSegs6 = decodedData;
            (`DECODER_BASE_ADDRESS + 7): nextSevenSegs7 = decodedData;
        endcase
    end
end

always_ff @( posedge clk, negedge nrst ) begin : ff_7seg_decoder
    if(nrst == 1'b0) begin
        ss0 <= 0;
        ss1 <= 0;
        ss2 <= 0;
        ss3 <= 0;
        ss4 <= 0;
        ss5 <= 0;
        ss6 <= 0;
        ss7 <= 0;
    end
    else begin
        ss0 <= nextSevenSegs0;
        ss1 <= nextSevenSegs1;
        ss2 <= nextSevenSegs2;
        ss3 <= nextSevenSegs3;
        ss4 <= nextSevenSegs4;
        ss5 <= nextSevenSegs5;
        ss6 <= nextSevenSegs6;
        ss7 <= nextSevenSegs7;
    end
end

endmodule



  module byteTo7Seg(
    input logic [7:0] num,
    output logic [7:0] disp
  );
    always_comb begin
      case(num) 
      8'd0:
        disp = 8'b00111111;
      8'd1:
        disp = 8'b00000110;
      8'd2:
        disp = 8'b01011011;
      8'd3:
        disp = 8'b01001111;
      8'd4:
        disp = 8'b01100110;
      8'd5:
        disp = 8'b01101101;
      8'd6:
        disp = 8'b01111101;
      8'd7:
        disp = 8'b00000111;
      8'd8:
        disp = 8'b01111111;
      8'd9:
        disp = 8'b01101111;
      8'd10:
        disp = 8'b01110111;
      8'd11:
        disp = 8'b01111100;
      8'd12:
        disp = 8'b00111001;
      8'd13:
        disp = 8'b01011110;
      8'd14:
        disp = 8'b01111001;
      8'd15:
        disp = 8'b01110001;
      8'd16:
        disp = 8'b01110110; // H
      8'd17:
        disp = 8'b00111110; // w-ish
      8'd18:
        disp = 8'b01011100; // small o
      8'd19:
        disp = 8'b01010000; // r
      default:
        disp = 8'b00111111; // defaults to 0
    endcase

    end
  endmodule

// EXAMPLE 

// fpga_seven_seg_driver seven_seg_decoder (
//     .addressbusHigh(8'b0), 
//     .addressbusLow({4'b0, pb[19:16] }), 
//     .databus(pb[15:8]),
//     .clk(pb[2]), 
//     .nrst(~pb[0]), 
//     .writeEnable(pb[1]),
//     .ss0(ss0), 
//     .ss1(ss1), 
//     .ss2(ss2), 
//     .ss3(ss3), 
//     .ss4(ss4), 
//     .ss5(ss5), 
//     .ss6(ss6), 
//     .ss7(ss7)  
// );