`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/28/2019 01:06:27 AM
// Design Name: 
// Module Name: frozen_assign_tb
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


module frozen_assign_tb();

parameter K = 16, N = 32;

logic data[K];
logic [$clog2(N):0] sorted_indexes[N];
logic inserted[N];
logic recovered_data[K];

int sorted_indexes_int[N] = GetSortedIndexes($clog2(N), 0.1, 100);

task SetSortedIndexes();
  for (int i = 0; i < N; i++)
    sorted_indexes[i] = sorted_indexes_int[i];
endtask

initial
  begin
    #10
    SetSortedIndexes();
    data = '{ 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0};
    #10;
    data = '{ 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1};
    #10;
    data = '{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1};
    #10;   
    $stop;
  end

frozen_assign
#(.N(N), .K(K))
frozen_assign1
(
.data,
.sorted_indexes,
.inserted
);

frozen_recover
#(.N(N), .K(K))
frozen_recover1
(
.decoded_data(inserted),
.sorted_indexes,
.data(recovered_data)
);

endmodule
