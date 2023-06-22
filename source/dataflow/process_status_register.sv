module processStatusReg(
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
    input logic DBall_Z,        //enable set from |= databus
    input logic overflow_V,     //enble read from alu
    input logic rcl_V,          //directly set V to 1 from rcl
    input logic break_set,
    input logic break_clear,
    output logic [7:0] PSR_RCL,
    output logic [7:0] PSR_DB,
);



endmodule