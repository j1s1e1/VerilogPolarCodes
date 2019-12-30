`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/19/2019 12:22:14 AM
// Design Name: 
// Module Name: channel
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


module channel
#(parameter BITS = 4, N = 8)
(
input data[N],
output [BITS-1:0] noisy_data[N]
);
for (genvar g = 0; g < N; g++)
  assign noisy_data[g] = (data[g] == 0) ? 2**(BITS-1) : -(2**(BITS-1));
  
endmodule
