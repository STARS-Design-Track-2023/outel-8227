`timescale 1ns/10ps

module tb_internalDataflow ();

  localparam CLK_PERIOD        = 2;

  // Information signals
  logic [1024:0]       test_name;
  logic tb_mismatch;

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

    //   task check_outputs_4;
    // input logic[7:0] exp_xreg, exp_yreg, exp_acc; 
    // begin
    //     tb_mismatch = 0;
    //     @(negedge tb_clk); 
    //     if(exp_xreg != tb) begin
    //         tb_mismatch = 1;
    //         $error("Incorrect tb_count_4 value. Actual: %0d, Expected: %0d.", tb_count_4, exp_count); 
    //     end 
    //     else 
    //         $info("Correct tb_count_4 value."); 
        
    //     if(exp_at_max != tb_at_max_4) begin 
    //         tb_mismatch = 1;
    //         $error("Incorrect tb_at_max_4 value. Actual: %0d, Expected: %0d.", tb_at_max_4, exp_at_max); 
    //     end 
    //     else 
    //         $info("Correct tb_at_max_4 value.");

    // end
    // endtask 

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

    assign test_name = "Load Y from ACC";
    @(negedge tb_clk);
    reset_flags();
    assign tb_flags[SET_SB_TO_ACC] = 1;
    assign tb_flags[LOAD_Y] = 1;

    assign test_name = "Load ACC from Y";
    @(negedge tb_clk);
    reset_flags();
    assign tb_flags[SET_SB_TO_Y] = 1;
    assign tb_flags[LOAD_ACC] = 1;

    assign test_name = "Increment Program Counter"; 
    @(negedge tb_clk);
    reset_flags();
    assign tb_flags[PC_INC] = 1;

    assign test_name = "Decrement Program Counter";
    @(negedge tb_clk);
    reset_flags();
    assign tb_flags[PC_DEC] = 1;

    assign test_name = "Load into Program Counter from Input";
    @(negedge tb_clk);
    reset_flags();
    assign tb_externalDBRead = 8'b00000000;
    assign tb_flags[LOAD_PC] = 1;
    assign tb_flags[SET_ADL_TO_DATA] = 1;
    assign tb_flags[SET_ADH_TO_DATA] = 1;

    assign test_name = "Load and Increment PC";
    @(negedge tb_clk);
    reset_flags();
    assign tb_flags[LOAD_PC] = 1;
    assign tb_flags[PC_INC] = 1;
    assign tb_flags[SET_ADL_TO_DATA] = 1;
    assign tb_flags[SET_ADH_TO_DATA] = 1;

    assign test_name = "Load and Decrement PC";
    @(negedge tb_clk);
    reset_flags();
    assign tb_flags[LOAD_PC] = 1;
    assign tb_flags[PC_DEC] = 1;
    assign tb_flags[SET_ADL_TO_DATA] = 1;
    assign tb_flags[SET_ADH_TO_DATA] = 1;

    assign test_name = "Load ABH and ADH from PC";
    @(negedge tb_clk);
    reset_flags();
    assign tb_flags[SET_ADH_TO_PCH] = 1;
    assign tb_flags[SET_ADL_TO_PCL] = 1;
    assign tb_flags[LOAD_ABH] = 1;
    assign tb_flags[LOAD_ABL] = 1;

    assign test_name = "Preset ADH";
    @(negedge tb_clk);
    reset_flags();
    assign tb_flags[SET_ADH_FF] = 1;

    assign test_name = "Store PCH in Stack";
    @(negedge tb_clk);
    reset_flags();
    assign tb_flags[SET_ADH_TO_PCH] = 1;
    assign tb_flags[SET_SB_TO_ADH] = 1;
    assign tb_flags[LOAD_SP] = 1;

    assign test_name = "Add Data with ALU";
    @(negedge tb_clk);
    reset_flags();
    assign tb_externalDBRead = 8'b00000001;
    assign tb_flags[SET_DB_TO_DATA] = 1;
    assign tb_flags[SET_INPUT_B_TO_DB] = 1;
    assign tb_flags[SET_INPUT_A_TO_SB] = 1;
    assign tb_flags[SET_SB_TO_ACC] = 1;
    assign tb_flags[ALU_ADD] = 1;
    assign tb_flags[LOAD_ALU] = 1;

    assign test_name = "Process Reg from DB";
    @(negedge tb_clk);
    reset_flags();
    assign tb_flags[SET_PSR_C_TO_DB0] = 1;
    assign tb_flags[SET_PSR_Z_TO_DB1] = 1;
    assign tb_flags[SET_PSR_I_TO_DB2] = 1;
    assign tb_flags[SET_PSR_D_TO_DB3] = 1;
    assign tb_flags[SET_PSR_V_TO_DB6] = 1;
    assign tb_flags[SET_PSR_N_TO_DB7] = 1;
    assign tb_flags[SET_SB_TO_ALU] = 1;
    assign tb_flags[SET_DB_TO_SB] = 1;

    assign test_name = "Process Reg zeros";
    @(negedge tb_clk);
    reset_flags();
    assign tb_externalDBRead = 8'b00000000;
    assign tb_flags[SET_DB_TO_DATA] = 1;
    assign tb_flags[SET_PSR_C_TO_DB0] = 1;
    assign tb_flags[SET_PSR_Z_TO_DB1] = 1;
    assign tb_flags[SET_PSR_I_TO_DB2] = 1;
    assign tb_flags[SET_PSR_D_TO_DB3] = 1;
    assign tb_flags[SET_PSR_V_TO_DB6] = 1;
    assign tb_flags[SET_PSR_N_TO_DB7] = 1;

    assign test_name = "Process Reg interrupt and manual sets";
    @(negedge tb_clk);
    reset_flags();
    assign tb_flags[PSR_DATA_TO_LOAD] = 1;
    assign tb_flags[LOAD_CARRY_PSR_FLAG] = 1;
    assign tb_flags[LOAD_DECIMAL_PSR_FLAG] = 1;
    assign tb_flags[LOAD_INTERUPT_PSR_FLAG] = 1;
    assign tb_flags[LOAD_OVERFLOW_PSR_FLAG] = 1;

    assign test_name = "Process Reg zeros";
    @(negedge tb_clk);
    reset_flags();
    assign tb_externalDBRead = 8'b00000000;
    assign tb_flags[SET_DB_TO_DATA] = 1;
    assign tb_flags[SET_PSR_C_TO_DB0] = 1;
    assign tb_flags[SET_PSR_Z_TO_DB1] = 1;
    assign tb_flags[SET_PSR_I_TO_DB2] = 1;
    assign tb_flags[SET_PSR_D_TO_DB3] = 1;
    assign tb_flags[SET_PSR_V_TO_DB6] = 1;
    assign tb_flags[SET_PSR_N_TO_DB7] = 1;

    @(negedge tb_clk);
    reset_flags();

    //Wait a bit and end the simulation
    #(CLK_PERIOD*2);
    $display("Simulation complete");
    $stop;
  end

endmodule