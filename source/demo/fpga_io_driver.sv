`default_nettype none
`ifndef NUMFLAGS
`include "source/param_file.sv"
`endif

// Relative adresses from page 0x80
`define SS0_ADDR 0
`define SS1_ADDR 1
`define SS2_ADDR 2
`define SS3_ADDR 3
`define SS4_ADDR 4
`define SS5_ADDR 5
`define SS6_ADDR 6
`define SS7_ADDR 7
`define LEFT_ADDR 8
`define RIGHT_ADDR 9
`define PB_ADDR 10 // gets 10 and the next 20 bytes (21 in total)

module fpga_io_driver
(
    input logic clk, nrst, read_en,
    input logic [7:0] addr,
    input logic [7:0] din,
    input logic [20:0] pb,
    output logic [7:0] dout,
    output logic [7:0] ss0, 
    output logic [7:0] ss1, 
    output logic [7:0] ss2, 
    output logic [7:0] ss3, 
    output logic [7:0] ss4, 
    output logic [7:0] ss5, 
    output logic [7:0] ss6, 
    output logic [7:0] ss7,
    output logic [7:0] left, 
    output logic [7:0] right  
);

  ///////////
  // SSEGS //
  ///////////

  logic [7:0] decodedData;
  logic [7:0] nextSevenSegs0;
  logic [7:0] nextSevenSegs1;
  logic [7:0] nextSevenSegs2;
  logic [7:0] nextSevenSegs3;
  logic [7:0] nextSevenSegs4;
  logic [7:0] nextSevenSegs5;
  logic [7:0] nextSevenSegs6;
  logic [7:0] nextSevenSegs7;

  byteTo7Seg byteTo7Seg(.num(din), .disp(decodedData)); // converts from numbers to 7seg display panels

  always_comb begin : comb_7seg_decoder

      
      nextSevenSegs0 = ss0;
      nextSevenSegs1 = ss1;
      nextSevenSegs2 = ss2;
      nextSevenSegs3 = ss3;
      nextSevenSegs4 = ss4;
      nextSevenSegs5 = ss5;
      nextSevenSegs6 = ss6;
      nextSevenSegs7 = ss7;
    
      
      if(~read_en) begin
          case(addr) // DECODER_BASE_ADDRESS is the address of the first byte used to represent the displays
              (`SS0_ADDR): nextSevenSegs0 = decodedData;  
              (`SS1_ADDR): nextSevenSegs1 = decodedData;
              (`SS2_ADDR): nextSevenSegs2 = decodedData;
              (`SS3_ADDR): nextSevenSegs3 = decodedData;
              (`SS4_ADDR): nextSevenSegs4 = decodedData;
              (`SS5_ADDR): nextSevenSegs5 = decodedData;
              (`SS6_ADDR): nextSevenSegs6 = decodedData;
              (`SS7_ADDR): nextSevenSegs7 = decodedData;
          endcase
      end
  end

  always_ff @( posedge clk, negedge nrst ) begin : ff_7seg_decoder
      if(nrst == 1'b0) begin
          ss0 <= 8'b00000000;
          ss1 <= 8'b00000000;
          ss2 <= 8'b00000000;
          ss3 <= 8'b00000000;
          ss4 <= 8'b00000000;
          ss5 <= 8'b00000000;
          ss6 <= 8'b00000000;
          ss7 <= 8'b00000000;
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

  //////////
  // LEDS //
  //////////

  logic [7:0] nextLeft;
  logic [7:0] nextRight;

  always_comb begin : LED_IO_HANDLER
    nextLeft = left;
    nextRight = right;

    if (~read_en) begin
      case (addr)
        `LEFT_ADDR: nextLeft = din;
        `RIGHT_ADDR: nextLeft = din;
      endcase
    end    
  end

  always_ff @( posedge clk, negedge nrst ) begin : FF_LEDS
    if (~nrst) begin
      left <= 0;
      right <= 0;
    end
    else begin
      left <= nextLeft;
      right <= nextRight;
    end
  end

  /////////
  // PBs //
  /////////

  // Should be replaced with a more elegant solution
  // 20 is number of buttons
  logic [3:0] oneHotOutput;

  oneHotEncoder #(
    .INPUT_COUNT(16),
  ) oneHotEncoder(
    .select(pb[15:0]),
    .encodedSelect(oneHotOutput)
  );
  assign dout = {4'b0, oneHotOutput};

endmodule



module byteTo7Seg(
  input logic [7:0] num,
  output logic [7:0] disp
);
  always_comb begin
    case(num) 
      8'd0:    disp = 8'b00111111;
      8'd1:    disp = 8'b00000110;
      8'd2:    disp = 8'b01011011;
      8'd3:    disp = 8'b01001111;
      8'd4:    disp = 8'b01100110;
      8'd5:    disp = 8'b01101101;
      8'd6:    disp = 8'b01111101;
      8'd7:    disp = 8'b00000111;
      8'd8:    disp = 8'b01111111;
      8'd9:    disp = 8'b01101111;
      8'd10:   disp = 8'b01110111;
      8'd11:   disp = 8'b01111100;
      8'd12:   disp = 8'b00111001;
      8'd13:   disp = 8'b01011110;
      8'd14:   disp = 8'b01111001;
      8'd15:   disp = 8'b01110001;
      8'd16:   disp = 8'b01110110; // H
      8'd17:   disp = 8'b00011100; // w-ish
      8'd18:   disp = 8'b01011100; // small o
      8'd19:   disp = 8'b01010000; // r
      8'd20:   disp = 8'b01111000; // t
      8'd21:   disp = 8'b01011000; // small e
      8'd22:   disp = 8'b01110100; // small h
      8'd23:   disp = 8'b01011110; // small d
      default: disp = 8'b00000000; // defaults to 0
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
