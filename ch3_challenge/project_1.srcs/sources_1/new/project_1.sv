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


  function logic [6:0] hexto7segment(input [3:0] x);
    logic [6:0] z;
    begin
      case (x)
        4'b0000:
          z = 7'b1111110; // Hexadecimal 0
        4'b0001:
          z = 7'b0110000; // Hexadecimal 1
        4'b0010:
          z = 7'b1101101; // Hexadecimal 2
        4'b0011:
          z = 7'b1111001; // Hexadecimal 3
        4'b0100:
          z = 7'b0110011; // Hexadecimal 4
        4'b0101:
          z = 7'b1011011; // Hexadecimal 5
        4'b0110:
          z = 7'b1011111; // Hexadecimal 6
        4'b0111:
          z = 7'b1110000; // Hexadecimal 7
        4'b1000:
          z = 7'b1111111; // Hexadecimal 8
        4'b1001:
          z = 7'b1111011; // Hexadecimal 9
        4'b1010:
          z = 7'b1110111; // Hexadecimal A
        4'b1011:
          z = 7'b0011111; // Hexadecimal B
        4'b1100:
          z = 7'b1001110; // Hexadecimal C
        4'b1101:
          z = 7'b0111101; // Hexadecimal D
        4'b1110:
          z = 7'b1001111; // Hexadecimal E
        4'b1111:
          z = 7'b1000111; // Hexadecimal F
        default:
          z = 7'b0000000; // Default case
      endcase
      hexto7segment = z; // Assign the result to the function name
    end
  endfunction


  function logic [NUM_SEGMENTS-1:0][3:0] copy_led_to_encoded(input logic [15:0] LED, input string mode);
    logic [NUM_SEGMENTS-1:0][3:0] din;
    int i, j; // Declare loop variables
    bit [3:0] next_val;
    bit carry_in;

    if (mode == "HEX")
    begin
      for (i = 0; i < NUM_SEGMENTS; i++)
      begin
        din[i] = LED[i * 4 +: 4]; // Assuming each segment is 4 bits
      end
    end
    else if (mode == "DEC")
    begin
      for (i = 0; i < NUM_SEGMENTS; i++)
      begin
        din[i] = hexto7segment(LED[i * 4 +: 4]);
      end
    end

    return din;
  endfunction


endmodule
