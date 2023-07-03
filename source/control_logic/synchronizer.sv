module synchronizer (
    input logic in, nrst, clk,
    output logic out
);
    logic q1, q2, nextQ1, nextQ2;

    always_comb begin : nextStateLogic
        nextQ1 = in;
        nextQ2 = q1;
    end

    always_ff @(posedge clk, negedge nrst) begin : nextStateAssignment
        if(~nrst)
        begin
            q1 <= 1'b0;
            q2 <= 1'b0;
        end
        else
        begin
            q1 <= nextQ1;
            q2 <= nextQ2;
        end
    end

    always_comb begin : outputLogic
        out = q2;
    end
endmodule
