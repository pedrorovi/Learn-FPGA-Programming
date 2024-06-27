`timescale 1ns / 10ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 06/27/2024 03:35:00 PM
// Design Name:
// Module Name: add_to_ch2_update_seven_display
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module add_to_ch2_update_seven_display(
    #
    (
      parameter SELECTOR,
      parameter BITS      = 16
      parameter NUM_SEGMENTS = 8,
      parameter CLK_PER      = 10,  // Clock period in ns
      parameter REFR_RATE    = 1000 // Refresh rate in Hz
    )
    (
      input wire [BITS-1:0]          SW,
      input wire                     BTNC,
      input wire                     BTNU,
      input wire                     BTNL,
      input wire                     BTNR,
      input wire                     BTND,

      output logic signed [BITS-1:0] LED,

      input wire                         CLK,
      input wire [NUM_SEGMENTS-1:0][3:0] ENCODED,
      input wire [NUM_SEGMENTS-1:0]      DIGIT_POINT,
      output logic [7:0]                 CATHODE
    );

    logic [$clog2(BITS):0] LO_LED;
    logic [$clog2(BITS):0] NO_LED;
    logic [BITS-1:0]       AD_LED;
    logic [BITS-1:0]       SB_LED;
    logic [BITS-1:0]       MULT_LED;


    logic [NUM_SEGMENTS-1:0][7:0]       segments;

    leading_ones #(.SELECTOR(SELECTOR), .BITS(BITS)) u_lo (.*, .LED(LO_LED));
    add_sub      #(.SELECTOR("ADD"),    .BITS(BITS)) u_ad (.*, .LED(AD_LED));
    add_sub      #(.SELECTOR("SUB"),    .BITS(BITS)) u_sb (.*, .LED(SB_LED));
    num_ones     #(                     .BITS(BITS)) u_no (.*, .LED(NO_LED));
    mult         #(                     .BITS(BITS)) u_mt (.*, .LED(MULT_LED));
    seven_segment #(.NUM_SEGMENTS(NUM_SEGMENTS), .CLK_PER(CLK_PER), .REFR_RATE(REFR_RATE)) u_7seg (.clk(CLK), .encoded(ENCODED), .digit_point(DIGIT_POINT), .cathode(CATHODE));

    //always_latch begin
    always_comb
    begin
      LED = '0;
      case (1'b1)
        BTNC:
          LED  = MULT_LED;
        BTNU:
          LED  = LO_LED;
        BTND:
          LED  = NO_LED;
        BTNL:
          LED  = AD_LED;
        BTNR:
          LED  = SB_LED;
      endcase
    end
  );
endmodule
