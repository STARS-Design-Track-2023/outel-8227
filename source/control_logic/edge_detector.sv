module edgeDetector(
    input logic clk, nrst,
    input logic in,
    output logic out
);

    logic lastIn;

    always_comb begin
        out = ~lastIn & in;
    end

    always_ff @(posedge clk, negedge nrst) begin
        if(~nrst)
        begin
            lastIn = 1'b0;
        end
        else
        begin
            lastIn = in;
        end
    end

endmodule