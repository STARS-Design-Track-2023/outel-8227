module synchronizer (
    input logic in, nrst, clk, enableFFs,
    output logic out
);
    logic q1, q2, nextQ1, nextQ2;

    always_comb begin : nextStateLogic
        if(enableFFs)
        begin
            nextQ1 = in;
            nextQ2 = q1;
        end
        else
        begin
            nextQ1 = q1;
            nextQ2 = q2;
        end
    end

    always_ff @(posedge clk, negedge nrst) begin : nextStateAssignment
        if(~nrst)
        begin
            q1 = 1'b0;
            q2 = 1'b0;
        end
        else
        begin
            q1 = nextQ1;
            q2 = nextQ2;
        end
    end

    always_comb begin : outputLogic
        out = q2;
    end
endmodule