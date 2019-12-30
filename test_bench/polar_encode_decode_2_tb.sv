`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/27/2019 12:05:44 PM
// Design Name: 
// Module Name: polar_encode_decode_2_tb
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


module polar_encode_decode_2_tb();

import channel_tasks_pkg::*;

parameter N=2;
parameter BITS=8;

logic clk;
logic block_data[N];
logic encoded[N];

logic signed [BITS-1:0] noisy[N];
logic frozen[N] = '{default : 0};
logic decoded_data[N];
logic reversed_decoded_data[N];
logic in_valid;
logic in_valid_polar_decode = 0;
logic out_valid_polar_transform;
logic out_valid;

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
  noisy = Noise#(.BITS(BITS))::Reverse(noisy);
  noisy = Noise#(.BITS(BITS))::DivideByTwo(noisy);
  in_valid_polar_decode <= 1;
  @(posedge clk);
  in_valid_polar_decode <= 0;
  while (out_valid == 0)
    @(posedge clk);  
  reversed_decoded_data = Noise#(.BITS(1))::ReverseUnsigned(decoded_data);
endtask

task DisplayNoisy();
  for (int i = 0; i < N; i++)
    $write("%d, ", noisy[i]);
  $display("");
endtask

initial
  begin
    in_valid <= 0;
    block_data <= '{ default : 0 };
    @(posedge clk);
    @(posedge clk);
    Test('{ 0, 0}, 10.0);
    Test('{ 1, 0}, 10.0);
    Test('{ 0, 1}, 10.0);
    Test('{ 1, 1}, 10.0);
    DisplayNoisy();
    @(posedge clk);
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
.u(decoded_data),
.v()
);

endmodule
