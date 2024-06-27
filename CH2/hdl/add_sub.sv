`timescale 1ns/10ps
module add_sub #(
  parameter SELECTOR = 0,
  parameter BITS = 16
) (
  input wire [BITS-1:0] SW,
  output logic signed [BITS-1:0] LED
);

typedef struct packed {
  logic signed [BITS/2-1:0] a_in;
  logic signed [BITS/2-1:0] b_in;
} InputData;

InputData input_data;

always_comb begin
  input_data.a_in = SW[BITS-1:BITS/2];
  input_data.b_in = SW[BITS/2-1:0];
  if (SELECTOR == "ADD") 
    LED = input_data.a_in + input_data.b_in;
  else
    LED = input_data.a_in - input_data.b_in;
end

endmodule
