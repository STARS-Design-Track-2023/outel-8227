module decoder (
    input logic [7:0] opcode,
    output logic [2:0] addressTimingCode, opTimingCode,
    output logic [???:0] CMD,
    output logic [???:0] ADDRESS
);

    always_comb begin : comb_decoder

    logic a = opcode[7:5];
    logic b = opcode[4:2];
    logic c = opcode[1:0];

    CMD = ???'b0;
    ADDRESS = ???'b0;

    casez(c)
        2'b00:
            casez(b)
                3'b000:
                    case(a)
                        3'b000: begin
                             CMD=BRK;
                             ADDRESS=impl;
                        end
                        3'b001: begin
                             CMD= JSR;
                             ADDRESS=abs;
                        end
                        3'b010: begin
                             CMD=RTI;
                             ADDRESS=impl;
                        end
                        3'b011: begin
                             CMD= RTS;
                             ADDRESS=impl;
                        end
                        3'b101: begin
                             CMD=LDY;
                             ADDRESS=?;
                        end
                        3'b110: begin
                             CMD=CPY;
                             ADDRESS=?;
                        end
                        3'b111: begin
                             CMD=CPX;
                             ADDRESS=?;
                        end
                    endcase
                
                3'b001:
                    ADDRESS=zpg
                    casez(a)
                        3'b00?: CMD=BIT;
                        3'b100: CMD=STY;
                        3'b101: CMD=LDY;
                        3'b110: CMD=CPY;
                        3'b111: CMD=CPX;

                3'b010: begin
                    ADDRESS=impl
                    case(a)
                        3'b000: CMD=PHP;
                        3'b001: CMD=PLP;
                        3'b010: CMD=PHA;
                        3'b011: CMD=PLA;
                        3'b100: CMD=DEY;
                        3'b101: CMD=TAY;
                        3'b110: CMD=INY;
                        3'b111: CMD=INX;
                    endcase
                end
                3'b011: begin
                    ADDRESS=abs
                    case(a)
                        3'b001: CMD=BIT;
                        3'b010: CMD=JMP;
                        3'b011: begin
                             CMD=JMP;
                             ADDRESS=ind; // only one with a different address
                        end
                        3'b100: CMD=STY;
                        3'b101: CMD=LDY;
                        3'b110: CMD=CPY;
                        3'b111: CMD=CPX;
                end
                3'b100: begin
                    ADDRESS=rel
                    case(a)
                        3'b000: CMD=BPL;
                        3'b001: CMD=BMI;
                        3'b010: CMD=BVC;
                        3'b011: CMD=BVS;
                        3'b100: CMD=BCC;
                        3'b101: CMD=BCS;
                        3'b110: CMD=BNE;
                        3'b111: CMD=BEQ;
                end
                3'b101: begin
                    ADDRESS=zpg,X;
                    case(a)
                        3'b100: CMD=STY;
                        3'b101: CMD=LDY;
                3'b110: begin
                    ADDRESS=impl
                    case(a)
                        3'b000: CMD=CLC;
                        3'b001: CMD=SEC;
                        3'b010: CMD=CLI;
                        3'b011: CMD=SEI;
                        3'b100: CMD=TYA;
                        3'b101: CMD=CLV;
                        3'b110: CMD=CLD;
                        3'b111: CMD=SED;
                3'b111: begin
                    ADDRESS=abs,X;
                    CMD=LDY;
                
        2'b01:  begin
            case(b)
                3'b000: ADDRESS=IND;
                3'b001: ADDRESS=ZPG;
                3'b010: ADDRESS=?;
                3'b011: ADDRESS=abs;
                3'b100: ADDRESS=ind;
                3'b101: ADDRESS=zpg,X;
                3'b110: ADDRESS=abs,Y;
                3'b111: ADDRESS=abs,X;
            case(c)
                3'b000: CMD=ORA;
                3'b001: CMD=AND;
                3'b010: CMD=EOR;
                3'b011: CMD=ADC;
                3'b100: CMD=STA;
                3'b101: CMD=LDA;
                3'b110: CMD=CMP;
                3'b111: CMD=SBC;
 
        2'b10: begin
            case(b)
                3'b000: begin
                             ADDRESS=?;
                             CMD=LDX;
                        end
                3'b001: begin
                ADDRESS=zpg
                    case(c)
                        3'b000: CMD=ASL;
                        3'b001: CMD=ROL;
                        3'b010: CMD=LSR;
                        3'b011: CMD=ROR;
                        3'b100: CMD=STX;
                        3'b101: CMD=LDX;
                        3'b110: CMD=DEC;
                        3'b111: CMD=INC;
                3'b010: begin
                    case(c)
                        3'b000: CMD=ASL;
                        3'b001: CMD=ROL;
                        3'b010: CMD=LSR;
                        3'b011: CMD=ROR;
                        3'b100: CMD=TXA;
                        3'b101: CMD=TAX;
                        3'b110: CMD=DEX;
                        3'b111: CMD=NOP;
                3'b011: begin
                ADDRESS=abs
                    case(c)
                        3'b000: CMD=ASL;
                        3'b001: CMD=ROL;
                        3'b010: CMD=LSR;
                        3'b011: CMD=ROR;
                        3'b100: CMD=STX;
                        3'b101: CMD=LDX;
                        3'b110: CMD=DEC;
                        3'b111: CMD=INC;
                3'b101: begin
                    case(c)
                        3'b000: begin
                             CMD=ASL;
                             ADDRESS=zpg,X;
                        end
                        3'b001: begin
                             CMD=ROL;
                             ADDRESS=zpg,X
                        end
                        3'b010: begin
                             CMD=LSR;
                             ADDRESS=zpg,X
                        end
                        3'b011: begin
                             CMD=ROR;
                             ADDRESS=zpg,X
                        end
                        3'b100: begin
                             CMD=STX;
                             ADDRESS=zpg,Y
                        end
                        3'b101: begin
                             CMD=LDX;
                             ADDRESS=zpg,Y
                        end
                        3'b110: begin
                             CMD=DEC;
                             ADDRESS=zpg,X
                        end
                        3'b111: begin
                             CMD=INC;
                             ADDRESS=zpg,X
                        end
                    endcase
                end
                3'b110: begin
                    ADDRESS=impl
                    case(c)
                        3'b100: CMD=TXS;
                        3'b101: CMD=TSX;
                    endcase
                3'b111: begin 
                    ABS,X
                    case(c)
                        3'b000: CMD=ASL;
                        3'b001: CMD=ROL;
                        3'b010: CMD=LSR;
                        3'b011: CMD=ROR;
                        3'b101: CMD=LDX;
                        3'b110: CMD=DEC;
                        3'b111: CMD=INC;
                    endcase
    end

end

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