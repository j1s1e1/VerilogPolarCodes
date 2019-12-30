`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/27/2019 01:01:55 AM
// Design Name: 
// Module Name: polar_encode_decode_32_tb
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


module polar_encode_decode_32_tb();

import channel_tasks_pkg::*;

parameter N=32;
parameter BITS=8;

logic clk;
logic block_data[N];
logic encoded[N];

logic signed [BITS-1:0] noisy[N];
logic frozen[N] = '{default : 0};
logic decoded_data[N];
logic in_valid;
logic in_valid_polar_decode = 0;
logic out_valid_polar_transform;
logic out_valid;

int errors;
real error_rate = -1;

task Test(logic data[], real snr);
  in_valid <= 1;
  for (int i = 0; i < N; i++)
    block_data[i] <= data[i];
  @(posedge clk);
  in_valid <= 0;
  while (out_valid_polar_transform == 0)
    @(posedge clk);
  noisy = Noise#(.BITS(BITS))::Add(encoded, snr);
  // Decoder is using 0 positive 1 negative
  noisy = Noise#(.BITS(BITS))::Minus(noisy);
  //noisy = Noise#(.BITS(BITS))::Reverse(noisy);
  //for (int i = 0; i < N; i++)
  //  extended_noisy[i] = noisy[i];
  in_valid_polar_decode <= 1;
  @(posedge clk);
  in_valid_polar_decode <= 0;
  while (out_valid == 0)
    @(posedge clk);  
  errors = Errors(block_data, decoded_data);
  error_rate = 1.0 * errors / N;
endtask

task DisplayNoisy();
  for (int i = 0; i < N; i++)
    $write("%d, ", noisy[i]);
  $display("");
endtask

task TestRandom(real snr);
  for (int i = 0; i < 10; i++)
    begin
      Test(RandomBits(32), snr);
      @(posedge clk);
      @(posedge clk);     
    end
endtask

initial
  begin
    in_valid <= 0;
    block_data <= '{ default : 0 };
    @(posedge clk);
    @(posedge clk);
    Test('{ 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0,
            1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0}, 10.0);
    DisplayNoisy();
    @(posedge clk);
    @(posedge clk);
    Test('{ 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0,
            1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0}, 2.0);
    @(posedge clk);
    @(posedge clk);
    Test('{ 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0,
            1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0}, 1.0);
    @(posedge clk);
    @(posedge clk);    
    Test('{ 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0,
            1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0}, 0.5);
    @(posedge clk);
    @(posedge clk);    
    TestRandom(10.0);
    $stop;  
  end

initial
  begin
    clk = 0;
    forever #10 clk = ~clk;
  end

polar_transform
#(.BITS(N))
polar_transform_array
(
.clk,
.in_valid,
.u(block_data),
.out_valid(out_valid_polar_transform),
.x(encoded)
);

polar_decode
#(.BITS(BITS), .N(N))
polar_decode_array
(
.clk,
.in_valid(in_valid_polar_decode),
.y(noisy),
.frozen(frozen),
.out_valid,
.u(decoded_data)
);
endmodule
