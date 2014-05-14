#!/usr/bin/rdmd
import std.stdio;
import std.array;
import std.conv;
import std.string;

void weights(ref int[][] W,in int[] x0,in int[] x1,in int[] x2,in int N)
{
  foreach(row;0 .. W.length)
    foreach(point;0..W[row].length)
       W[row][point] = x0[row]*x0[point]
                        + x1[row]*x1[point]
                        + x2[row]*x2[point];
  foreach(k;0..N)
    W[k][k] = 0;
    
debug writeln("W: ", W);
}

void mul(in int[][] W,in int[] s,ref int[] h,in int N)
{
  foreach(row;0 .. W.length)
  {
debug writeln(row);
debug writefln("Initial h[%d]: %d", row, h[row]);
    int sum = 0;
    foreach(point;0..W[row].length)
    {   
      sum += W[row][point]*s[point];
    }
    h[row] = sum;
debug writefln("Output h[%d]: %d", row, h[row]);
  }
debug writeln("h: " , h);
}

int sign(int y)
{
debug  writefln("...getting sign of %d",  y);
  if (y > 0)
  {
debug writeln("Returning 1");
    return 1;
  }
  else 
  {
debug writeln("Returning -1");
    return -1;
  }
}

int check(int[] v1, int[] v2, int N)
{
  if (v1 == v2)
    return 1;
  else 
    return 0;
}

int energy(int[][] W, int[] s, int N)
{
  int Energy = 0;
  foreach(row;0 .. W.length)
  {
    foreach(point;0..W[row].length)
    {
      Energy += W[row][point]*s[row]*s[point];
    }
  }
//  writefln("Energy is: %d", Energy);
  return Energy;
}

void readInFile(in string inFile)
{
  auto file2readIn = File(inFile);
  int count = 0;
  int[][] inMatrix = new int[][](0);
  foreach(line; file2readIn.byLine())
  {
    int[] bob = new int[0];
debug    writeln(count);
debug    writeln(line);
debug    writeln();
    foreach(item;line.split(","))
    {
debug      writeln(item);
      bob ~=  to!int(strip(item));
    }
    inMatrix ~= bob;
    
debug    writefln("Line number %d", count);
    count++;
  }
  
debug  writeln(inMatrix);
}

void main()
{
  int N = 40;
  string inputFile = "/home/brian/Documents/Data/nnet-test-data/hopfield-train-data.csv";
  
  readInFile(inputFile);
  
  int[] x0 = [-1, -1, 1, -1, -1, -1, 1, 1, -1, -1, -1, -1, 1, -1, -1, -1, -1, 1, -1, -1, -1, -1, 1, -1, -1, -1, -1, 1, -1, -1, -1, -1, 1, -1, -1, -1, -1, -1, -1, -1];
  int[] x1 = [-1, 1, 1, 1, -1, 1, -1, -1, -1, 1, -1, -1, -1, -1, 1, -1, -1, 1, 1, -1, -1, 1, -1, -1, -1, 1, -1, -1, -1, -1, 1, 1, 1, 1, 1, -1, -1, -1, -1, -1];
  int[] x2 = [1, -1, -1, 1, -1, 1, -1, -1, 1, -1, 1, -1, -1, 1, -1, 1, 1, 1, 1, 1, -1, -1, -1, 1, -1, -1, -1, -1, 1, -1, -1, -1, -1, 1, -1, -1, -1, -1, -1, -1];
  assert(x0.length  == 40);
  assert(x1.length  == 40);
  assert(x2.length  == 40);
  
  int[][] weightMatrix = new int[][](40, 40);  
  weights(weightMatrix, x0, x1, x2, N);   
  
  int[] s = [1, 1, -1, 1, -1, -1, 1, -1, 1, 1, 1, -1, -1, 1, -1, 1, -1, 1, 1, 1, -1, -1, -1, -1, -1, -1, -1, 1, 1, -1, -1, -1, -1, 1, -1, -1, -1, -1, -1, -1];
/*  int[] s = [ -1,  1,  1, -1, -1, 
              -1, -1,  1,  1,  1, 
              -1, -1,  1, -1, -1, 
              -1, -1, -1,  1, -1, 
              -1, -1,  1, -1, -1, 
              -1, -1, -1,  1, -1, 
              -1, -1,  1, -1, -1, 
              -1, -1, -1, -1, -1];
*/
  assert(s.length == 40);
  
  int E = energy(weightMatrix, s, N);
  writefln("Energy of the initial configuration: %d",  E);
  
  int[] h = new int[](N);

  int[] s1 = s.dup;
 
  assert(s !is s1);
  int count = 0;
  int result;
  
  do
  {
    s1=s.dup;
    assert(s1 !is s);
    mul(weightMatrix, s, h, N);
    
debug writeln(h);
debug writeln(s);
debug writeln(s1);

    foreach(point;0 .. h.length)
    {
debug writeln("Point: ",  point);
      if (h[point] != 0 )
      {
debug writefln("I've changed s from %d to %d",  s[point], sign(h[point]));
debug writeln (h[point]);
        s[point] = sign(h[point]);
      }
      else 
      {  s[point] = s1[point];}
debug writefln("point: %d   s[point]: %d   s1[point]: %d",point, s[point],  s1[point]);
debug writeln(s);
    }
debug writeln(s);
debug writeln(s1);
    
debug foreach(point;0 .. h.length) { writefln("s1     %d   %d      s",  s1[point], s[point]);}
    writefln("Energy of the initial configuration: %d", energy(weightMatrix, s, N));
    result = check(s, s1, N);
    count++;
    writefln("Count is: %d", count);
  }
  while ((count < 100) && (result != 1));
  
  writefln("The number of iterations is: %d",  count);
  
  foreach(line;0 .. 7)
    writeln(s[line*5+0 .. line*5+5]);
}