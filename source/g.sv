`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/18/2019 09:20:16 PM
// Design Name: 
// Module Name: g
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


module g
#(parameter BITS=4)
(
input signed [BITS-1:0] a,
input signed [BITS-1:0] b,
input u,
output logic signed [BITS-1:0] c
);

assign c = (u == 0) ? b + a : b - a;

endmodule
