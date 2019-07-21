
#include <stdlib.h>
#include <cstdint>
#include <omp.h>
#include <stdio.h>
#include <string.h>

using namespace std;
//global variables
int **A;
int **B;
int **R;
int N;
int HILOS;

int main(int argc, char **argv)
{
   if ( argc !=  5)
    {
        printf("usage: ./matrixMult MatA.csv MatB.csv <N> <HILOS>\n");
        return -1;
    }
   char buffer[1024] ;
   char *record,*line;
   int i=0,j=0;
   int mat[8][8];
   //printf("%s",argv[1]);
   FILE *fstream = fopen(argv[1],"r");
   if(fstream == NULL)
   {
      printf("\n file opening failed ");
      return -1 ;
   }
   while((line=fgets(buffer,sizeof(buffer),fstream))!=NULL)
   {
     j = 0;
     record = strtok(line,",");
     while(record != NULL)
     {
     A[i][j++] = atoi(record) ;
     //printf("%d ",mat[i][j]);
     record = strtok(NULL,",");
     }
     ++i ;
   }
   i=0;
   j=0;
   fstream = fopen(argv[2],"r");
   if(fstream == NULL)
   {
      printf("\n file opening failed ");
      return -1 ;
   }
   while((line=fgets(buffer,sizeof(buffer),fstream))!=NULL)
   {
     j = 0;
     record = strtok(line,",");
     while(record != NULL)
     {
     B[i][j++] = atoi(record) ;
     //printf("%d ",mat[i][j]);
     record = strtok(NULL,",");
     }
     ++i ;
   }

    N = atoi(argv[3]);
    HILOS = atoi(argv[4]);
   // create result matrix
   #pragma omp parallel num_threads(HILOS)
    {
        int tn = omp_get_thread_num();
        int ini = (int)(N/HILOS)*(tn-1);
        int fin = (int)(N/HILOS)+ini;
        printf("thread %d inicio: %d fin : %d \n",tn,ini,fin);
    }


    // print matrix for testing
    for (int h = 0; h < N; h++)
    {
        for (int k = 0; k < N; k++)
        {
            printf("%d ",R[h][k]);
        }
        printf("\n");
    }
    
   //write the matrix


    return 0;
}
