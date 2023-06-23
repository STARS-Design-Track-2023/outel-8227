module programCounterLogic (
    //components of 16-bit address to be given to PC
    input logic [7:0] input_lowbyte, input_highbyte,
    input logic increment, decrement,                       //control flags for modiflying address
    output logic [7:0] output_lowbyte, output_highbyte      //address output of the PC
);

    logic [15:0] address = {input_highbyte, input_lowbyte}; //inputs are operated on as a whole
    always_comb begin
        if(increment) address = address + 1;
        else if(decrement) address = address - 1;
        else address = address;
    end

    assign output_lowbyte = address[7:0];
    assign output_highbyte = address[15:8];

endmodule
