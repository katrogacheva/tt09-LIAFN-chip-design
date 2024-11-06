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
  assign uio_out [6:0] = 0;
  assign uio_oe  = 1;

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, uio_in, 1'b0};

  // instantiate lif neuron
  lif lif1 (.current(ui_in), .clk(clk), .reset_n(rst_n), .state(uo_out), .spike(uio_out[7]));
  //lif lif2 (.current({{uio_out[7], 7'b0000000}}), .clk(clk), .reset_n(rst_n), .state(uo_out), .spike(uio_out[7]));

endmodule
