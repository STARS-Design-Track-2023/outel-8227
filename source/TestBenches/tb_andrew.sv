`timescale 1ns/10ps

module tb_andrew ();

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

  logic [7:0]          targetLowAddress;
  logic [7:0]          targetHighAddress;

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
    test_name = "Reset";
    reset_dut();

    // Initialize all of the test inputs
    tb_nrst             = 1'b1; // Initialize to be inactive

    // Wait some time before starting first test case
    #(0.1);
    @(negedge tb_clk);
    targetLowAddress = 8'bx;
    targetHighAddress = 8'bx;
//--------------------------------------------------------------------------------------------
//-----------------------------------------RESET----------------------------------------------
//--------------------------------------------------------------------------------------------

    @(posedge tb_clk);
    test_name = "Boot Up sequence Reset";

    tb_nrst = 1'b0;
    @(negedge tb_clk);
    @(negedge tb_clk);

    //Clk 0
    @(negedge tb_clk);
    tb_nrst = 1'b1;
    @(posedge tb_clk);
    test_name = "Boot Seq clk 0";

    //Clk 1
    @(negedge tb_clk);
    tb_nrst = 1'b1;
    @(posedge tb_clk);
    test_name = "Boot Seq clk 1";

    //Clk 2
    @(negedge tb_clk);

    @(posedge tb_clk);
    test_name = "Boot Seq clk 2";

    //Clk 3
    @(negedge tb_clk);

    @(posedge tb_clk);
    test_name = "Boot Seq clk 3";

    //Clk 4
    @(negedge tb_clk);

    @(posedge tb_clk);
    test_name = "Boot Seq clk 4";
    
    //Clock Cycle 1
    tb_nonMaskableInterrupt = 1'b0;
    tb_interruptRequest = 1'b0;
    tb_dataBusInput = 8'Hxx;
    @(negedge tb_clk);
    targetLowAddress = 8'bx;
    targetHighAddress = 8'b00;

    @(negedge tb_clk);
    // @(negedge tb_clk);
    // @(negedge tb_clk);
    // @(negedge tb_clk);


//--------------------------------------------------------------------------------------------
//----------------------------------------EOR, ABSX--------------------------------------------
//--------------------------------------------------------------------------------------------

    @(posedge tb_clk);
    test_name = "EOR ABS,X";

    //Clock Cycle 1
    tb_nonMaskableInterrupt = 1'b0;
    tb_interruptRequest = 1'b0;
    tb_dataBusInput = 8'h5D;//Put the opcode for EOR ABS,X on the data bus
    // targetLowAddress = 8'bx;
    // targetHighAddress = 8'b00;
    @(posedge tb_clk);
    //Clock Cycle 2
    tb_nonMaskableInterrupt = 1'b0;
    tb_interruptRequest = 1'b0;
    tb_dataBusInput = 8'h42;//Put the low address of the absolute address onto the data bus
    targetLowAddress = 8'h00;
    targetHighAddress = 8'h00;
    @(posedge tb_clk);
    //Clock Cycle 3
    tb_nonMaskableInterrupt = 1'b0;
    tb_interruptRequest = 1'b0;
    tb_dataBusInput = 8'h53;//Put the page of the absolute address onto the data bus
    targetLowAddress = 8'h42;
    targetHighAddress = 8'h00;
    @(posedge tb_clk);
    //Clock Cycle 4
    tb_nonMaskableInterrupt = 1'b0;
    tb_interruptRequest = 1'b0;
    tb_dataBusInput = 8'hF0;//Put the value to be XOR'd onto the data bus
    targetLowAddress = 8'h42;
    targetHighAddress = 8'h53;
    @(posedge tb_clk);
    //Clock Cycle 5
    tb_nonMaskableInterrupt = 1'b0;
    tb_interruptRequest = 1'b0;
    //_interruptRequest = 1'b0;
    targetLowAddress = 8'h42;
    targetHighAddress = 8'h53;
    @(posedge tb_clk);

//--------------------------------------------------------------------------------------------
//------------------------------------End Example Test----------------------------------------
//--------------------------------------------------------------------------------------------

    test_name = "Finishing";
    @(negedge tb_clk);

    //Wait a bit and end the simulation
    #(CLK_PERIOD*2);
    $display("Simulation complete");
    $stop;
  end

endmodule