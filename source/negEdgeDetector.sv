module negEdgeDetector (
  input logic clk, nrst, enableFFs,
  input logic in,
  output logic out
);

  logic q1, nextQ1;

  always_comb begin : nextStateLogic
    if(enableFFs)
      nextQ1 = in;
    else
      nextQ1 = q1;
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

  assign out = q1 & ~in;

endmodule