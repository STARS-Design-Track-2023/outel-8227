module programCounterLogic (
    input logic [7:0] input_lowbyte, input_highbyte,        //components of 16-bit address to be given to PC
    input logic increment, decrement,                       //control flags for modiflying address
    output logic [7:0] output_lowbyte, output_highbyte      //address output of the PC
);

    logic [15:0] address;
    assign address = {input_highbyte, input_lowbyte}; //inputs are operated on as a whole
    

    logic [15:0] nextAddress;
    always_comb begin
        if(increment) nextAddress = address + 1;
        else if(decrement) nextAddress = address - 1;
        else nextAddress = address;
    end

    assign output_lowbyte = nextAddress[7:0];
    assign output_highbyte = nextAddress[15:8];
endmodule
