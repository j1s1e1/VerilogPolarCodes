`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/14/2019 12:25:46 AM
// Design Name: 
// Module Name: polar_transform_tb
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


module polar_transform_tb();

parameter BITS = 4;

logic clk;
logic in_valid;         
logic u[BITS];      
logic out_valid;  
logic x[BITS];

polar_transform #(.BITS(BITS)) pt1(.*);

task StepTest(input int uin);
  in_valid <= 1;
    for (int i = 0; i < BITS; i++)
      u[i] <= ((uin >> i) & 1) ? 1 : 0;
  @(posedge clk);
  in_valid <= 0;
  while (out_valid == 0)
    @(posedge clk);
  u <= '{default : 0};
endtask

task Test();
  for (int i = 0; i < 2**BITS; i++)
    StepTest(i);
endtask

initial
  begin
    @(posedge clk);
    @(posedge clk);
    Test();
    @(posedge clk);
    @(posedge clk);
    $stop;
  end
  
initial
  begin
    clk = 0;
    forever #10 clk = ~clk;
  end

endmodule
