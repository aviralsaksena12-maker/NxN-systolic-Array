module pe #(
    parameter WIDTH     = 8,
    parameter ACC_WIDTH = 32
)(
    input                          clk,
    input                          rst_n,
    input                          clear_acc,
    input   signed [WIDTH-1:0]     a_in,
    input   signed [WIDTH-1:0]     b_in,
    output reg  signed [WIDTH-1:0] a_out,
    output reg  signed [WIDTH-1:0] b_out,
    output  signed [ACC_WIDTH-1:0] acc_out
);

    // forward this cycle's inputs to neighbors, one cycle later
    always @(posedge clk) begin
        if (rst_n) begin                // active-high reset
            a_out <= 0;
            b_out <= 0;
        end else begin
            a_out <= a_in;
            b_out <= b_in;
        end
    end

    // this PE's own MAC, using its own current inputs
    mac #(
        .WIDTH(WIDTH),
        .ACC_WIDTH(ACC_WIDTH)
    ) mac_inst (
        .clk       (clk),
        .rst_n     (rst_n),
        .clear     (clear_acc),
        .en        (1'b1),
        .a         (a_in),
        .b         (b_in),
        .acc_out   (acc_out)
    );

endmodule
