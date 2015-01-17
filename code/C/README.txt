
A suite of programs to perform efficient iterative clustering using
the k-averages algorithm, with a reference implementation of kernel
k-means for comparison purposes.

All code written by Mathias Rossignol and Mathieu Lagrange
    Copyright (C) 2015 IRCAM <http://www.ircam.fr>

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.


CONTENTS:

* txtMatrixToBinary -i infile -o outfile

  Use this program to convert a similarity matrix represented as text
  into a binary file that can be directly loaded by the clustering
  programs. The input file simply contains all the matrix values as
  text, that's all. No size needed (it's a square matrix, so it's easy
  for the program reading the binary file to figure out the matrix
  dimensions from the file size).


* kaverages -m similarityMatrix (-c numberOfClasses | -l initLabelsFile) -o outfilePrefix [-r] [-rs randomSeed]

  Cluster objects into c classes using the kaverages algorithm. The
  file "outfilePrefix.log" will contain details of execution (loops,
  running time, etc), and "outfilePrefix.labels" will contain labels,
  as text.
  Line 1 : <number of objects> <number of classes>
  Line 2 : labels, separated by spaces

  Optionally, one may specify an init labels file instead of a number
  of classes (if both -c and -l are present, -c is ignored), and
  request that the algorithm run in raw mode (-r switch).

  Specifying a random seed allows to re-generate the exact same init
  data. If none is given, the current time will be used. If init
  labels are given, that option is useless.


* kkmeans -m similarityMatrix  (-c numberOfClasses | -l initLabelsFile) -o outfilePrefix [-rs randomSeed]

  Same as kaverages, but using the kernel k-means algorithm.
  No '-r' option, since that is not relevant here.
