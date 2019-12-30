`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/26/2019 06:48:35 PM
// Design Name: 
// Module Name: decode_block
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


module decode_block
#(parameter BITS=8, N=2048, K=1024, P=32)
(
input clk,
input in_valid,
input signed [BITS-1:0] noisy[N],
input [$clog2(P):0] sorted_indexes[P],
output logic out_valid,
output logic decoded[K]
);

// Convert noisy bits to 
localparam BLOCKS = N/P;
localparam BITS_PER_BLOCK = (K + BLOCKS - 1)/BLOCKS;
localparam ZEROS_NORMAL = P - BITS_PER_BLOCK;
localparam ZEROS_LAST = N - K - (BLOCKS - 1) * ZEROS_NORMAL;

logic signed [BITS-1:0] block_data[BLOCKS][P];
logic signed decoded_block_data[BLOCKS][P];
logic frozen[BLOCKS][P];
logic out_valid_polar_decode[BLOCKS];

int zero_count;

always_comb
  for (int i = 0; i < BLOCKS; i++)
    begin
      zero_count = (i == BLOCKS-1) ? ZEROS_LAST  : ZEROS_NORMAL;
      for (int j = 0; j < P; j++)
        if (j < zero_count)
          frozen[i][sorted_indexes[P-1-j]] = 0;
        else
          frozen[i][sorted_indexes[P-1-j]] = 1;
    end

for (genvar g = 0; g < BLOCKS; g++)
  assign block_data[g] = noisy[g*P:g*P+P-1];

always @(posedge clk)
  if (out_valid_polar_decode[0])
    out_valid <= 1;
  else
    out_valid <= 0;
    
for (genvar g = 0; g < BLOCKS; g++)
polar_decode
#(.BITS(BITS), .N(P))
polar_decode_array
(
.clk,
.in_valid,
.y(block_data[g]),
.frozen(frozen[g]),
.out_valid(out_valid_polar_decode[g]),
.u(decoded_block_data[g])
);

for (genvar g = 0; g < BLOCKS; g++)
  begin
    localparam CNT = (g == BLOCKS-1) ? K - g * BITS_PER_BLOCK  : BITS_PER_BLOCK; 
    frozen_recover
    #(.N(P), .K(CNT))
    frozen_recover1
    (
       .decoded_data(decoded_block_data[g]),
       .sorted_indexes,
       .data(decoded[g * BITS_PER_BLOCK:g * BITS_PER_BLOCK + CNT-1])
    );
  end

endmodule
