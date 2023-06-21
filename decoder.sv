module decoder (
    input logic [7:0] opcode,
    output logic [2:0] addressTimingCode, opTimingCode,
    output logic [56:0] CMD,
    
    output logic [26:0] ADDRESS
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
                             CMD[BRK]=1'b1;
                             ADDRESS=impl;
                        end
                        3'b001: begin
                             CMD= JSR;
                             ADDRESS=abs;
                        end
                        3'b010: begin
                             CMD[RTI]=1'b1;
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
                             CMD[CPX]=1'b1;
                             ADDRESS=?;
                        end
                    endcase
                
                3'b001:
                    ADDRESS=zpg
                    casez(a)
                        3'b00?: CMD[BIT]=1'b1;
                        3'b100: CMD[STY]=1'b1;
                        3'b101: CMD[LDY]=1'b1;
                        3'b110: CMD[CPY]=1'b1;
                        3'b111: CMD[CPX]=1'b1;

                3'b010: begin
                    ADDRESS=impl
                    case(a)
                        3'b000: CMD[PHP]=1'b1;
                        3'b001: CMD[PLP]=1'b1;
                        3'b010: CMD[PHA]=1'b1;
                        3'b011: CMD[PLA]=1'b1;
                        3'b100: CMD[DEY]=1'b1;
                        3'b101: CMD[TAY]=1'b1;
                        3'b110: CMD[INY]=1'b1;
                        3'b111: CMD[INX]=1'b1;
                    endcase
                end
                3'b011: begin
                    ADDRESS=abs
                    case(a)
                        3'b001: CMD[BIT]=1'b1;
                        3'b010: CMD[JMP]=1'b1;
                        3'b011: begin
                             CMD[JMP]=1'b1;
                             ADDRESS=ind; // only one with a different address
                        end
                        3'b100: CMD[STY]=1'b1;
                        3'b101: CMD[LDY]=1'b1;
                        3'b110: CMD[CPY]=1'b1;
                        3'b111: CMD[CPX]=1'b1;
                end
                3'b100: begin
                    ADDRESS[rel]=1'b1
                    case(a)
                        3'b000: CMD[BPL]=1'b1;
                        3'b001: CMD[BMI]=1'b1;
                        3'b010: CMD[BVC]=1'b1;
                        3'b011: CMD[BVS]=1'b1;
                        3'b100: CMD[BCC]=1'b1;
                        3'b101: CMD[BCS]=1'b1;
                        3'b110: CMD[BNE]=1'b1;
                        3'b111: CMD[BEQ]=1'b1;
                end
                3'b101: begin
                    ADDRESS=zpg,X;
                    case(a)
                        3'b100: CMD[STY]=1'b1;
                        3'b101: CMD[LDY]=1'b1;
                3'b110: begin
                    ADDRESS=impl
                    case(a)
                        3'b000: CMD[CLC]=1'b1;
                        3'b001: CMD[SEC]=1'b1;
                        3'b010: CMD[CLI]=1'b1;
                        3'b011: CMD[SEI]=1'b1;
                        3'b100: CMD[TYA]=1'b1;
                        3'b101: CMD[CLV]=1'b1;
                        3'b110: CMD[CLD]=1'b1;
                        3'b111: CMD[SED]=1'b1;
                3'b111: begin
                    ADDRESS=abs,X;
                    CMD=LDY;
                
        2'b01:  begin
            case(b)
                3'b000: ADDRESS[IND]=1'b1;
                3'b001: ADDRESS[ZPG]=1'b1;
                3'b010: ADDRESS[?]=1'b1;
                3'b011: ADDRESS[abs]=1'b1;
                3'b100: ADDRESS[ind]=1'b1;
                3'b101: ADDRESS[zpgX;]=1'b1
                3'b110: ADDRESS[absY;]=1'b1
                3'b111: ADDRESS[absX;]=1'b1
            case(c)
                3'b000: CMD[ORA]=1'b1;
                3'b001: CMD[AND]=1'b1;
                3'b010: CMD[EOR]=1'b1;
                3'b011: CMD[ADC]=1'b1;
                3'b100: CMD[STA]=1'b1;
                3'b101: CMD[LDA]=1'b1;
                3'b110: CMD[CMP]=1'b1;
                3'b111: CMD[SBC]=1'b1;
 
        2'b10: begin
            case(b)
                3'b000: begin
                             ADDRESS=?;
                             CMD[LDX]=1'b1;
                        end
                3'b001: begin
                ADDRESS=zpg
                    case(c)
                        3'b000: CMD[ASL]=1'b1;
                        3'b001: CMD[ROL]=1'b1;
                        3'b010: CMD[LSR]=1'b1;
                        3'b011: CMD[ROR]=1'b1;
                        3'b100: CMD[STX]=1'b1;
                        3'b101: CMD[LDX]=1'b1;
                        3'b110: CMD[DEC]=1'b1;
                        3'b111: CMD[INC]=1'b1;
                3'b010: begin
                    case(c)
                        3'b000: CMD[ASL]=1'b1;
                        3'b001: CMD[ROL]=1'b1;
                        3'b010: CMD[LSR]=1'b1;
                        3'b011: CMD[ROR]=1'b1;
                        3'b100: CMD[TXA]=1'b1;
                        3'b101: CMD[TAX]=1'b1;
                        3'b110: CMD[DEX]=1'b1;
                        3'b111: CMD[NOP]=1'b1;
                3'b011: begin
                ADDRESS=abs
                    case(c)
                        3'b000: CMD[ASL]=1'b1;
                        3'b001: CMD[ROL]=1'b1;
                        3'b010: CMD[LSR]=1'b1;
                        3'b011: CMD[ROR]=1'b1;
                        3'b100: CMD[STX]=1'b1;
                        3'b101: CMD[LDX]=1'b1;
                        3'b110: CMD[DEC]=1'b1;
                        3'b111: CMD[INC]=1'b1;
                3'b101: begin
                    case(c)
                        3'b000: begin
                             CMD=ASL;
                             ADDRESS=zpgX;
                        end
                        3'b001: begin
                             CMD[ROL]=1'b1;
                             ADDRESS=zpgX
                        end
                        3'b010: begin
                             CMD[LSR]=1'b1;
                             ADDRESS=zpgX
                        end
                        3'b011: begin
                             CMD[ROR]=1'b1;
                             ADDRESS=zpgX
                        end
                        3'b100: begin
                             CMD[STX]=1'b1;
                             ADDRESS=zpgY
                        end
                        3'b101: begin
                             CMD[LDX]=1'b1;
                             ADDRESS=zpgY
                        end
                        3'b110: begin
                             CMD[DEC]=1'b1;
                             ADDRESS=zpgX
                        end
                        3'b111: begin
                             CMD[INC]=1'b1;
                             ADDRESS=zpgX
                        end
                    endcase
                end
                3'b110: begin
                    ADDRESS=impl
                    case(c)
                        3'b100: CMD[TXS]=1'b1;
                        3'b101: CMD[TSX]=1'b1;
                    endcase
                3'b111: begin 
                    ABS,X
                    case(c)
                        3'b000: CMD[ASL]=1'b1;
                        3'b001: CMD[ROL]=1'b1;
                        3'b010: CMD[LSR]=1'b1;
                        3'b011: CMD[ROR]=1'b1;
                        3'b101: CMD[LDX]=1'b1;
                        3'b110: CMD[DEC]=1'b1;
                        3'b111: CMD[INC]=1'b1;
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