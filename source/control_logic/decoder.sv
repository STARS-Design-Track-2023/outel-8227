module decoder (
    input  logic [7:0] opcode,
    output logic [5:0] CMD,
    output logic [3:0] ADDRESS,
    output logic [7:0] 
);

    logic [2:0] a;
    logic [2:0] b;
    logic [1:0] c;

    assign a = opcode[7:5];
    assign b = opcode[4:2];
    assign c = opcode[1:0];

    logic storeA;
    logic storeX;
    logic storeY;

    always_comb begin : comb_decoder

    
    CMD = 6'b0;
    ADDRESS = 4'b0;
    
    case(c)
        2'b00: begin
            case(b)
                3'b000: begin
                    case(a)
                        3'b000: begin
                             CMD=BRK;
                             ADDRESS=impl;
                        end
                        3'b001: begin
                             CMD=JSR;
                             ADDRESS=abs;
                        end
                        3'b010: begin
                             CMD=RTI;
                             ADDRESS=impl;
                        end
                        3'b011: begin
                             CMD=RTS;
                             ADDRESS=impl;
                        end
                        3'b101: begin
                             CMD=LDY;
                             ADDRESS=IMMEDIATE;
                        end
                        3'b110: begin
                             CMD=CPY;
                             ADDRESS=IMMEDIATE;
                        end
                        default: begin // ACTUAL 3'b111
                             CMD=CPX;
                             ADDRESS=IMMEDIATE;
                        end
                    endcase
                end
                3'b001: begin
                    ADDRESS=zpg;
                    case(a)
                        3'b000: CMD=BIT;
                        3'b001: CMD=BIT;
                        3'b100: CMD=STY;
                        3'b101: CMD=LDY;
                        3'b110: CMD=CPY;
                        default: CMD=CPX; // ACTUAL 3'b111 
                    endcase
                end
                3'b010: begin
                    ADDRESS=impl;
                    case(a)
                        3'b000: CMD=PHP;
                        3'b001: CMD=PLP;
                        3'b010: CMD=PHA;
                        3'b011: CMD=PLA;
                        3'b100: CMD=DEY;
                        3'b101: CMD=TAY;
                        3'b110: CMD=INY;
                        default: CMD=INX; // ACTUAL 3'b111
                    endcase
                end
                3'b011: begin
                    ADDRESS=abs;
                    case(a)
                        3'b001: CMD=BIT;
                        3'b010: begin
                            CMD=JMP;
                        end
                        3'b011: begin
                            CMD=JMP;
                            ADDRESS=ind;
                        end
                        3'b100: CMD=STY;
                        3'b101: CMD=LDY;
                        3'b110: CMD=CPY;
                        default: CMD=CPX; // ACTUAL 3'b111
                    endcase
                end
                3'b100: begin
                    ADDRESS=rel;
                    case(a)
                        3'b000: CMD=BPL;
                        3'b001: CMD=BMI;
                        3'b010: CMD=BVC;
                        3'b011: CMD=BVS;
                        3'b100: CMD=BCC;
                        3'b101: CMD=BCS;
                        3'b110: CMD=BNE;
                        default: CMD=BEQ; // ACTUAL 3'b111
                    endcase
                end
                3'b101: begin
                    ADDRESS=zpgX;
                    case(a)
                        3'b100: CMD=STY;
                        default: CMD=LDY; // ACTUAL 3'b101
                    endcase
                end
                3'b110: begin
                    ADDRESS=impl;
                    case(a)
                        3'b000: CMD=CLC;
                        3'b001: CMD=SEC;
                        3'b010: CMD=CLI;
                        3'b011: CMD=SEI;
                        3'b100: CMD=TYA;
                        3'b101: CMD=CLV;
                        3'b110: CMD=CLD;
                        default: CMD=SED; // ACTUAL 3'b111
                    endcase
                end
                default: begin // ACTUAL 3'b111
                    ADDRESS=absX;
                    CMD=LDY;
                end
            endcase
            end
                
        2'b01: begin // start of block c 1
            case(b)
                3'b000: ADDRESS=Xind;
                3'b001: ADDRESS=zpg;
                3'b010: ADDRESS=IMMEDIATE;
                3'b011: ADDRESS=abs;
                3'b100: ADDRESS=indY;
                3'b101: ADDRESS=zpgX;
                3'b110: ADDRESS=absY;
                default: ADDRESS=absX; // ACTUAL 3'b111
            endcase // end of b addressing
            case(a)
                3'b000: CMD=ORA;
                3'b001: CMD=AND;
                3'b010: CMD=EOR;
                3'b011: CMD=ADC;
                3'b100: CMD=STA;
                3'b101: CMD=LDA;
                3'b110: CMD=CMP;
                default: CMD=SBC; // end of c addressing
            endcase
        end
 
        default: begin // start of block c 2
            case(b)
                3'b000: begin
                             ADDRESS=IMMEDIATE;
                             CMD=LDX;
                        end
                3'b001: begin
                ADDRESS=zpg;
                    case(a)
                        3'b000: begin
                             CMD=ASL;
                             ADDRESS=A;
                        end
                        3'b001: begin
                             CMD=ROL;
                             ADDRESS=A;
                        end
                        3'b010: begin
                             CMD=LSR;
                             ADDRESS=A;
                        end
                        3'b011: begin
                             CMD=ROR;
                             ADDRESS=A;
                        end
                        3'b100: begin
                             CMD=STX;
                             ADDRESS=impl;
                        end
                        3'b101: begin
                             CMD=LDX;
                             ADDRESS=impl;
                        end
                        3'b110: begin
                             CMD=DEC;
                             ADDRESS=impl;
                        end
                        default: begin // ACTUAL 3'b111
                             CMD=INC;
                             ADDRESS=impl;
                        end
                    endcase
                end
                3'b010: begin
                    case(a)
                        3'b000: CMD=ASLA;
                        3'b001: CMD=ROLA;
                        3'b010: CMD=LSRA;
                        3'b011: CMD=RORA;
                        3'b100: CMD=TXA;
                        3'b101: CMD=TAX;
                        3'b110: CMD=DEX;
                        default: CMD=NOP; // ACTUAL 3'b111
                    endcase
                end
                3'b011: begin
                ADDRESS=abs;
                    case(a)
                        3'b000: CMD=ASL;
                        3'b001: CMD=ROL;
                        3'b010: CMD=LSR;
                        3'b011: CMD=ROR;
                        3'b100: CMD=STX;
                        3'b101: CMD=LDX;
                        3'b110: CMD=DEC;
                        default: CMD=INC; // ACTUAL 3'b111
                    endcase
                end
                3'b101: begin
                    case(a)
                        3'b000: begin
                             CMD=ASL;
                             ADDRESS=zpgX;
                        end
                        3'b001: begin
                             CMD=ROL;
                             ADDRESS=zpgX;
                        end
                        3'b010: begin
                             CMD=LSR;
                             ADDRESS=zpgX;
                        end
                        3'b011: begin
                             CMD=ROR;
                             ADDRESS=zpgX;
                        end
                        3'b100: begin
                             CMD=STX;
                             ADDRESS=zpgY;
                        end
                        3'b101: begin
                             CMD=LDX;
                             ADDRESS=zpgY;
                        end
                        3'b110: begin
                             CMD=DEC;
                             ADDRESS=zpgX;
                        end
                        default: begin // ACTUAL 3'b111
                             CMD=INC;
                             ADDRESS=zpgX;
                        end
                    endcase
                end
                3'b110: begin
                    ADDRESS=impl;
                    case(a)
                        3'b100: CMD=TXS;
                        default: CMD=TSX; // ACTUAL 3'b101
                    endcase
                end
                default: begin // ACTUAL 3'b101
                    ADDRESS=absX;
                    case(a)
                        3'b000: CMD=ASL;
                        3'b001: CMD=ROL;
                        3'b010: CMD=LSR;
                        3'b011: CMD=ROR;
                        3'b101: CMD=LDX;
                        3'b110: CMD=DEC;
                        default: CMD=INC; // ACTUAL 3'b101
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