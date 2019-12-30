`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/27/2019 08:59:50 PM
// Design Name: 
// Module Name: recursive_decode
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


module recursive_decode
#(parameter BITS = 8, N=4)
(
input clk,
input in_valid,
input signed [BITS-1:0] y[N],
input frozen[N],
output out_valid,
output u[N],
output v[N]
);

if (N==2)
  begin
    assign out_valid = in_valid;
    logic signed [BITS-1:0] lu[2];
    f #(.BITS(BITS)) f1
    (
      .a(y[0]),
      .b(y[1]),
      .c(lu[0])
    );
    assign u[0] = (frozen[0]) ? 0 : (lu[0] >= 0) ? 0 : 1;
    g #(.BITS(BITS)) g1
    (
      .a(y[0]),
      .b(y[1]),
      .u(u[0]),
      .c(lu[1])
    );
    assign u[1] = (frozen[1]) ? 0 : (lu[1] >= 0) ? 0 : 1;
    assign v[0] = u[0] ^ u[1];
    assign v[1] = u[1];
  end
else
  begin
    logic signed [BITS-1:0] L_w_odd[N/2];
    for (genvar index = 0; index < N/2; index++)
      f #(.BITS(BITS)) f_array
      (
        .a(y[2*index]),
        .b(y[2*index+1]),
        .c(L_w_odd[index])
      );
    
    logic frozen1[N/2];
    for (genvar i = 0; i < N/2; i++)
      assign frozen1[i] = frozen[i];
    logic u1[N/2];
    logic v1[N/2];
    recursive_decode #(.BITS(BITS), .N(N/2)) recursive_decode1
    (
    .clk,
    .in_valid,
    .y(L_w_odd),
    .frozen(frozen1),
    .out_valid,
    .u(u1),
    .v(v1)
    );
    
    logic signed [BITS-1:0] L_w_even[N/2];
    for (genvar index = 0; index < N/2; index++)
      g #(.BITS(BITS)) g_array
      (
        .a(y[2*index]),
        .b(y[2*index+1]),
        .u(v1[index]),
        .c(L_w_even[index])
      );
    
    logic frozen2[N/2];
    for (genvar i = 0; i < N/2; i++)
      assign frozen2[i] = frozen[N/2+i];
    logic u2[N/2];
    logic v2[N/2];
    recursive_decode #(.BITS(BITS), .N(N/2)) recursive_decode2
    (
    .clk,
    .in_valid,
    .y(L_w_even),
    .frozen(frozen2),
    .out_valid(),
    .u(u2),
    .v(v2)
    );
    
    for (genvar g = 0; g < N/2; g++)
      begin
        assign u[g] = u1[g];
        assign u[N/2+g] = u2[g];
        assign v[2*g] = v1[g] ^ v2[g];
        assign v[2*g+1] = v2[g];
      end
  end

endmodule
