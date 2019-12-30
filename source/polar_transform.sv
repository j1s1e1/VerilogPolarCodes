`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/14/2019 12:15:19 AM
// Design Name: 
// Module Name: polar_transform
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


module polar_transform
#(parameter BITS = 2)
(
input clk,
input in_valid,
input u[BITS],
output logic out_valid = 0,
output logic x[BITS]
);

if (BITS > 2)
  begin
    logic u_even[BITS/2];
    logic u_odd[BITS/2];
    for (genvar g = 0; g < BITS/2; g++)
      begin
        assign u_odd[g] = u[2*g] + u[2*g+1];
        assign u_even[g] = u[2*g];
      end
    polar_transform
    #(.BITS(BITS/2))
    polar_transform1
    (
    .clk,
    .in_valid,
    .u(u_even),
    .out_valid(out_valid),
    .x(x[0:BITS/2-1])
    );
    polar_transform
    #(.BITS(BITS/2))
    polar_transform2
    (
    .clk,
    .in_valid,
    .u(u_odd),
    .out_valid(),
    .x(x[BITS/2:BITS-1])
    );
  end
else
  begin
    always @(posedge clk)
      out_valid <= in_valid;
    always @(posedge clk)
      case ({u[1],u[0]})
        2'b00: x <= '{0,0};
        2'b01: x <= '{1,1};
        2'b10: x <= '{0,1};
        2'b11: x <= '{1,0};
      endcase
  end
endmodule
