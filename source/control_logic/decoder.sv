`ifndef NUMFLAGS
`include "source/param_file.sv"
`endif
module decoder (
    input  logic [7:0] opcode,
    output logic [5:0] cmd,
    output logic [3:0] address
);

    logic [2:0] a;
    logic [2:0] b;
    logic [1:0] c;

    assign a = opcode[7:5];
    assign b = opcode[4:2];
    assign c = opcode[1:0];

    always_comb begin : comb_decoder

    
    cmd = 6'b0;
    address = 4'b0;
    
    casez(c)
        2'b00: begin
            case(b)
                3'b000: begin
                    case(a)
                        3'b000: begin
                             cmd=`BRK;
                             address=`impl;
                        end
                        3'b001: begin
                             cmd=`JSR;
                             address=`impl;
                        end
                        3'b010: begin
                             cmd=`RTI;
                             address=`impl;
                        end
                        3'b011: begin
                             cmd=`RTS;
                             address=`impl;
                        end
                        3'b101: begin
                             cmd=`LDY;
                             address=`IMMEDIATE;
                        end
                        3'b110: begin
                             cmd=`CPY;
                             address=`IMMEDIATE;
                        end
                        default: begin // ACTUAL 3'b111
                             cmd=`CPX;
                             address=`IMMEDIATE;
                        end
                    endcase
                end
                3'b001: begin
                    address=`zpg;
                    casez(a)
                        3'b00?: cmd=`BIT;
                        3'b100: cmd=`STY;
                        3'b101: cmd=`LDY;
                        3'b110: cmd=`CPY;
                        default: cmd=`CPX; // ACTUAL 3'b111 
                    endcase
                end
                3'b010: begin
                    address=`impl;
                    case(a)
                        3'b000: cmd=`PHP;
                        3'b001: cmd=`PLP;
                        3'b010: cmd=`PHA;
                        3'b011: cmd=`PLA;
                        3'b100: cmd=`DEY;
                        3'b101: cmd=`TAY;
                        3'b110: cmd=`INY;
                        default: cmd=`INX; // ACTUAL 3'b111
                    endcase
                end
                3'b011: begin
                    address=`abs;
                    case(a)
                        3'b001: cmd=`BIT;
                        3'b010: begin
                            cmd=`JMP;
                        end
                        3'b011: begin
                            cmd=`JMP;
                            address=`ind;
                        end
                        3'b100: cmd=`STY;
                        3'b101: cmd=`LDY;
                        3'b110: cmd=`CPY;
                        default: cmd=`CPX; // ACTUAL 3'b111
                    endcase
                end
                3'b100: begin
                    address=`rel;
                    case(a)
                        3'b000: cmd=`BPL;
                        3'b001: cmd=`BMI;
                        3'b010: cmd=`BVC;
                        3'b011: cmd=`BVS;
                        3'b100: cmd=`BCC;
                        3'b101: cmd=`BCS;
                        3'b110: cmd=`BNE;
                        default: cmd=`BEQ; // ACTUAL 3'b111
                    endcase
                end
                3'b101: begin
                    address=`zpgX;
                    case(a)
                        3'b100: cmd=`STY;
                        default: cmd=`LDY; // ACTUAL 3'b101
                    endcase
                end
                3'b110: begin
                    address=`impl;
                    case(a)
                        3'b000: cmd=`CLC;
                        3'b001: cmd=`SEC;
                        3'b010: cmd=`CLI;
                        3'b011: cmd=`SEI;
                        3'b100: cmd=`TYA;
                        3'b101: cmd=`CLV;
                        3'b110: cmd=`CLD;
                        default: cmd=`SED; // ACTUAL 3'b111
                    endcase
                end
                default: begin // ACTUAL 3'b111
                    address=`absX;
                    cmd=`LDY;
                end
            endcase
            end
                
        2'b01: begin // start of block c 1
            case(b)
                3'b000: address=`Xind;
                3'b001: address=`zpg;
                3'b010: address=`IMMEDIATE;
                3'b011: address=`abs;
                3'b100: address=`indY;
                3'b101: address=`zpgX;
                3'b110: address=`absY;
                default: address=`absX; // ACTUAL 3'b111
            endcase // end of b addressing
            case(a)
                3'b000: cmd=`ORA;
                3'b001: cmd=`AND;
                3'b010: cmd=`EOR;
                3'b011: cmd=`ADC;
                3'b100: cmd=`STA;
                3'b101: cmd=`LDA;
                3'b110: cmd=`CMP;
                default: cmd=`SBC; // end of c addressing
            endcase
        end
 
        default: begin // start of block c 2
            case(b)
                3'b000: begin
                             address=`IMMEDIATE;
                             cmd=`LDX;
                        end
                3'b001: begin
                address=`zpg;
                    case(a)
                        3'b000: begin
                             cmd=`ASL;
                             address=`A;
                        end
                        3'b001: begin
                             cmd=`ROL;
                             address=`A;
                        end
                        3'b010: begin
                             cmd=`LSR;
                             address=`A;
                        end
                        3'b011: begin
                             cmd=`ROR;
                             address=`A;
                        end
                        3'b100: begin
                             cmd=`STX;
                             address=`zpg;
                        end
                        3'b101: begin
                             cmd=`LDX;
                             address=`zpg;
                        end
                        3'b110: begin
                             cmd=`DEC;
                             address=`impl;
                        end
                        default: begin // ACTUAL 3'b111
                             cmd=`INC;
                             address=`impl;
                        end
                    endcase
                end
                3'b010: begin
                    case(a)
                        3'b000: cmd=`ASLA;
                        3'b001: cmd=`ROLA;
                        3'b010: cmd=`LSRA;
                        3'b011: cmd=`RORA;
                        3'b100: cmd=`TXA;
                        3'b101: cmd=`TAX;
                        3'b110: cmd=`DEX;
                        default: cmd=`NOP; // ACTUAL 3'b111
                    endcase
                end
                3'b011: begin
                    address=`abs;
                    case(a)
                        3'b000: cmd=`ASL;
                        3'b001: cmd=`ROL;
                        3'b010: cmd=`LSR;
                        3'b011: cmd=`ROR;
                        3'b100: cmd=`STX;
                        3'b101: cmd=`LDX;
                        3'b110: cmd=`DEC;
                        default: cmd=`INC; // ACTUAL 3'b111
                    endcase
                end
                3'b101: begin
                    case(a)
                        3'b000: begin
                             cmd=`ASL;
                             address=`zpgX;
                        end
                        3'b001: begin
                             cmd=`ROL;
                             address=`zpgX;
                        end
                        3'b010: begin
                             cmd=`LSR;
                             address=`zpgX;
                        end
                        3'b011: begin
                             cmd=`ROR;
                             address=`zpgX;
                        end
                        3'b100: begin
                             cmd=`STX;
                             address=`zpgY;
                        end
                        3'b101: begin
                             cmd=`LDX;
                             address=`zpgY;
                        end
                        3'b110: begin
                             cmd=`DEC;
                             address=`zpgX;
                        end
                        default: begin // ACTUAL 3'b111
                             cmd=`INC;
                             address=`zpgX;
                        end
                    endcase
                end
                3'b110: begin
                    address=`impl;
                    case(a)
                        3'b100: cmd=`TXS;
                        default: cmd=`TSX; // ACTUAL 3'b101
                    endcase
                end
                default: begin // ACTUAL 3'b101
                    address=`absX;
                    case(a)
                        3'b000: cmd=`ASL;
                        3'b001: cmd=`ROL;
                        3'b010: cmd=`LSR;
                        3'b011: cmd=`ROR;
                        3'b101: cmd=`LDX;
                        3'b110: cmd=`DEC;
                        default: cmd=`INC; // ACTUAL 3'b101
                    endcase
                end
            endcase
        end
    endcase

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
