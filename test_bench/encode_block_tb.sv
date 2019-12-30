`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/26/2019 01:47:26 AM
// Design Name: 
// Module Name: encode_block_tb
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

import channel_tasks_pkg::*;
import polar_pkg::*;

module encode_block_tb();

parameter N=2048, K=1024, P=32;
parameter BITS=8;

logic clk;            
logic in_valid;       
logic data[K];       
logic out_valid;
logic encoded[N];
logic frozen[P];

logic in_valid_decode_block;
logic out_valid_decode_block;
logic signed [BITS-1:0] noisy[N];
logic decoded[K];

real snr_amplitude = -100;
int errors;
real error_rate = -1;

int sorted_indexes_int[P] = GetSortedIndexes($clog2(P), 0.1, 100);
logic [$clog2(P):0] sorted_indexes[P];

task Test(real snr);
  snr_amplitude = snr;
  in_valid <= 1;
  data <= RandomBits(K);
  frozen <= SelectFrozen(5, 0.1, 100, 17);
  @(posedge clk);
  in_valid <= 0;
  while (out_valid == 0)
    @(posedge clk);
  noisy = Noise#(.BITS(BITS))::Add(encoded, snr);
  noisy = Noise#(.BITS(BITS))::Minus(noisy);
  in_valid_decode_block <= 1;
  @(posedge clk); 
  in_valid_decode_block <= 0;
  while (out_valid_decode_block == 0)
    @(posedge clk);
  errors = Errors(data, decoded);
  error_rate = 1.0 * errors / K;
endtask


task SetSortedIndexes();
  for (int i = 0; i < N; i++)
    sorted_indexes[i] = sorted_indexes_int[i];
endtask

initial
  begin
    in_valid <= 0;
    @(posedge clk);
    SetSortedIndexes();
    @(posedge clk);
    Test(10.0);     
    @(posedge clk);
    @(posedge clk);    
    Test(4.0);     
    @(posedge clk);
    @(posedge clk);
    Test(2.0);
    @(posedge clk);
    @(posedge clk);
    Test(1.0);
    @(posedge clk);
    @(posedge clk);
    Test(0.5);
    @(posedge clk);
    @(posedge clk);
    $stop;
  end

initial
  begin
    clk = 0;
    forever #10 clk = ~clk;
  end

encode_block
#(.N(N), .K(K), .P(P))
encode_block1
(
.clk,             
.in_valid,        
.data,       
.sorted_indexes,  
.out_valid,
.encoded
);

decode_block
#(.BITS(BITS), .N(N), .K(K), .P(P))
decode_block1
(
.clk,
.in_valid(in_valid_decode_block),
.noisy,
.sorted_indexes,
.out_valid(out_valid_decode_block),
.decoded
);

endmodule
