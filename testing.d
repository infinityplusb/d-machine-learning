import std.stdio;
import nnet;

void main()
{
  string inputFile = "/home/brian/Documents/Data/nnet-test-data/hopfield-train-data-1.csv";
  int[][] weightMatrix = new int[][](0);
  
  train(inputFile,  weightMatrix);
  
  debug   writeln("weightMatrix: ");
  debug  foreach(line;0 .. weightMatrix.length) writeln(weightMatrix[line]);  
  debug writeln();
debug  writeln("Weight Matrix has length: ", weightMatrix.length);
  
  string testFile = "/home/brian/Documents/Data/nnet-test-data/hopfield-test-data.csv";
  int[][] energyMatrix = new int[][](0);
  int[] returnArray = new int[weightMatrix.length];
  test(testFile, weightMatrix, energyMatrix);
}