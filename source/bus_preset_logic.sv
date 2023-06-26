module busPreset(
    input logic set_FF,
    input logic set_FE,
    input logic set_FD,
    input logic set_FC,
    input logic set_FB,
    input logic set_FA,
    input logic set_00,
    input logic set_01,
    output logic [7:0] bus_out
);

    always_comb begin
        bus_out = 8'b00000000;
        if(set_FF) bus_out = 8'b11111111;
        if(set_FE) bus_out = 8'b11111110;
        if(set_FD) bus_out = 8'b11111101;
        if(set_FC) bus_out = 8'b11111100;
        if(set_FB) bus_out = 8'b11111011;
        if(set_FA) bus_out = 8'b11111010;
        if(set_00) bus_out = 8'b00000000;
        if(set_01) bus_out = 8'b00000001;
    end
endmodule
