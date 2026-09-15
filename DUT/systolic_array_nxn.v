module systolic_array_nxn #(
    parameter N         = 2,
    parameter WIDTH     = 8,
    parameter ACC_WIDTH = 32
)(
    input     clk,
    input     rst_n,
    input     clear_acc,
    input   signed [WIDTH-1:0] a_in [0:N-1],
    input  signed [WIDTH-1:0]  b_in [0:N-1],
    output  signed [ACC_WIDTH-1:0] acc_out [0:N-1][0:N-1]
);

    // internal links: a flows left->right, b flows top->bottom
    wire signed [WIDTH-1:0] a_link [0:N-1][0:N];
    wire signed [WIDTH-1:0] b_link [0:N][0:N-1];

    genvar i, j;
    generate
        for (i = 0; i < N; i = i + 1) begin : ROW
            for (j = 0; j < N; j = j + 1) begin : COL

                wire signed [WIDTH-1:0] a_src;
                wire signed [WIDTH-1:0] b_src;
                assign a_src = (j == 0) ? a_in[i] : a_link[i][j];
                assign b_src = (i == 0) ? b_in[j] : b_link[i][j];

                pe #(
                    .WIDTH(WIDTH),
                    .ACC_WIDTH(ACC_WIDTH)
                ) u_pe (
                    .clk       (clk),
                    .rst_n     (rst_n),
                    .clear_acc (clear_acc),
                    .a_in      (a_src),
                    .b_in      (b_src),
                    .a_out     (a_link[i][j+1]),
                    .b_out     (b_link[i+1][j]),
                    .acc_out   (acc_out[i][j])
                );

            end
        end
    endgenerate

endmodule
