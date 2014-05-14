module nnet;

import std.stdio;
import std.string;
import std.array;
import std.conv;

void train(in string FileToTrain, ref int[][] weightMatrix)
{
  int maxEntries = 0;
  int minEntries = 0;
  int count = 0;
  
  int[][] inMatrix = new int[][](0);
  
  readInFile(FileToTrain, minEntries, maxEntries, count, inMatrix);
  int[][] weightMatrix1 = new int[][](minEntries, minEntries);
  
  weightMatrix = weightMatrix1;
  
  weights(weightMatrix, inMatrix);
  
  writefln("Trained %d lines.\n", count);
debug  writeln("Weight Matrix length: ", weightMatrix.length);
debug  writeln("Weight Matrix Line length: ", weightMatrix[0].length);

//  writeln(inMatrix);
}

void readInFile(string locationToReadFrom,ref int maxEntries,ref int minEntries,
    ref int count,  ref int[][] inMatrix)
{
  writefln("\nI'm reading %s",locationToReadFrom);
  auto file2readIn = File(locationToReadFrom);

  int[] bob = new int[0];

  foreach(line; file2readIn.byLine())
  {
    bob.clear;
    debug    writeln(count);
    debug    writeln(line);
    debug    writeln();
    // add each item in a line into an array cell
    foreach(item;line.split(","))
    {
      debug      writeln(item);
      bob ~=  to!int(strip(item));
    }
    // add the array onto the large matrix
    inMatrix ~= bob;
    int length = to!int(bob.length);
    
    if (count ==  0)
      maxEntries = minEntries = length;
    else if (length > maxEntries)
      maxEntries = length;
    else if (length < minEntries)
      minEntries = length;

    debug    writeln("Min Entries: " ,  minEntries);

    // output the count of lines
    // useful for larger files
    if (count % 1000 == 0 && count != 0)
      writefln("Line number %d", count);
    count++;
  }
}

void weights(ref int[][] W,in int[][] X)
{
  int sum;
  foreach(row;0 .. W.length)
    foreach(column;0..W[row].length)
    {
      sum = 0;
      foreach(ob_row;0 .. X.length)
        sum += X[ob_row][row] * X[ob_row][column];
        
      W[row][column] = sum;
    }
    
  foreach(k;0..W.length)
    W[k][k] = 0;

debug  writeln("W: "); 
debug  foreach(line;0 .. W.length) writeln(W[line]);
  
}

int energy(int[][] W, int[] s)
{
  int Energy = 0;
  foreach(row;0 .. W.length)
    foreach(column;0..W[row].length)
    {
      Energy += W[row][column]*s[row]*s[column];
    }
  //  writefln("Energy is: %d", Energy);
  return Energy;
}

void mul(in int[][] W,in int[] s,ref int[] h)
{
  foreach(row;0 .. W.length)
  {
    debug writeln(row);
    debug writefln("Initial h[%d]: %d", row, h[row]);
    int sum = 0;
    foreach(point;0..W[row].length)
    {   
      debug writeln(W[row][point]);
      debug writeln(s[point]);
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

int check(int[] v1, int[] v2)
{
  if (v1 == v2)
    return 1;
  else 
    return 0;
}

void test(in string testFile, int[][] weightMatrix, ref int[][] trainMatrix)
{
  writefln("Testing this file: %s", testFile);
  int maxTestEntries = 0;
  int minTestEntries = 0;
  int countTest = 0;

  readInFile(testFile, minTestEntries, maxTestEntries, countTest, trainMatrix);
debug  writeln("Train Matrix: ");  
debug foreach(line;0 .. trainMatrix.length) writeln(trainMatrix[line]);
    
  foreach(line; trainMatrix)
  {
    auto ob = line;
debug    writeln(line);
    int E = energy(weightMatrix, ob);
debug    writefln("Energy of the initial configuration: %d",  E);
    
    int[] h = new int[](weightMatrix.length);
debug    writeln("H has length: ",  h.length);
    int[] ob1 = ob.dup;
    
    int countOb = 0;
    int result;
    
    do
    {
      ob1 = ob.dup;
      mul(weightMatrix, line, h);
      foreach(point;0 .. h.length)
      {
        if ( h[point] != 0 )
          ob[point] = sign(h[point]);
        else
          ob[point] = ob1[point];
      }
debug      writefln("Energy of the configuration is: %d",  energy(weightMatrix, ob));
      result = check(ob, ob1);
      
      countOb++;
debug      writefln("Count is: %d", countOb);
    }
    while ((countOb < 100) && (result != 1));
      
    writefln("The number of iterations is: %d", countOb);
    
    foreach(thing;0 .. 7)
    writeln(ob[thing*5+0 .. thing*5+5]);
  }
}