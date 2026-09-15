
module mac #(parameter WIDTH=8, ACC_WIDTH=32)
  (input  clk,
   input  rst_n,                                    // active-HIGH reset (resets when rst_n=1)
   input  clear,
   input  en,
   input  signed [WIDTH-1:0]    a,
   input  signed [WIDTH-1:0]    b,
   output reg signed [ACC_WIDTH-1:0] acc_out
  );

  wire signed [2*WIDTH-1:0] product;
  assign product = a*b;

  always @(posedge clk) begin
      if (rst_n)                        // active-high: held in reset while rst_n = 1
        acc_out <= 0;
      else begin
          if (clear)
            acc_out <= 0;
          else if (en)
            acc_out <= acc_out + product;
      end
  end
endmodule
