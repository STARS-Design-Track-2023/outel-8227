module bridge (
    input [7:0] inputSide1, inputSide2,
    output [7:0] out,
    input direction
);
    assign out = (direction)?inputSide1:inputSide2;
endmodule