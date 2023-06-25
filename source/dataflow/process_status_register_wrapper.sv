module processStatusRegisterWrapper(
    input logic clk,
    input logic nrst,
    input logic [7:0] DB_in,    //data bus input
    input logic manual_set,     //from rcl, manually choose values for bits
    input logic carry,          //carry flag from alu
    input logic overflow,       //overflow flag from alu
    input logic DB0_C,          //"DB" means enabled bits will read the corresponding bit from DB
    input logic DB1_Z,          //These are enable flags
    input logic DB2_I,
    input logic DB3_D,
    input logic DB6_V,
    input logic DB7_N,          
    input logic manual_C,       //"manual" means enabled bits will take the value of manual set
    input logic manual_I,
    input logic manual_D,
    input logic carry_C,        //enable read from alu
    input logic DBall_Z,        //enable set from ~|= (NOR) databus, Dragon Ball Z
    input logic overflow_V,     //enble read from alu
    input logic rcl_V,          //directly set V to 1 from rcl
    input logic break_set,
    output logic [7:0] PSR_RCL,
    output logic [7:0] PSR_DB,
    input logic enableDBWrite
);

logic [7:0] internalFFInput, internalFFOutput;//The input and output to the internal register inside the bus interfaces

//Always pass the input through the bus interface.  This module is left to accomodate potential future needs.
busInterface inputInterface(.interfaceInput(DB_in), .enable(1'b1), .interfaceOutput(internalFFInput));

processStatusReg processStatusReg(
    .clk(clk),
    .nrst(nrst),
    .DB_in(DB_in),
    .manual_set(manual_set),
    .carry(carry),
    .overflow(overflow),
    .DB0_C(DB0_C),
    .DB1_Z(DB1_Z),
    .DB2_I(DB2_I),
    .DB3_D(DB3_D),
    .DB6_V(DB6_V),
    .DB7_N(DB7_N),
    .manual_C(manual_C),
    .manual_I(manual_I),
    .manual_D(manual_D),
    .carry_C(carry_C),
    .DBall_Z(DBall_Z),
    .overflow_V(overflow_V),
    .rcl_V(rcl_V),
    .PSR_Output(internalFFOutput),
    .break_set(break_set)
);

//Output Logic:  PSR_RCL always has the signal.  PSR_DB can be disabled (but will write to the internal data bus when enabled)
assign PSR_RCL = internalFFOutput;
busInterface outputInterface(.interfaceInput(internalFFOutput), .enable(enableDBWrite), .interfaceOutput(PSR_DB));

endmodule