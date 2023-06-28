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
  logic                tb_dataBusEnable;
  logic                tb_ready;
  logic                tb_sync; 
  logic                tb_readNotWrite;
  logic                tb_setOverflow;

  logic [7:0]          targetLowAddress;
  logic [7:0]          targetHighAddress;

  logic [524287:0]          memory;

  always_comb begin : memoryAssignment
    memory = 0;
    memory[8*16'HFFFC+:8] = 8'HDD;//ADL of reset pointer
    memory[8*16'HFFFD+:8] = 8'HCC;//ADH of reset Pointer
    
    memory[8*16'H0099+:8] = 8'H73;//memory to test lda,zpg      (30, 10)
    memory[8*16'HCCDD+:8] = 8'HA5;//program start
    memory[8*16'HCCDE+:8] = 8'H99;

    memory[8*16'HCCDF+:8] = 8'H85;//STA, ZPG (50)               (48, 10)
    memory[8*16'HCCE0+:8] = 8'H50;

  end

  //Memory loop
  always_ff @(negedge tb_clk) begin
    //Update the memory and databuses on negative clock edges
    if(tb_readNotWrite)
      tb_dataBusInput = memory[8*(256*tb_AddressBusHigh + tb_AddressBusLow) +:8];//8*(8*(tb_AddressBusHigh) + tb_AddressBusLow) +:8];
    else
      memory[8*(256*tb_AddressBusHigh + tb_AddressBusLow) +:8] = tb_dataBusOutput;
  end

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
    .AddressBusLow(tb_AddressBusLow),
    .dataBusEnable(tb_dataBusEnable), 
    .ready(tb_ready),
    .sync(tb_sync), 
    .readNotWrite(tb_readNotWrite),
    .setOverflow(tb_setOverflow)
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

    tb_ready = 1'b1;
    tb_setOverflow = 1'b0;
    
//--------------------------------------------------------------------------------------------
//-----------------------------------------RESET----------------------------------------------
//--------------------------------------------------------------------------------------------

    @(posedge tb_clk);
    test_name = "Boot Up sequence Reset";

    tb_nrst = 1'b0;
    @(negedge tb_clk);
    @(negedge tb_clk);

    //Clk 1
    @(negedge tb_clk);
    tb_nrst = 1'b1;
    @(posedge tb_clk);
    test_name = "Boot Seq clk 1";

    //Clk 2
    @(negedge tb_clk);

    @(posedge tb_clk);
    test_name = "Boot Seq clk 2";

    @(negedge tb_clk);
    tb_ready = 1'b0;
    @(negedge tb_clk);
    @(negedge tb_clk);
    @(negedge tb_clk);
    @(negedge tb_clk);
    

    //Clk 3
    @(negedge tb_clk);
    tb_ready = 1'b1;
    @(posedge tb_clk);
    test_name = "Boot Seq clk 3";

    //Clk 4
    @(negedge tb_clk);

    @(posedge tb_clk);
    test_name = "Boot Seq clk 4";

    //Clk 5
    @(negedge tb_clk);
    
    @(posedge tb_clk);
    test_name = "Boot Seq clk 5";

    //Clk 6
    @(negedge tb_clk);
    //tb_dataBusInput = 8'HDD;
    @(posedge tb_clk);
    test_name = "Boot Seq clk 6";

    //Clk 7
    @(negedge tb_clk);
    //tb_dataBusInput = 8'HCC;
    @(posedge tb_clk);
    test_name = "Boot Seq clk 7";

//--------------------------------------------------------------------------------------------
//----------------------------------------INX, impl--------------------------------------------
//--------------------------------------------------------------------------------------------    
    //Clk 0
    @(negedge tb_clk);
    tb_dataBusInput = 8'HE8;//Put the opcode for INX, impl on the data bus
    @(posedge tb_clk);
    test_name = "INX impl";

    //Clk 1
    @(negedge tb_clk);
    // wait, nothing is required here 
    @(posedge tb_clk);

    for(int i = 0; i < 100; i++)
    begin
      //Clk 1
      @(negedge tb_clk);
      tb_dataBusInput = 8'HA5;// loads in the next instruction
      @(posedge tb_clk);
    end
//--------------------------------------------------------------------------------------------
//----------------------------------------LDA, ZPG--------------------------------------------
//--------------------------------------------------------------------------------------------   
    //Clk 0
    @(negedge tb_clk);
    tb_dataBusInput = 8'HA5;//Put the opcode for LDA, ZPG on the data bus
    @(posedge tb_clk);
    test_name = "Program Start";

    //Clk 1
    @(negedge tb_clk);
    //tb_dataBusInput = 8'H99;//Put goal address on ZPG
    @(posedge tb_clk);

    for(int i = 0; i < 100; i++)
    begin
      //Clk 1
      @(negedge tb_clk);
      //tb_dataBusInput = 8'H88;//Put the value at in memory @ 0099
      @(posedge tb_clk);
    end

//--------------------------------------------------------------------------------------------
//----------------------------------------Next Instruction------------------------------------
//--------------------------------------------------------------------------------------------

    @(posedge tb_clk);
    test_name = "Next Opcode";

    //Clk 0
    @(negedge tb_clk);
    //tb_dataBusInput = 8'HA5;//Put the opcode for LDA, ZPG on the data bus
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