`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/25/2019 09:23:02 PM
// Design Name: 
// Module Name: channel_tasks_pkg
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


package channel_tasks_pkg;

import math_pkg::*;

virtual class ElementRepeat #(parameter BITS=8);
typedef logic[BITS-1:0] encoded_t[];
static function encoded_t Encode(logic data[], int N, int length = 0);
  if (length == 0)
    length = data.size();
  Encode = new[length * N];
  for (int i = 0; i < length; i++)
    for (int j = 0; j < N; j++)
      Encode[N*i+j] = data[i];
endfunction

typedef logic decoded_t[];
static function decoded_t Decode(logic signed [BITS-1:0] noisy[], int N, int length = 0);
  int K;
  int sum;  
  if (length == 0)
    length = noisy.size();
  K = length/N;
  Decode = new[K];
  for (int i = 0; i < K; i++)
    begin
      sum = 0;
      for (int j = 0; j < N; j++)
        sum = sum + noisy[N*i+j];
      if (sum >= 0)
        Decode[i] = 1;
      else
        Decode[i] = 0;
    end
endfunction
endclass

typedef logic random_bits_t[];

function random_bits_t RandomBits(int count);
  RandomBits = new[count];
  for (int i = 0; i < count; i++)
    RandomBits[i] = ($random() > 0.5) ? 1 : 0;
endfunction

function int Errors(logic data[], logic decoded[]);
  Errors = 0;
  for (int i = 0; i < data.size(); i++)
    if (data[i] != decoded[i])
      Errors++;
  //error_rate =  1.0 * errors / K;
endfunction

function real RandStdNormal();
  real PI = 3.14159;
  real u1;
  real u2;
  real u3;
  real u4;

  u3 =  0.5 + $random()/(2.0**32);
  
  u1 = 1.0 - u3; //$dist_normal( seed, mean, std_deviation )/1024.0; //uniform(0,1]
  u4 = log(u1);
  u2 = 0.5 - $random()/(2.0**32); // $dist_normal( seed, mean, std_deviation )/1024.0;
  return sqrt(-2.0 * log(u1)) * sin(2.0 * PI * u2); //random normal(0,1)
endfunction

virtual class Noise #(parameter BITS=8);
  parameter CLEAN_HIGH = 1 << BITS-2;
  parameter CLEAN_LOW = -CLEAN_HIGH;
  parameter HIGH_LIMIT = 1 << BITS-1;
  parameter LOW_LIMIT = -HIGH_LIMIT;
  typedef logic signed [BITS-1:0] noisy_t[];
  static function noisy_t Add(logic encoded_data[], real snr, int length=0);
    real noise;
    if (length == 0)
    length = encoded_data.size();
    Add = new[encoded_data.size()];
    Add = '{default : 0};
    for (int i = 0; i < length; i++)
      begin
        if (encoded_data[i] == 1)
          Add[i] = CLEAN_HIGH;
        else
          Add[i] = CLEAN_LOW;
        noise = RandStdNormal();
        noise = noise * CLEAN_HIGH / snr;
        if (noise > 0)
          if (noise + Add[i] > HIGH_LIMIT)
            Add[i] = HIGH_LIMIT;
          else
            Add[i] = noise + Add[i];
        else
          if (noise + Add[i] < LOW_LIMIT)
            Add[i] = LOW_LIMIT;
          else
            Add[i] = noise + Add[i];
      end
  endfunction
  typedef logic signed [BITS-1:0] array_t[];
  static function array_t Minus(signed [BITS-1:0] data[]);
    Minus = new[data.size()];
    for (int i = 0; i < data.size(); i++)
      Minus[i] = -data[i];
  endfunction
  static function array_t Reverse(signed [BITS-1:0] data[]);
    int length;
    length = data.size();
    Reverse = new[length];
    for (int i = 0; i < length; i++)
      Reverse[i] = data[length-1-i];
  endfunction
  static function array_t DivideByTwo(signed [BITS-1:0] data[]);
    int length;
    length = data.size();
    DivideByTwo = new[length];
    for (int i = 0; i < length; i++)
      DivideByTwo[i] = data[i]/2;
  endfunction  
  typedef logic [BITS-1:0] array_unsigned_t[];
  static function array_unsigned_t ReverseUnsigned(logic [BITS-1:0] data[]);
    int length;
    length = data.size();
    ReverseUnsigned = new[length];
    for (int i = 0; i < length; i++)
      ReverseUnsigned[i] = data[length-1-i];
  endfunction  
endclass

endpackage
