`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/18/2019 10:25:01 PM
// Design Name: 
// Module Name: f_tb
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


module f_tb();

parameter BITS=4;

logic clk;
logic signed [BITS-1:0] a;
logic signed [BITS-1:0] b;
logic signed [BITS-1:0] c;

task Test(int ain, int bin);
  a <= ain;
  b <= bin;
  @(posedge clk);
  a <= 0;
  b <= 0;
endtask

initial
  begin
    a <= 0;
    b <= 0;
    @(posedge clk);
    @(posedge clk);
    Test(5, 7);
    @(posedge clk);
    @(posedge clk);
    Test(5, -7);
    @(posedge clk);
    @(posedge clk);
    Test(-5, -7);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    $stop;
  end
  
initial
  begin
    clk = 0;
    forever #10 clk = ~clk;
  end

f #(.BITS(BITS)) f1
(
.a,
.b,
.c
);
    
endmodule
