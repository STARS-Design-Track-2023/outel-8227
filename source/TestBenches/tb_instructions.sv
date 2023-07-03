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
  logic                tb_functionalClockOut;
  logic                tb_dataBusSelect;
  logic                tb_M10ClkOut;

  logic [7:0]          targetLowAddress;
  logic [7:0]          targetHighAddress;

  logic [524287:0]          memory;

  always_comb begin : memoryAssignment
    memory = 0;

    //Reset Pointer
    memory[8*16'HFFFC+:8] = 8'HF0;//ADL of reset pointer
    memory[8*16'HFFFD+:8] = 8'HCC;//ADH of reset Pointer
    //Start with CCDD after this

    //IRQ/BRK Pointer
    memory[8*16'HFFFE+:8] = 8'H00;//ADL of reset pointer
    memory[8*16'HFFFF+:8] = 8'HBB;//ADH of reset Pointer
    //Start with BB00 after this

    //NMI Pointer
    memory[8*16'HFFFA+:8] = 8'H00;//ADL of reset pointer
    memory[8*16'HFFFB+:8] = 8'HAA;//ADH of reset Pointer
    //Start with AA00 after this

    //NMI Procedure
    memory[8*16'HAA00+:8] = 8'H58;//CLI
    memory[8*16'HAA01+:8] = 8'HA9;
    memory[8*16'HAA02+:8] = 8'H22;
    memory[8*16'HAA03+:8] = 8'H40;


    //IRQ Procedure
    memory[8*16'HBB00+:8] = 8'H18;//CLC
    memory[8*16'HBB01+:8] = 8'HF8;//SED
    memory[8*16'HBB02+:8] = 8'HEA;//NOP
    memory[8*16'HBB03+:8] = 8'HEA;//NOP
    memory[8*16'HBB04+:8] = 8'HEA;//NOP
    memory[8*16'HBB05+:8] = 8'H40;//RTI


    //Normal Reset procedure
    memory[8*16'HCCF0+:8] = 8'H58;//CLI
    memory[8*16'HCCF1+:8] = 8'HA9;//SEC
    memory[8*16'HCCF2+:8] = 8'H80;//SED
    memory[8*16'HCCF3+:8] = 8'H69;//Loop
    memory[8*16'HCCF4+:8] = 8'H80;//Set Overflow
    memory[8*16'HCCF5+:8] = 8'HEA;//Loop
    memory[8*16'HCCF6+:8] = 8'HB8;//Loop
    memory[8*16'HCCF7+:8] = 8'HCC;//Loop


  end

  assign tb_dataBusInput = memory[8*(256*tb_AddressBusHigh + tb_AddressBusLow) +:8];
  //Memory loop
  always_ff @(negedge tb_clk) begin
    //Update the memory on negative clock edges
    if(~tb_readNotWrite)
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
    .addressBusHigh(tb_AddressBusHigh),
    .addressBusLow(tb_AddressBusLow),
    .dataBusEnable(tb_dataBusEnable),
    .ready(tb_ready),
    .sync(tb_sync), 
    .readNotWrite(tb_readNotWrite),
    .setOverflow(tb_setOverflow),
    .functionalClockOut(tb_functionalClockOut),
    .dataBusSelect(tb_dataBusSelect),
    .M10ClkOut(tb_M10ClkOut)
  );

  // Signal Dump
  initial begin
    $dumpfile ("dump.vcd");
    $dumpvars;
  end
  
  // Test Cases
  initial begin
    test_name = "Reset";
    tb_interruptRequest = 1'b1;
    tb_nonMaskableInterrupt = 1'b1;
    reset_dut();

    // Initialize all of the test inputs
    tb_nrst             = 1'b1; // Initialize to be inactive

    // Wait some time before starting first test case
    #(0.1);
    @(negedge tb_clk);
    targetLowAddress = 8'bx;
    targetHighAddress = 8'bx;

    tb_ready = 1'b1;
    tb_setOverflow = 1'b1;
    tb_dataBusEnable = 1'b1;
    
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
//----------------------------------------LDA, ZPG--------------------------------------------
//--------------------------------------------------------------------------------------------    

    //Clk 0
    @(negedge tb_clk);
    //tb_dataBusInput = 8'HA5;//Put the opcode for LDA, ZPG on the data bus
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

    tb_interruptRequest = 1'b0;
    for(int i = 0; i < 25; i++)
    begin
      //Clk 1
      @(negedge tb_clk);
      //tb_dataBusInput = 8'H88;//Put the value at in memory @ 0099
      @(posedge tb_clk);
    end
    tb_interruptRequest = 1'b1;

    tb_nonMaskableInterrupt = 1'b0;
    for(int i = 0; i < 5; i++)
    begin
      //Clk 1
      @(negedge tb_clk);
      //tb_dataBusInput = 8'H88;//Put the value at in memory @ 0099
      @(posedge tb_clk);
    end
    tb_nonMaskableInterrupt = 1'b1;


    for(int i = 0; i < 200; i++)
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