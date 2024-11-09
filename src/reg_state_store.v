`default_nettype none

module reg_state_store(
    input wire [7:0]    state,
    input wire          clk,
    input wire          reset_n,
    output reg [7:0]    prev_state
);

    always @(posedge clk) begin
        if (!reset_n) begin
            prev_state <= 0; // Reset previous state to 0
        end else begin
            prev_state <= state; // Update previous state to current state
        end
    end

endmodule
