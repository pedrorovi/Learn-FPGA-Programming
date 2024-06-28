`timescale 1ns / 10ps
module project_1
  #
    (
      parameter SELECTOR,
      parameter BITS         = 16,
      parameter NUM_SEGMENTS = 4,
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


      input wire                      clk,

      output logic [NUM_SEGMENTS-1:0] anode,
      output logic [6:0]              cathode
    );

  logic [$clog2(BITS):0] LO_LED;
  logic [$clog2(BITS):0] NO_LED;
  logic [BITS-1:0]       AD_LED;
  logic [BITS-1:0]       SB_LED;
  logic [BITS-1:0]       MULT_LED;

  leading_ones
    #(.SELECTOR(SELECTOR), .BITS(BITS))
    u_lo (.*, .LED(LO_LED));
  add_sub
    #(.SELECTOR("ADD"),    .BITS(BITS))
    u_ad (.*, .LED(AD_LED));
  add_sub
    #(.SELECTOR("SUB"),    .BITS(BITS))
    u_sb (.*, .LED(SB_LED));
  num_ones
    #(.BITS(BITS))
    u_no (.*, .LED(NO_LED));
  mult
    #(.BITS(BITS))
    u_mt (.*, .LED(MULT_LED));


  logic [NUM_SEGMENTS-1:0][3:0]       encoded;
  logic [NUM_SEGMENTS-1:0]            digit_point;

  seven_segment
    #(.NUM_SEGMENTS(NUM_SEGMENTS), .CLK_PER(CLK_PER), .REFR_RATE(REFR_RATE))
    u_7seg (.clk(clk), .encoded(encoded), .digit_point(digit_point), .anode(anode), .cathode(cathode));


  initial
  begin
    encoded     = '0;
    digit_point = '1;
  end

  //always_latch begin
  always_comb
  begin
    LED = '0;
    case (1'b1)
      BTNC:
      begin
        LED  = MULT_LED;
        // ENCODED = MULT_LED;
      end
      BTNU:
      begin
        LED  = LO_LED;
        // ENCODED = LO_LED;
      end
      BTND:
      begin
        LED  = NO_LED;
        // ENCODED = NO_LED;
      end
      BTNL:
      begin
        LED  = AD_LED;
        // ENCODED = AD_LED;
      end
      BTNR:
      begin
        LED  = SB_LED;
        // ENCODED = SB_LED;
      end
    endcase
  end
endmodule
