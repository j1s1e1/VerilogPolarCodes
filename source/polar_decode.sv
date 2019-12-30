`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/14/2019 03:22:12 PM
// Design Name: 
// Module Name: polar_decode
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


module polar_decode
#(parameter BITS = 8, N=4)
(
input clk,
input in_valid,
input signed [BITS-1:0] y[N],
input frozen[N],
output out_valid,
output u[N]
);

localparam EXTENDED_BITS = BITS + $clog2(N);


logic signed [EXTENDED_BITS-1:0] y_rev_ext[N];  // Add extra bits to allow sums
logic frozen_rev[N];
logic u_rev[N];

for (genvar g = 0; g < N; g++)
  begin
    assign y_rev_ext[g] = y[N-1-g];  // Reverse data order of input
    assign frozen_rev[g] = frozen[N-1-g];
    assign u[g] = u_rev[N-1-g];
  end

recursive_decode
#(.BITS(EXTENDED_BITS), .N(N))
recursive_decode1
(
.clk,
.in_valid,
.y(y_rev_ext),
.frozen(frozen_rev),
.out_valid,
.u(u_rev),
.v()
);
  
endmodule
