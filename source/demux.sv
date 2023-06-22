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

module setFlags(
input logic [5:0] instructionCode,
input logic [4:0] addressingCode,
input logic [2:0] addressTimingCode, opTimingCode,
input logic rst,
output logic [NUMFLAGS - 1:0] outFlags
);


logic [13:0] [NUMFLAGS - 1:0] outputListAddressing;
logic [59:0] [NUMFLAGS - 1:0]  outputListInstruction;
logic [2:0] currentTime;
logic isAddressing;
logic IS_STORE_ACC_INSTRUCT;
logic IS_STORE_X_INSTRUCT;
logic IS_STORE_Y_INSTRUCT;
logic passAddressing;

timing_generator u1(.clk(), .addressTimingCode(addressTimingCode), .opTimingCode(opTimingCode), .rst(rst), .timeOut(currentTime), .isAddressing(isAddressing), .passAddressing(passAddressing) );

always_comb begin : blockName
    
case(opTimingCode) 
    STO: IS_STORE_ACC_INSTRUCT = 1'b1;
    STY: IS_STORE_X_INSTRUCT = 1'b1;
    STX: IS_STORE_Y_INSTRUCT = 1'b1;
endcase

if(addressingCode == IMMEDIATE | addressingCode == implied | addressingCode == A) // bypasses Addressing
    passAddressing = 1'b1;


if(isAddressing & ~passAddressing) begin

case(addressingCode)
    A: outFlags = outputListAddressing[A];
    abs: outFlags = outputListAddressing[abs];
    absX: outFlags = outputListAddressing[absX];
    absY: outFlags = outputListAddressing[absY];
    IMMEDIATE: outFlags = outputListAddressing[IMMEDIATE];
    impl: outFlags = outputListAddressing[impl];
    ind: outFlags = outputListAddressing[ind];
    Xind: outFlags = outputListAddressing[Xind];
    indY: outFlags = outputListAddressing[indY];
    rel: outFlags = outputListAddressing[rel];
    zpg: outFlags = outputListAddressing[zpg];
    zpgX: outFlags = outputListAddressing[zpgX];
    zpgY: outFlags = outputListAddressing[zpgY];
    implied: outFlags = outputListAddressing[implied];
endcase

end
else begin

case(instructionCode)
    ADC: outFlags = outputListInstruction[ADC];
    AND: outFlags = outputListInstruction[AND];
    ASL: outFlags = outputListInstruction[ASL];
    BCC: outFlags = outputListInstruction[BCC];
    BCS: outFlags = outputListInstruction[BCS];
    BEQ: outFlags = outputListInstruction[BEQ];
    BIT: outFlags = outputListInstruction[BIT];
    BMI: outFlags = outputListInstruction[BMI];
    BNE: outFlags = outputListInstruction[BNE];
    BPL: outFlags = outputListInstruction[BPL];
    BRK: outFlags = outputListInstruction[BRK];
    BVC: outFlags = outputListInstruction[BVC];
    BVS: outFlags = outputListInstruction[BVS];
    CLC: outFlags = outputListInstruction[CLC];
    CLD: outFlags = outputListInstruction[CLD];
    CLI: outFlags = outputListInstruction[CLI];
    CLV: outFlags = outputListInstruction[CLV];
    CMP: outFlags = outputListInstruction[CMP];
    CPX: outFlags = outputListInstruction[CPX];
    CPY: outFlags = outputListInstruction[CPY];
    DEC: outFlags = outputListInstruction[DEC];
    DEX: outFlags = outputListInstruction[DEX];
    DEY: outFlags = outputListInstruction[DEY];
    EOR: outFlags = outputListInstruction[EOR];
    INC: outFlags = outputListInstruction[INC];
    INX: outFlags = outputListInstruction[INX];
    INY: outFlags = outputListInstruction[INY];
    JMP: outFlags = outputListInstruction[JMP];
    JSR: outFlags = outputListInstruction[JSR];
    LDA: outFlags = outputListInstruction[LDA];
    LDX: outFlags = outputListInstruction[LDX];
    LDY: outFlags = outputListInstruction[LDY];
    LSR: outFlags = outputListInstruction[LSR];
    NOP: outFlags = outputListInstruction[NOP];
    ORA: outFlags = outputListInstruction[ORA];
    PHA: outFlags = outputListInstruction[PHA];
    PHP: outFlags = outputListInstruction[PHP];
    PLA: outFlags = outputListInstruction[PLA];
    PLP: outFlags = outputListInstruction[PLP];
    ROL: outFlags = outputListInstruction[ROL];
    ROR: outFlags = outputListInstruction[ROR];
    RTI: outFlags = outputListInstruction[RTI];
    RTS: outFlags = outputListInstruction[RTS];
    SBC: outFlags = outputListInstruction[SBC];
    SEC: outFlags = outputListInstruction[SEC];
    SED: outFlags = outputListInstruction[SED];
    SEI: outFlags = outputListInstruction[SEI];
    
    STA: outFlags = outputListInstruction[STO]; // funky behavior on the ST? commands
    STX: outFlags = outputListInstruction[STO];
    STY: outFlags = outputListInstruction[STO];

    TAX: outFlags = outputListInstruction[TAX];
    TAY: outFlags = outputListInstruction[TAY];
    TSX: outFlags = outputListInstruction[TSX];
    TXA: outFlags = outputListInstruction[TXA];
    TXS: outFlags = outputListInstruction[TXS];
    ASLA: outFlags = outputListInstruction[ASLA];
    ROLA: outFlags = outputListInstruction[ROLA];
    LSRA: outFlags = outputListInstruction[LSRA];
    RORA: outFlags = outputListInstruction[RORA];
    TYA: outFlags = outputListInstruction[TYA];
endcase

end

end

endmodule
