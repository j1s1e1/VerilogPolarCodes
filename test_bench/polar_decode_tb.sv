`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/18/2019 09:55:49 PM
// Design Name: 
// Module Name: polar_decode_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module polar_decode_tb();

parameter BITS = 8, N=4;

logic clk;
logic in_valid;
logic signed [BITS-1:0] y[N];
logic frozen[N];
logic out_valid;
logic u[N];
logic v[N];

task Test(input real yin[N]);
  in_valid <= 1;
  for (int i = 0; i < N; i++)
    y[i] <= yin[i] * 2**N;
  @(posedge clk);
  in_valid <= 0;
  y <= '{default : 0};
endtask

initial
  begin
    in_valid <= 0;
    y <= '{default : 0};
    frozen <= '{default : 0};
    @(posedge clk);
    @(posedge clk);
    Test('{ 0.05, -0.05, 0.05, -0.05 });
    @(posedge clk);
    @(posedge clk);
    Test('{ -0.05, 0.05, -0.05, 0.05 });
    @(posedge clk);
    @(posedge clk);
    Test('{ 0.5, 0.5, 0.5, 0.5 });
    @(posedge clk);
    @(posedge clk);
    Test('{ -0.5, -0.5, -0.5, -0.5 });
    @(posedge clk);
    @(posedge clk);
    $stop;
  end
  
initial
  begin
    clk = 0;
    forever #10 clk = ~clk;
  end

polar_decode
#(.BITS(BITS), .N(N))
polar_decode1
(
.clk,
.in_valid,
.y,
.frozen,
.out_valid,
.u,
.v
);

endmodule
