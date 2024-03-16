`timescale 1ns/10ps
module challenge
(
  input  wire  [2:0]    SW,
  output logic [1:0]    LED
  );

 // SW[2] is carry in
 // SW[1] is A
 // SW[0] is B
 assign LED[0]  = SW[0] ^ SW[1] ^ SW[2]; // Write the code for the Sum
 assign LED[1]  = (SW[0] && SW[1]) || (SW[0] && SW[2]) || (SW[1] && SW[2]); // Write the code for the Carry
endmodule // challenge
