//this tb is to check for 2x2 systolic array (to check the functionality of the dut)
module tb_systolic_array;

    localparam N         = 2;
    localparam WIDTH     = 8;
    localparam ACC_WIDTH = 32;

    reg                          clk;
    reg                          rst_n;      // active-HIGH: 1 = reset, 0 = run
    reg                          clear_acc;
    reg  signed [WIDTH-1:0]      a_in [0:N-1];
    reg  signed [WIDTH-1:0]      b_in [0:N-1];
    wire signed [ACC_WIDTH-1:0]  acc_out [0:N-1][0:N-1];

    // A = [[1,2],[3,4]]  B = [[5,6],[7,8]]  ->  C = [[19,22],[43,50]]
    reg signed [WIDTH-1:0] A [0:N-1][0:N-1];
    reg signed [WIDTH-1:0] B [0:N-1][0:N-1];

    integer i, j, k;

    systolic_array_nxn #(.N(N), .WIDTH(WIDTH), .ACC_WIDTH(ACC_WIDTH)) dut (
        .clk       (clk),
        .rst_n     (rst_n),
        .clear_acc (clear_acc),
        .a_in      (a_in),
        .b_in      (b_in),
        .acc_out   (acc_out)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        rst_n     = 1;
        clear_acc = 0;
        for (i = 0; i < N; i = i + 1) begin
            a_in[i] = 0;
            b_in[i] = 0;
        end

        A[0][0]=1; A[0][1]=2; A[1][0]=3; A[1][1]=4;
        B[0][0]=5; B[0][1]=6; B[1][0]=7; B[1][1]=8;

        // hold active-high reset, then release
        repeat (3) @(posedge clk);
        rst_n = 0;

        // clear accumulators for 1 cycle
        clear_acc = 1;
        @(negedge clk);
        clear_acc = 0;

        // stream with skew: a row i is i cycles late, b column j is j cycles late
        // t runs 0 .. 2N-2  (2N-1 cycles total)
        for (k = 0; k < 2*N-1; k = k + 1) begin
            for (i = 0; i < N; i = i + 1)
                a_in[i] = (k >= i && k-i < N) ? A[i][k-i] : 0;
            for (j = 0; j < N; j = j + 1)
                b_in[j] = (k >= j && k-j < N) ? B[k-j][j] : 0;
            @(negedge clk);
        end

        // all inputs consumed; inputs back to zero, then let the array drain
        for (i = 0; i < N; i = i + 1) begin
            a_in[i] = 0;
            b_in[i] = 0;
        end
        repeat (2*N) @(posedge clk);

        for (i = 0; i < N; i = i + 1)
            for (j = 0; j < N; j = j + 1)
                $display("C[%0d][%0d] = %0d", i, j, acc_out[i][j]);

        if (acc_out[0][0]==19 && acc_out[0][1]==22 &&
            acc_out[1][0]==43 && acc_out[1][1]==50)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end

endmodule
