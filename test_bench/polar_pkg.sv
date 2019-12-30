`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/26/2019 01:59:42 AM
// Design Name: 
// Module Name: polar_pkg
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


package polar_pkg;

typedef real cnop_t[];
function cnop_t  Cnop(real a[], real b[]);
  int length = a.size();
  Cnop = new[length];
  for (int i = 0; i < length; i++)
    Cnop[i] = a[i] * (1 - b[i]) + b[i] * (1 - a[i]);
endfunction

typedef real vnop_t[];
function vnop_t Vnop(real a[], real b[]);
  int length = a.size();
  Vnop = new[length];
  for (int i = 0; i < length; i++)
    Vnop[i] = a[i] * b[i] / (a[i] * b[i] + (1 - a[i]) * (1 - b[i]));
endfunction

typedef int polar_decode_t[];

function automatic polar_decode_t PolarDecode(real data[], real f[], output real x[]);
  automatic int length = data.size();
  automatic real left[];
  automatic real right[];
  automatic real u1est[]; 
  automatic real fstart[];
  automatic real fend[];
  automatic int uhat1[];
  automatic real u2est[];
  automatic int uhat2[];
  automatic real u1hardprev[];
  automatic real u2hardprev[];
  automatic real xhigh[];
  automatic int data0;
  PolarDecode = new[length];
  x = new[length];

  if (length == 1)
    if (f[0] == 1.0 / 2.0)
      begin
        // If info bit, make hard decision based on observation
        data0 =  data[0];
        x[0] = data0; // (int)
        PolarDecode[0] = data0;
      end
    else
      begin
         // Use frozen bit for output and hard decision for input(for monte carlo design)
         x[0] = f[0];
         PolarDecode[0] = (data[0]); // (int) -- don't need to add hear since verilog rounds to nearest
       end
  else
    begin
      length = data.size() / 2;
      left = new[length];
      right = new[length];
      for (int i = 0; i < length; i++)
        begin
            left[i] = data[2*i+1];
            right[i] = data[2 * i];
          end
        // Compute soft mapping back one stage
        u1est = Cnop(left, right);
        // R_N ^ T maps u1est to top polar code
        fstart = new[length];
        fend = new[length];
        for (int i = 0; i < length; i++)
          begin
            fstart[length - 1 - i] = f[i];
            fend[length - 1 - i] = f[length + i];
          end
        uhat1 = PolarDecode(u1est, fstart, u1hardprev);
        // Using u1est and x1hard, we can estimate u2
        u2est = Vnop(Cnop(u1hardprev, left), right);
        // R_N ^ T maps u2est to bottom polar code
        uhat2  = PolarDecode(u2est, fend, u2hardprev);
        // Tunnel u decisions back up. Compute and interleave x1, x2 hard decisions
        for (int i = 0; i < length; i++)
          PolarDecode[i] = uhat2[i];
        for (int i = 0; i < length; i++)
          PolarDecode[length + i] = uhat1[i];
        xhigh = Cnop(u1hardprev, u2hardprev);
        for (int i = 0; i < length; i++)
          x[i] = u2hardprev[i];
        for (int i = 0; i < length; i++)
          x[length + i] = xhigh[i];  
      end
endfunction

function void Reverse(inout real data[]);
  real copy[];
  int length = data.size();
  copy = new[length];
  for (int i = 0; i < length; i++)
    copy[i] = data[length-1-i];
  data = copy;
endfunction

typedef real bit_err_t[];

function bit_err_t  BitErr(int n, real p, int M);
  real f[];
  real y[];
  int uhat[];
  real xhat[];
  int N = 2**n;
  real rand_num;
  f = new[N];
  BitErr = new[N];
  BitErr = '{default : 0};

  // fix Random rand = new Random();
  // Monte Carlo evaluation of error probability
  for (int i = 0; i < M; i++)
    begin
      // Transmit all - zero codeword through BSC(p)
      y = new[N];
      for (int j = 0; j < N; j++)
        begin
          y[j] = p;
          rand_num = $urandom() / 2.0**32;
          if (rand_num < p)
            y[j] = 1 - p;
          //y[j] = Math.Log((1-y[j])/y[j]);
        end
      // Decode received vector using all - zero frozen vector
      //int[] uhat = rec.Decode(y, f, out int[] xhat);
      uhat = PolarDecode(y, f, xhat);
      for (int j = 0; j < N; j++)
        BitErr[j] += uhat[j];
    end
  for (int j = 0; j < N; j++)
    BitErr[j] /= (1.0 * M);
  Reverse(BitErr);
endfunction

typedef real sort_t[];
function sort_t Sort(real data[]);
  int length = data.size();
  int j;
  Sort = new[length];
  Sort[0] = data[0];
  for (int i = 1; i < length; i++)
    begin
      j = i-1;
      while (data[i] < Sort[j] && j >= 0)
        j--;
      if (j < i-1)
        begin
          for (int k = i; k > j; k--)
            Sort[k] = Sort[k-1];
        end
      Sort[j+1] = data[i];
    end
endfunction

typedef int sorted_indexes[];
function sorted_indexes SortedIndexes(real data[]);
  int length = data.size();
  int j;
  real sort[];
  SortedIndexes = new[length];
  SortedIndexes = '{default : 0};
  sort = new[length];
  sort[0] = data[0];
  for (int i = 1; i < length; i++)
    begin
      j = i-1;
      while (data[i] < sort[j] && j >= 0)
        j--;
      if (j < i-1)
        begin
          for (int k = i; k > j; k--)
            begin
              sort[k] = sort[k-1];
              SortedIndexes[k] = SortedIndexes[k-1];
            end
        end
      sort[j+1] = data[i];
      SortedIndexes[j+1] = i;
    end
endfunction

typedef logic frozen_t[];        
function frozen_t SelectFrozen(int n, real p, int M, int Z);
    int N = 2**n;
    real biterrd[];
    real sorted[];
    int sortedIndexes[];
    real limit;
    SelectFrozen = new[N];
    SelectFrozen = '{default : 0};
    biterrd = BitErr(n, p, M);
    sorted = Sort(biterrd);
    limit = sorted[Z-1];
    sortedIndexes = SortedIndexes(biterrd);
    /*
    for (int i = 0; i < N; i++)
      if (biterrd[i] <= limit)
        SelectFrozen[i] = 1;
    */
    // Guarantee number of results
    for (int i = 0; i < Z; i++)
      SelectFrozen[sortedIndexes[i]] = 1;
 endfunction
 
typedef int sorted_indexes_t[];        
function sorted_indexes_t GetSortedIndexes(int n, real p, int M);
    int N = 2**n;
    real biterrd[];
    int sortedIndexes[];
    GetSortedIndexes = new[N];
    biterrd = BitErr(n, p, M);
    GetSortedIndexes = SortedIndexes(biterrd);
 endfunction

endpackage
