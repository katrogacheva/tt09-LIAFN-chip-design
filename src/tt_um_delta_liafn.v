`default_nettype none

module tt_um_delta_liafn (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  // All output pins must be assigned. If not used, assign to 0.
  assign uio_oe = 8'b11111111;

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, uio_in, 1'b0};

  // Delta threshold for spiking
  wire [7:0] delta_threshold = 8'd50;

  // Implement Beta value for leaky integration later
  // This value will be multiplied by the state and added to the input current to update the state of the lif
  //wire [7:0] beta = 8'd128; 

  // Intermediate signals
  wire [7:0] state;
  wire [7:0] prev_state;
  wire signed [8:0] diff;         // 9-bit to handle overflow
  wire [8:0] abs_diff;
  wire [7:0] difference;
  wire spike;

  // TOP MODULE LOGIC
  // flow output of lif into reg to update current state
  lif lif_inst (.current(ui_in), .clk(clk), .reset_n(rst_n), .spike(spike), .state(state));

  // Instantiate the register to hold the previous state
  reg_state_store store (.state(state), .clk(clk), .reset_n(rst_n), .prev_state(prev_state));

  // Compare the previous and current states
  assign diff = state - prev_state;

  // Get absolute difference since it is signed
  assign abs_diff = (diff < 0) ? -diff : diff;

  // Check if difference exceeds delta threshold and set spike if it does
  assign spike = (abs_diff >= {1'b0, delta_threshold});

  // Output the difference if there is a spike, else pass zero
  assign difference = spike ? abs_diff[7:0] : 8'b00000000;

  // Connect outputs for testing and debugging
  assign uio_out = difference; // Output the difference on uio_out
  assign uo_out = state;       // Output the current state on uo_out

endmodule
