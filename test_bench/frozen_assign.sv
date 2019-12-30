`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/28/2019 12:56:54 AM
// Design Name: 
// Module Name: frozen_assign
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
// 1288 LUTs
//////////////////////////////////////////////////////////////////////////////////
`include "../../sim_1/new/polar_pkg.sv"
import polar_pkg::*;

module frozen_assign
#(parameter N = 32, K = 16)
(
input data[K],
input [$clog2(N):0] sorted_indexes[N],
output logic inserted[N]
);

always_comb
  begin
    for (int i = 0; i < N; i++)
      if (i < K)
        inserted[sorted_indexes[N-1-i]] = data[i];
      else
        inserted[sorted_indexes[N-1-i]] = 0;
  end

endmodule
