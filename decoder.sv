
parameter ADC = 6'd1; // INSTRUCTION PARAMATERS
parameter AND = 6'd2;
parameter ASL = 6'd3;
parameter BCC = 6'd4;
parameter BCS = 6'd5;
parameter BEQ = 6'd6;
parameter BIT = 6'd7;
parameter BMI = 6'd8;
parameter BNE = 6'd9;
parameter BPL = 6'd10;
parameter BRK = 6'd11;
parameter BVC = 6'd12;
parameter BVS = 6'd13;
parameter CLC = 6'd14;
parameter CLD = 6'd15;
parameter CLI = 6'd16;
parameter CLV = 6'd17;
parameter CMP = 6'd18;
parameter CPX = 6'd19;
parameter CPY = 6'd20;
parameter DEC = 6'd21;
parameter DEX = 6'd22;
parameter DEY = 6'd23;
parameter EOR = 6'd24;
parameter INC = 6'd25;
parameter INX = 6'd26;
parameter INY = 6'd27;
parameter JMP = 6'd28;
parameter JSR = 6'd29;
parameter LDA = 6'd30;
parameter LDX = 6'd31;
parameter LDY = 6'd32;
parameter LSR = 6'd33;
parameter NOP = 6'd34;
parameter ORA = 6'd35;
parameter PHA = 6'd36;
parameter PHP = 6'd37;
parameter PLA = 6'd38;
parameter PLP = 6'd39;
parameter ROL = 6'd40;
parameter ROR = 6'd41;
parameter RTI = 6'd42;
parameter RTS = 6'd43;
parameter SBC = 6'd44;
parameter SEC = 6'd44;
parameter SED = 6'd45;
parameter SEI = 6'd46;
parameter STA = 6'd47;
parameter STX = 6'd48;
parameter STY = 6'd49;
parameter TAX = 6'd50;
parameter TAY = 6'd51;
parameter TSX = 6'd52;
parameter TXA = 6'd53;
parameter TXS = 6'd54;
parameter ASLA =6'd55; // Start of instructions that were forgot
parameter ROLA = 6'd56;
parameter LSRA = 6'd57;
parameter RORA = 6'd58;
parameter TYA = 6'd59; // END OF INSTRUCTION PARAMETERS

parameter A = 5'd0;
parameter abs = 5'd1; // ADDRESSING PARAMETERS
parameter absX = 5'd2;
parameter absY = 5'd3;
parameter IMMEDIATE = 5'd4;
parameter impl = 5'd5;
parameter ind = 5'd6;
parameter Xind = 5'd7;
parameter indY= 5'd8;
parameter rel = 5'd9;
parameter zpg = 5'd10;
parameter zpgX = 5'd11;
parameter zpgY = 5'd12; 
parameter implied = 5'd13; // END OF ADDRESSING PARAMETERS

module decoder (
    input logic [7:0] opcode,
    output logic [2:0] addressTimingCode, opTimingCode,
    output logic [5:0] CMD,
    output logic [4:0] ADDRESS
);

    always_comb begin : comb_decoder

    logic [2:0] a = opcode[7:5];
    logic [2:0] b = opcode[4:2];
    logic [1:0] c = opcode[1:0];

    logic storeA;
    logic storeX;
    logic storeY;
    
    CMD = 6'b0;
    ADDRESS = 5'b0;
    addressTimingCode = 3'b000;
    opTimingCode = 3'b000;
    
    casez(c)
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
                    casez(a)
                        3'b00?: CMD=BIT;
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
                        3'b010: CMD=JMP;
                        3'b011: begin
                             CMD=JMP;
                             ADDRESS=ind;
                             ADDRESS=abs; // only one with a different address
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