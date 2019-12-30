`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/26/2019 01:43:52 AM
// Design Name: 
// Module Name: encode_block
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

import polar_pkg::*;

module encode_block
#(parameter N=2048, K=1024, P=32)
(
input clk,
input in_valid,
input data[K],
input [$clog2(P):0] sorted_indexes[P],
output logic out_valid,
output logic encoded[N]
);

// Break up block and encode each group
localparam BLOCKS = N/P;
localparam BITS_PER_BLOCK = (K + BLOCKS - 1)/BLOCKS;
localparam FBITS_PER_BLOCK = P - BITS_PER_BLOCK;

logic block_data[BLOCKS][P];
logic encoded_block_data[BLOCKS][P];
logic out_valid_polar_transform[BLOCKS];

for (genvar g = 0; g < BLOCKS; g++)
  begin
    localparam CNT = (g == BLOCKS-1) ? K - g * BITS_PER_BLOCK  : BITS_PER_BLOCK; 
    frozen_assign
    #(.N(P), .K(CNT))
    frozen_assign_array
    (
        .data(data[g * BITS_PER_BLOCK:g * BITS_PER_BLOCK + CNT-1]),
        .sorted_indexes,
        .inserted(block_data[g])
    );
  end

always @(posedge clk)
  if (out_valid_polar_transform[0])
    out_valid <= 1;
  else
    out_valid <= 0;
    
always @(posedge clk)
  if (out_valid_polar_transform[0])
    for (int i = 0; i < BLOCKS; i++)
      begin
        for (int j = 0; j < P; j++)
          encoded[i*P+j] <= encoded_block_data[i][j];
      end
  else
    encoded <= encoded;
  
for (genvar g = 0; g < BLOCKS; g++)
  polar_transform
  #(.BITS(P))
  polar_transform_array
  (
    .clk,
    .in_valid,
    .u(block_data[g]),
    .out_valid(out_valid_polar_transform[g]),
    .x(encoded_block_data[g])
  );
  
endmodule
