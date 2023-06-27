`timescale 1ns/10ps

module tb_shift_reg ();

  localparam CLK_PERIOD        = 2;

  // Information signals
  logic [1024:0]       test_name;

  // Declare DUT Connection Signals
  logic                tb_clk;
  logic                tb_nrst;
  logic [100:0]        tb_flags;
  logic [7:0]          tb_externalDBRead;
  logic [7:0]          tb_externalDBWrite;
  logic [7:0]          tb_externalAddressBusLowOutput;
  logic [7:0]          tb_externalAddressBusHighOutput;

  // Clock generation block
  always begin
    // Start with clock low to avoid false rising edge events at t=0
    tb_clk = 1'b0;
    // Wait half of the clock period before toggling clock value (maintain 50% duty cycle)
    #(CLK_PERIOD/2.0);
    tb_clk = 1'b1;
    // Wait half of the clock period before toggling clock value via rerunning the block (maintain 50% duty cycle)
    #(CLK_PERIOD/2.0);
  end

  // Task for standard DUT reset procedure
  task reset_dut;
  begin
    // Activate the reset
    tb_nrst = 1'b0;

    // Maintain the reset for more than one cycle
    @(posedge tb_clk);
    @(posedge tb_clk);

    // Wait until safely away from rising edge of the clock before releasing
    @(negedge tb_clk);
    tb_nrst = 1'b1;

    // Leave out of reset for a couple cycles before allowing other stimulus
    // Wait for negative clock edges, 
    // since inputs to DUT should normally be applied away from rising clock edges
    @(negedge tb_clk);
    @(negedge tb_clk);
  end
  endtask

  //Set all the flags low so that the test can set specific flags high
  task reset_flags;
  begin
    assign tb_flags = 101'b0;
  end
  endtask

  // DUT Portmap
  internalDataflow dataflow(
    .nrst(tb_nrst),
    .clk(tb_clk),
    .flags(tb_flags),
    .externalDBRead(tb_externalDBRead),
    .externalDBWrite(tb_externalDBWrite),
    .externalAddressBusLowOutput(tb_externalAddressBusLowOutput),
    .externalAddressBusHighOutput(tb_externalAddressBusHighOutput)
);

  // Signal Dump
  initial begin
    $dumpfile ("dump.vcd");
    $dumpvars;
  end
  
  // Test Cases
  initial begin
    assign test_name = "Reset";
    reset_flags();
    reset_dut();

    // Initialize all of the test inputs
    tb_nrst             = 1'b1; // Initialize to be inactive

    // Wait some time before starting first test case
    #(0.1);

    assign test_name = "Load X Register and ABH Reg";
    @(negedge tb_clk);
    reset_flags();
    assign tb_flags[SET_ADH_TO_DATA] = 1;
    assign tb_flags[LOAD_ABH] = 1;
    assign tb_flags[SET_SB_TO_ADH] = 1;
    assign tb_flags[LOAD_X] = 1;
    assign tb_externalDBRead = 8'b10101010;

    assign test_name = "Load Acc Register and clear DB";
    @(negedge tb_clk);
    reset_flags();
    assign tb_externalDBRead = 8'b0;
    assign tb_flags[SET_SB_TO_X] = 1;
    assign tb_flags[LOAD_ACC] = 1;

    assign test_name = "Load DOR from ACC";
    @(negedge tb_clk);
    reset_flags();
    assign tb_flags[SET_DB_TO_ACC] = 1;
    assign tb_flags[LOAD_DOR] = 1;

    @(negedge tb_clk);
    reset_flags();

    //Wait a bit and end the simulation
    #(CLK_PERIOD*2);
    $display("Simulation complete");
    $stop;
  end

endmodule