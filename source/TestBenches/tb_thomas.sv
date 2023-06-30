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
  logic [7:0]          tb_dataBusOutput;
  logic [7:0]          tb_dataBusInput;
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

    //Clk 3
    @(negedge tb_clk);

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
    tb_dataBusInput = 8'HDD;
    @(posedge tb_clk);
    test_name = "Boot Seq clk 6";

    //Clk 7
    @(negedge tb_clk);
    tb_dataBusInput = 8'HCC;
    @(posedge tb_clk);
    test_name = "Boot Seq clk 7";
    @(negedge tb_clk);
  end
  endtask

  task StoreACC;
    tb_dataBusInput = 8'HA9; //Put the opcode for the next instruction here
    @(posedge tb_clk);
    test_name = "Get data";
    @(negedge tb_clk);
    tb_dataBusInput = 8'H10; //Put the opcode for the next instruction here
    @(posedge tb_clk);
    test_name = "store and Next Opcode";
    @(negedge tb_clk);
  endtask

  task PushACC;
    tb_dataBusInput = 8'H48; //Put the opcode for the next instruction here
    @(posedge tb_clk);
    test_name = "PUSH ACC";
    @(negedge tb_clk);
    @(negedge tb_clk);
    @(negedge tb_clk);
    
  endtask

  // DUT Portmap
  top8227 top8227 (
    .clk(tb_clk), 
    .nrst(tb_nrst), 
    .nonMaskableInterrupt(tb_nonMaskableInterrupt), 
    .interruptRequest(tb_interruptRequest),
    .dataBusInput(tb_dataBusInput),
    .dataBusOutput(tb_dataBusOutput),
    .AddressBusHigh(tb_addressBusHigh),
    .AddressBusLow(tb_addressBusLow)
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
    StoreACC();
    PushACC();

    test_name = "Finishing";
    @(negedge tb_clk);

    //Wait a bit and end the simulation
    #(CLK_PERIOD*2);
    $display("Simulation complete");
    $stop;
  end

endmodule