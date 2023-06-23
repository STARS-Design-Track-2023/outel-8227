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

    always_comb begin
        if()
    end
endmodule