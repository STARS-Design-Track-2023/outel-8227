`timescale 1ns/10ps

module tb_8227_template ();

  localparam CLK_PERIOD        = 2;

  // Information signals
  logic [1024:0]       test_name;

  // Declare DUT Connection Signals
  logic                tb_clk;
  logic                tb_nrst;
  logic                tb_nonMaskableInterrupt;
  logic                tb_interruptRequest;
  logic [7:0]          tb_dataBusInput;
  logic [7:0]          tb_dataBusOutput;
  logic [7:0]          tb_AddressBusHigh;
  logic [7:0]          tb_AddressBusLow;

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

  // DUT Portmap
  top8227 top8227 (
    .clk(tb_clk), 
    .nrst(tb_nrst), 
    .nonMaskableInterrupt(tb_nonMaskableInterrupt), 
    .interruptRequest(tb_interruptRequest),
    .dataBusInput(tb_dataBusInput),
    .dataBusOutput(tb_dataBusOutput),
    .AddressBusHigh(tb_AddressBusHigh),
    .AddressBusLow(tb_AddressBusLow)
  );

  // Signal Dump
  initial begin
    $dumpfile ("dump.vcd");
    $dumpvars;
  end
  
  // Test Cases
  initial begin
    assign test_name = "Reset";
    reset_dut();

    // Initialize all of the test inputs
    tb_nrst             = 1'b1; // Initialize to be inactive

    // Wait some time before starting first test case
    #(0.1);
    @(negedge tb_clk);

//--------------------------------------------------------------------------------------------
//----------------------------------------Example Test----------------------------------------
//--------------------------------------------------------------------------------------------

    assign test_name = "Example Test";

    //Clock Cycle 1
    assign tb_nonMaskableInterrupt = 1'b0;
    assign tb_interruptRequest = 1'b0;
    assign tb_dataBusInput = 8'b0;
    @(negedge tb_clk);

    //Clock Cycle 2
    assign tb_nonMaskableInterrupt = 1'b0;
    assign tb_interruptRequest = 1'b0;
    assign tb_dataBusInput = 8'b0;
    @(negedge tb_clk);

//--------------------------------------------------------------------------------------------
//------------------------------------End Example Test----------------------------------------
//--------------------------------------------------------------------------------------------

    @(negedge tb_clk);

    //Wait a bit and end the simulation
    #(CLK_PERIOD*2);
    $display("Simulation complete");
    $stop;
  end

endmodule