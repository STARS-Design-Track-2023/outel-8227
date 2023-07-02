module bridge(
  input logic [7:0] bus1Input, bus2Input, bus3Input,
  output logic [7:0] bus1Output, bus2Output, bus3Output,
  input logic open2To1, open1To2, open2To3, open3To2
);

  always_comb begin
    bus1Output = bus1Input;
    bus2Output = bus2Input;
    bus3Output = bus3Input;
    case({open2To1,open1To2,open2To3,open3To2})
      4'b0001:
      begin
        bus2Output = bus3Input;
      end
      4'b0010:
      begin
        bus3Output = bus2Input;
      end
      4'b0100:
      begin
        bus2Output = bus1Input;
      end
      4'b0110:
      begin
        bus2Output = bus1Input;
        bus3Output = bus1Input;
      end
      4'b1000:
      begin
        bus1Output = bus2Input;
      end
      4'b1001:
      begin
        bus2Output = bus3Input;
        bus1Output = bus3Input;
      end
      4'b1010:
      begin
        bus1Output = bus2Input;
        bus3Output = bus2Input;
      end
      default:
      begin
        bus1Output = bus1Input;
        bus2Output = bus2Input;
        bus3Output = bus3Input;
      end
    endcase
    
    if(open2To1)
      bus1Output=bus2Input;
    else if(open1To2)
      bus2Output=bus1Input;
  end

endmodule
