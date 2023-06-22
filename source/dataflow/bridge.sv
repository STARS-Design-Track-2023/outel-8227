module bridge(
    input logic [7:0] input1, input2,
    output logic [7:0] output1, output2,
    input logic setSide1ToSide2, setSide2ToSide1
);

    busInterface busInterface(.interfaceInput(input1), .enable(setSide2ToSide1), .interfaceOutput(output2));
    busInterface busInterface(.interfaceInput(input2), .enable(setSide1ToSide2), .interfaceOutput(output1));

endmodule