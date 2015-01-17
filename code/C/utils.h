
 /*************************************************************************/
 /* kaverages, an efficient iterative clustering algorithm.		  */
 /* Please refer to the accompanying README file for further information. */
 /* 									  */
 /* Written by Mathias Rossignol and Mathieu Lagrange,			  */
 /*  Copyright (C) 2015  IRCAM <http://www.ircam.fr>			  */
 /* 									  */
 /* This program is free software: you can redistribute it and/or modify  */
 /* it under the terms of the GNU General Public License as published by  */
 /* the Free Software Foundation, either version 3 of the License, or	  */
 /* (at your option) any later version.					  */
 /*  									  */
 /* This program is distributed in the hope that it will be useful,	  */
 /* but WITHOUT ANY WARRANTY; without even the implied warranty of	  */
 /* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the	  */
 /* GNU General Public License for more details.			  */
 /* 									  */
 /* You should have received a copy of the GNU General Public License	  */
 /* along with this program.  If not, see <http://www.gnu.org/licenses/>. */
 /*************************************************************************/

#ifndef __UTILS_H__
#define __UTILS_H__

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <math.h>
#include <stdint.h>
#include <time.h>

#define dbg(...) fprintf(stderr, __VA_ARGS__); fprintf(stderr, "\n");

// Displays an error message (parameters like for printf) and terminates the program
void errorAndQuit (const char *format, ...);

// Generates random numbers following a normal distribution with the given mean and sigma
double normalRandom(double mean, double sigma);

// Opens a file for reading, handling errors.
FILE *openInFile (const char *fileName);

// Opens a file for writing, handling errors.
FILE *openOutFile (const char *fileName);

// Returns floor(sqrt(x)), computed using 64-bit integer arithmetic only
int64_t intSquareRoot (int64_t x);

// Creates a square matrix of doubles, whose elements can be simply accessed as mat[i][j]
// The returned matrix is properly zero-initialized
// Do not forget to call 'freeMatrix' (below) when you don't need the matrix anymore
double **newMatrix (long size1, long size2);

// Call this function to free the memory allocated by 'newSquareMatrix'
void freeMatrix (double **matrix);

// Loads labels from a file into a given int matrix, and returns the number of labels
// Labels are normalized after reading to fit into the interval [0, nbLabels-1]
// 'nbObjects' gives the expected number of objects, which must also be the size of 'labels';
// If the file does not contain 'nbObjects' labels, a (clean) error will occur.
int loadLabels (const char *fileName, long nbObjects, int *labels);

// 'timerEnd' returns the number of microseconds elapsed since the last call to 'timerStart'
// This is actual "timeofday" time, not CPU time (CPU time only considers time for this process,
// which is good, but doesn't include I/O time, which is bad)
void timerStart();
double timerEnd();

#endif
