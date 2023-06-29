/*
    tb_linear.v

    Author: Spencer B

    Description:
        A linearized testbench for a verilog model of the 6502.
        Includes a module to simulate memory mapped io.
*/

// `ifdef REPLACE_WITH_CORRECT
//     `include "source/top8227.sv"
// `endif 

`include "source/top8227.sv"
`include "source/ref/cpu.v"

`timescale 1ns/100ps
`define CLK_PERIOD 100

`define DATA_BUS_WIDTH_CONST 8
`define ADDR_BUS_WIDTH_CONST 16

`define RAM_SIZE 32762
`define RAM_DELAY_NS 150
`define RAM_MEMORY_MAP 16'b0???_????_????_????

`define ROM_SIZE 32762
`define ROM_DELAY_NS 50
`define ROM_MEMORY_MAP 16'b1???_????_????_????

module moduleName ();

    //////////////////////////
    // TESTBENCH PARAMETERS //
    //////////////////////////

    ///////////////////////
    // TESTBENCH SIGNALS //
    ///////////////////////

    //////////
    // DUTs //
    //////////

    
    top8227 top8227 (
        .clk(tb_clk), 
        .nrst(tb_nrst), 
        .nonMaskableInterrupt(tb_nmi), 
        .interruptRequest(tb_irq), 
        .dataBusInput(tb_db_in),
        .dataBusOutput(tb_db_out),
        .AddressBusHigh(tb_addr_h),
        .AddressBusLow(tb_addr_l)
    );

    ref_cpu ref_cpu (
        .clk(tb_clk),                // CPU clock 
        .reset(~tb_nrst),            // reset signal
        .AB(ref_addr),               // address bus
        .DI(ref_db_in),              // data in, read bus
        .DO(ref_db_out),             // data out, write bus
        .WE(reg_we),                 // write enable
        .IRQ(ref_irq),               // interrupt request
        .NMI(reg_nmi),               // non-maskable interrupt request
        .RDY(ref_rdy)                // Ready signal. Pauses CPU when RDY=0 
    );


endmodule

module two_port_memory_mapped_io #(
    parameter DATA_BUS_WIDTH = `DATA_BUS_WIDTH_CONST,
    parameter ADDR_BUS_WIDTH = `ADDR_BUS_WIDTH_CONST
) (
    inout wire [DATA_BUS_WIDTH-1:0] data_in,
    input wire [ADDR_BUS_WIDTH-1:0] addr_bus,
    input wire n_write,
    output reg [DATA_BUS_WIDTH-1:0] read_data
);
    
    reg [DATA_BUS_WIDTH - 1:0] mem [0:2**ADDR_BUS_WIDTH - 1];
    

    // INITIALIZE ROM
    // initial begin
    //  // TODO
    //  //
    // end

    always @(*) begin : MEM_WRITE
        if (~n_write) begin
            casez (addr_bus)
                `ROM_MEMORY_MAP: $error("CANNOT WRITE TO ROM"); 
                `RAM_MEMORY_MAP: #(`RAM_DELAY_NS);
                default: $error("MISSED MEMORY MAP ON WRITE");
            endcase

            mem[addr_bus] = data_in;
        end
    end

    always @(*) begin : MEM_READ
        if (n_write) begin
            casez (addr_bus)
                `ROM_MEMORY_MAP: #(`ROM_DELAY_NS); 
                `RAM_MEMORY_MAP: #(`RAM_DELAY_NS);
                default: $error("MISSED MEMORY MAP ON READ");
            endcase

            read_data = mem[addr_bus];
        end
    end

endmodule

/*
module bi_dir_memory_mapped_io #(
    parameter DATA_BUS_WIDTH = `DATA_BUS_WIDTH_CONST,
    parameter ADDR_BUS_WIDTH = `ADDR_BUS_WIDTH_CONST
) (
    inout wire [DATA_BUS_WIDTH-1:0] data_bus,
    input wire [ADDR_BUS_WIDTH-1:0] addr_bus,
    input wire n_write
);
    
    reg [DATA_BUS_WIDTH - 1:0] mem [0:2**ADDR_BUS_WIDTH - 1];
    reg [DATA_BUS_WIDTH-1:0] read_data
    

    // INITIALIZE ROM
    // initial begin
    //  // TODO
    //  //
    // end

    // Tri-state buffer
    // outputs when n_write = 0
    assign data_bus = (n_write) ? read_data : 'bZ;

    always @(*) begin : MEM_WRITE
        if (~n_write) begin
            casez (addr_bus)
                `ROM_MEMORY_MAP: $error("CANNOT WRITE TO ROM"); 
                `RAM_MEMORY_MAP: #(`RAM_DELAY_NS);
                default: $error("MISSED MEMORY MAP ON WRITE");
            endcase

            mem[addr_bus] = data_bus;
        end
    end

    always @(*) begin : MEM_READ
        if (n_write) begin
            casez (addr_bus)
                `ROM_MEMORY_MAP: #(`ROM_DELAY_NS); 
                `RAM_MEMORY_MAP: #(`RAM_DELAY_NS);
                default: $error("MISSED MEMORY MAP ON READ");
            endcase

            read_data = mem[addr_bus];
        end
    end

endmodule
*/
