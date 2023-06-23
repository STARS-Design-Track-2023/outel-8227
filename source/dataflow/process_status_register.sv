module processStatusReg(
    input logic clk, nrst,      //clock and active low async reset
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
    input logic rcl_V,          //directly set V to 1 from rcl (random control logic)
    input logic break_set,      //Sets break high for interrupt / break control
    output logic [7:0] PSR_Output //status register to control unit
);

    logic [7:0] status_buffer, stat_buf_nxt;            //reg to hold status flags
    always_ff @ (posedge clk, negedge nrst) begin
        if(nrst == 0) begin
            status_buffer = 0;       
        end else begin
            status_buffer = stat_buf_nxt;
        end
    end

    always_comb begin                                   //comb block to handle next state logic
        stat_buf_nxt = status_buffer;
        if(DB0_C) stat_buf_nxt[0] = DB_in[0];           //handle inputs from DB
        if(DB1_Z) stat_buf_nxt[1] = DB_in[1];
        if(DB2_I) stat_buf_nxt[2] = DB_in[2];
        if(DB3_D) stat_buf_nxt[3] = DB_in[3];
        if(DB6_V) stat_buf_nxt[6] = DB_in[6];
        if(DB7_N) stat_buf_nxt[7] = DB_in[7];

        if(manual_C) stat_buf_nxt[0] = manual_set;      //handle manual set on certain flags
        if(manual_D) stat_buf_nxt[3] = manual_set;
        if(manual_I) stat_buf_nxt[2] = manual_set;

        if(carry_C) stat_buf_nxt[0] = carry;            //misc cases and direct sets and clears
        if(DBall_Z) stat_buf_nxt[1] = ~(DB_in != 0);
        if(overflow_V) stat_buf_nxt[6] = overflow;
        if(rcl_V) stat_buf_nxt[6] = 1'b1;
        if(break_set) 
        begin
            stat_buf_nxt[4] = 1'b1; //If the break flag is set, set it high before writing
            stat_buf_nxt[5] = 1'b1; //If the break flag is set, set it high before writing
        end
    end

    // Set Final outputs
    assign PSR_Output = status_buffer;

endmodule