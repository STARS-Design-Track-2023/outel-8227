module posEdgeDetector (
  input logic clk, nrst,
  input logic in,
  output logic out
);

  logic q1, nextQ1;

  always_comb begin : nextStateLogic
    nextQ1 = in;
  end

  always_ff @( posedge clk, negedge nrst ) begin : nextStateAssignment
    if(~nrst)
    begin
      q1 <= 1'b0;
    end
    else
    begin
      q1 <= nextQ1;

    end
  end

  assign out = ~q1 & in;

endmodule