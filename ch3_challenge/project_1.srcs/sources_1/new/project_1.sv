`timescale 1ns / 10ps
module project_1
  #
    (
      parameter SELECTOR,
      parameter BITS         = 16,
      parameter NUM_SEGMENTS = 4,
      parameter CLK_PER      = 10,  // Clock period in ns
      parameter REFR_RATE    = 1000, // Refresh rate in Hz
      parameter MODE         = "DEC" // or "DEC"
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
    encoded = copy_led_to_encoded(LED, MODE);
    case (1'b1)
      BTNC:
      begin
        LED  = MULT_LED;
        encoded = copy_led_to_encoded(LED, MODE);
      end
      BTNU:
      begin
        LED  = LO_LED;
        encoded = copy_led_to_encoded(LED, MODE);
      end
      BTND:
      begin
        LED  = NO_LED;
        encoded = copy_led_to_encoded(LED, MODE);
      end
      BTNL:
      begin
        LED  = AD_LED;
        encoded = copy_led_to_encoded(LED, MODE);
      end
      BTNR:
      begin
        LED  = SB_LED;
        encoded = copy_led_to_encoded(LED, MODE);
      end
    endcase
  end

  function  logic [NUM_SEGMENTS-1:0][3:0] copy_led_to_encoded(input logic [15:0] LED, input string mode);
    logic [NUM_SEGMENTS-1:0][3:0] din;
    int i, j; // Declare loop variables
    bit [3:0]                     next_val;
    bit                           carry_in;

    if (mode == "HEX")
    begin
      for (int i = 0; i < NUM_SEGMENTS; i++)
      begin
        for (int j = 0; j < NUM_SEGMENTS; j++)
        begin
          din[i][j] = LED[(i * NUM_SEGMENTS) + j];
        end
      end
    end
    else if (mode == "DEC")
    begin
      for (int i = 0; i < NUM_SEGMENTS; i++)
      begin
        for (int j = 0; j < NUM_SEGMENTS; j++)
        begin
          din[i][j] = LED[(i * NUM_SEGMENTS) + j];
        end
      end

      carry_in = '1;
      for (int i = 0; i < NUM_SEGMENTS; i++)
      begin
        next_val = din[i] + carry_in;
        if (next_val > 9)
        begin
          copy_led_to_encoded[i] = '0;
          carry_in   = '1;
        end
        else
        begin
          copy_led_to_encoded[i] = next_val;
          carry_in   = '0;
        end
      end // for (int i = 0; i < NUM_SEGMENTS; i++)

    end

    return din;
  endfunction
endmodule
