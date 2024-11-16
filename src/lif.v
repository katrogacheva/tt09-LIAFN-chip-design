`default_nettype none

module lif(
    input wire [7:0] current,  // Input current to the neuron
    input wire clk,            // Clock signal
    input wire reset_n,        // Active-low reset signal
    input wire spike,          // Spike signal used for controlling reset of the state
    output reg [7:0] state     // Current state of the neuron
);

    wire [7:0] next_state;            // Wire for next state calculation
    // following the equation next_state = beta*state + I_in
    reg [7:0] beta;                   // Scaling factor for leaky integration beta
    wire [15:0] scaled_state;         // 16-bit wire for the scaled state calculation

    always @(posedge clk) begin
        if (!reset_n) begin
            state <= 8'd0;            // Reset state to zero
            beta <= 8'd128;           // Initialize beta to 128 (approx. 0.5 scaling when right-shifted by 8)
        end else begin
            state <= next_state;      // Update state with next state value
        end
    end

    // Calculate the scaled state: state * beta (using 16 bits to prevent overflow)
    assign scaled_state = state * beta;

    // Next state and reset state logic
    // When spike is 0, update the state with leaky integrate formula: next_state = (scaled_state >> 8) + current
    // When spike is 1, reset the state to just the input current value
    assign next_state = spike ? current : (scaled_state[15:8]) + current;

endmodule
