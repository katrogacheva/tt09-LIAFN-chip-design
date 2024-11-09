`default_nettype none

module lif(
    input wire [7:0]    current,
    input wire          clk,
    input wire          reset_n,
    input wire          spike,
    output reg [7:0]    state
);

    wire [7:0] next_state;
    //reg [7:0] beta;

    always @(posedge clk) begin

        if (!reset_n) begin
            state <= 0;
        end else begin
            state <= next_state;
        end
    end
    
    // next state logic
    assign next_state = current + (spike ? 0: (state >> 1));

endmodule