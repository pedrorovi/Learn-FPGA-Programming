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


  function logic [NUM_SEGMENTS-1:0][3:0] copy_led_to_encoded(input logic [15:0] LED, input string mode);
    logic [NUM_SEGMENTS-1:0][3:0] din;
    int i, j; // Declare loop variables
    int sum;
    bit [3:0] next_val;
    bit carry_in;

    if (mode == "HEX")
    begin
      for (i = 0; i < NUM_SEGMENTS; i++)
      begin
        din[i] = LED[i * 4 +: 4]; // Assuming each segment is 4 bits
        // sum += din[i];
      end
    end
    else if (mode == "DEC")
    begin
      for (i = 0; i < NUM_SEGMENTS; i++)
      begin
        sum += LED[i * 4 +: 4] << i * 4;
      end

      din[0] = sum % 10;            // digit 0, ones place
      din[1] = (sum / 10) % 10;     // digit 1, tens place
      din[2] = (sum / 100) % 10;   // digit 2, hundreds place
      din[3] = (sum / 1000) % 10; // digit 3, thousands place

    end

    // begin
    //   for (i = 0; i < NUM_SEGMENTS; i++)
    //   begin
    //     next_val = sum % 10;
    //     sum /= 10;
    //     din[i] = next_val;
    //   end
    // end

    return din;
  endfunction


endmodule
