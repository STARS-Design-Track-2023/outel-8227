module programCL(
    input logic [7:0] ADL_in,               //address bus low input
    input logic nrst, clk,                  //clock and async reset
    input logic PCL_PCL,                    //flag: enables read to self
    input logic ADL_PCL,                    //flag: enables read from ABL
    input logic PCL_DB,                     //flag: enables write to DB
    input logic PCL_ADL,                    //flag: enables write to ADL
    input logic increment, decrement,       //flag: tells increment/decrement logic to trigger
    output logic [7:0] DB_out, ADL_out,     //data bus outputs for PCL
    output logic PCLC                       //flag: represents the carry out to PCH
);

    logic [7:0] PCL_internal, PCL_internal_next;   //internal register that stores the current PCL
    always_ff @ (posedge clk, negedge nrst) begin
        if(nrst == 0) begin
            PCL_internal = 0;
        end else begin
            PCL_internal = PCL_internal_next;
        end
    end

    //next state logic
    always_comb begin
        PCL_internal_next = PCL_internal;

        if(increment && PCL_PCL) PCL_internal_next = PCL_internal + 1;
        if(decrement && PCL_PCL) PCL_internal_next = PCL_internal - 1;
        if(ADL_PCL) PCL_internal_next = ADL_in;
    end

    //output logic
    always_comb begin
        DB_out = 8'bzzzzzzzz;     //output defaults to hi-Z
        ADL_out = 8'bzzzzzzzz;
        PCLC = 0;

        if(PCL_DB) DB_out = PCL_internal;
        if(PCL_ADL) ADL_out = PCL_internal;

        if(decrement && (PCL_internal == 8'b00000000))   //ines to handle carry for page shifts
            PCLC = 1;
        if(increment && (PCL_internal == 8'b11111111))
            PCLC = 1;
    end
endmodule