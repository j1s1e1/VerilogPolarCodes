`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/28/2019 01:44:47 AM
// Design Name: 
// Module Name: frozen_recover
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


module frozen_recover
#(parameter N = 32, K = 16)
(
input decoded_data[N],
input [$clog2(N):0] sorted_indexes[N],
output logic data[K]
);

always_comb
  begin
    for (int i = 0; i < K; i++)
      data[i] =  decoded_data[sorted_indexes[N-1-i]];
  end
  
endmodule
