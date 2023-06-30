
module seven_seg_decoder
(
    input logic [7:0] addressbusHigh, addressbusLow, databus,
    input logic clk, nrst, writeEnable,
    output logic [7:0] sevenSegs [7:0]
);

logic [7:0] decodedData;
logic [7:0] nextSevenSegs [7:0];

byteTo7Seg byteTo7Seg(.num(databus), .disp(decodedData)); // converts from numbers to 7seg display panels

always_comb begin : comb_7seg_decoder

    nextSevenSegs = sevenSegs;
    if(writeEnable) begin
        case( {addressbusHigh, addressbusLow} ) // DECODER_BASE_ADDRESS is the address of the first byte used to represent the displays
            (DECODER_BASE_ADDRESS + 0): nextSevenSegs[0] = decodedData;  
            (DECODER_BASE_ADDRESS + 1): nextSevenSegs[1] = decodedData;
            (DECODER_BASE_ADDRESS + 2): nextSevenSegs[2] = decodedData;
            (DECODER_BASE_ADDRESS + 3): nextSevenSegs[3] = decodedData;
            (DECODER_BASE_ADDRESS + 4): nextSevenSegs[4] = decodedData;
            (DECODER_BASE_ADDRESS + 5): nextSevenSegs[5] = decodedData;
            (DECODER_BASE_ADDRESS + 6): nextSevenSegs[6] = decodedData;
            (DECODER_BASE_ADDRESS + 7): nextSevenSegs[7] = decodedData;
        endcase
    end
end

always_ff @( clk, nrst ) begin : ff_7seg_decoder
    if(nrst == 1'b0) begin
        sevenSegs[0] = 0;
        sevenSegs[1] = 0;
        sevenSegs[2] = 0;
        sevenSegs[3] = 0;
        sevenSegs[4] = 0;
        sevenSegs[5] = 0;
        sevenSegs[6] = 0;
        sevenSegs[7] = 0;
    end
    else begin
        sevenSegs[0] = nextSevenSegs[0];
        sevenSegs[1] = nextSevenSegs[1];
        sevenSegs[2] = nextSevenSegs[2];
        sevenSegs[3] = nextSevenSegs[3];
        sevenSegs[4] = nextSevenSegs[4];
        sevenSegs[5] = nextSevenSegs[5];
        sevenSegs[6] = nextSevenSegs[6];
        sevenSegs[7] = nextSevenSegs[7];
    end
end

endmodule



  module byteTo7Seg(
    input logic [7:0] num,
    output logic [7:0] disp
  );
    always_comb begin
      case(num) 
      8'd0: disp = 8'b01111110;
      8'd1: disp = 8'b00001100;
      8'd2: disp = 8'b10110110;
      8'd3: disp = 8'b10011110;
      8'd4: disp = 8'b11001100;
      8'd5: disp = 8'b11011010;
      8'd6: disp = 8'b11111010;
      8'd7: disp = 8'b00001110;
      8'd8: disp = 8'b11111110;
      8'd9: disp = 8'b11011110;
      8'd10: disp =8'b11101110;
      default: disp = 8'd0;
      endcase
    end
  endmodule