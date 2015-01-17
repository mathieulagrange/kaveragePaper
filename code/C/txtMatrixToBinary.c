
 /*************************************************************************/
 /* Simple utility allowing to convert a text matrix file to binary mode. */
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

#include <stdio.h>
#include <string.h>
#include "utils.h"

int main (int argc, const char **argv) {

  const char *inFile = NULL;
  const char *outFile = NULL;

  int p = 1;
  while (p<argc) {
    if (!strcmp(argv[p], "-i")) inFile = argv[++p];
    else if (!strcmp(argv[p], "-o")) outFile = argv[++p];
    else  errorAndQuit("\nUsage: %s -i inFile -o outFile\n\n", argv[0]);
    p++;
  }
  if (!inFile || !outFile) errorAndQuit("\nUsage: %s -i inFile -o outFilen\n\n", argv[0]);

  FILE *fin  = openInFile (inFile);
  FILE *fout = openOutFile(outFile);

  long count = 0;
  double val;
  while (fscanf(fin, "%lf", &val) != EOF) {
    count++;
    fwrite(&val, sizeof(double), 1, fout);
  }
  
  fprintf(stderr, "\nRead and wrote %li values.\n\n", count);

}
