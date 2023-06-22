module processStatusRegisterWrapper(
    input logic [7:0] DB_in,    //data bus input
    input logic manual_set,     //from rcl, manually choose values for bits
    input logic carry,          //carry flag from alu
    input logic overflow,       //overflow flag from alu
    input logic DB0_C,          //"DB" means enabled bits will read the corresponding bit from DB
    input logic DB1_Z,
    input logic DB2_I,
    input logic DB3_D,
    input logic DB6_V,
    input logic DB7_N,          
    input logic manual_C,       //"manual" means enabled bits will take the value of manual set
    input logic manual_I,
    input logic manual_D,
    input logic carry_C,        //enable read from alu
    input logic DBall_Z,        //enable set from |= databus, Dragon Ball Z
    input logic overflow_V,     //enble read from alu
    input logic rcl_V,          //directly set V to 1 from rcl
    input logic break_set,
    input logic break_clear,
    output logic [7:0] PSR_RCL,
    output logic [7:0] PSR_DB,
);



processStatusReg processStatusReg(
    .DB_in(),
    .manual_set(),
    .carry(),
    .overflow(),
    .DB0_C(),
    .DB1_Z(),
    .DB2_I(),
    .DB3_D(),
    .DB6_V(),
    .DB7_N(),
    .manual_C(),
    .manual_I(),
    .manual_D(),
    .carry_C(),
    .DBall_Z(),
    .overflow_V(),
    .rcl_V(),
    .PSR_RCL(),
    .PSR_DB()
);

endmodule