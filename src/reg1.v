`default_nettype none

module reg1(
    input wire [7:0]    current,
    input wire          clk,
    input wire          reset_n,
    output reg [7:0]    state
);

    wire [7:0] next_state;
    //wire [7:0] delta;
    //reg [7:0] beta;

    always @(posedge clk) begin

        if (!reset_n) begin
            state <= 0;
        end else begin
            state <= next_state;
        end
    end
    
    // next state logic
    assign next_state = current + (state >> 1); // Leaky integration

    // should I update next state here? with the following equation U_i+1 = Beta*u_i + I_in?

endmodule