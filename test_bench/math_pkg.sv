`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/27/2019 05:12:19 PM
// Design Name: 
// Module Name: math_pkg
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


package math_pkg;

  //import dpi task      C Name = SV function name
  real PI = 3.14159;

  import "DPI-C" pure function real cos (input real rTheta);

  import "DPI-C" pure function real sin (input real rTheta);

  import "DPI-C" pure function real log (input real rVal);

  import "DPI-C" pure function real log10 (input real rVal);
  
  import "DPI-C" pure function real sqrt (input real rVal);
  
  import "DPI-C" pure function real fmod (input real rVal, input real modVal);

endpackage : math_pkg

