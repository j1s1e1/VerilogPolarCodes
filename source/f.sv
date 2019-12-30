`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/18/2019 09:16:54 PM
// Design Name: 
// Module Name: f
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


module f
#(parameter BITS=4)
(
input signed [BITS-1:0] a,
input signed [BITS-1:0] b,
output logic signed [BITS-1:0] c
);

logic [BITS-2:0] abs_a;
logic [BITS-2:0] abs_b;
logic [BITS-2:0] abs_c;

assign abs_a = (a[BITS-1] == 1) ? ~a[BITS-2:0] + 1 : a[BITS-2:0];
assign abs_b = (b[BITS-1] == 1) ? ~b[BITS-2:0] + 1 : b[BITS-2:0];

assign c[BITS-1] = a[BITS-1] ^ b[BITS-1];
assign abs_c = (abs_b < abs_a) ? abs_b : abs_a;

assign c[BITS-2:0] = (c[BITS-1] == 1) ? ~abs_c + 1 : abs_c;

endmodule
