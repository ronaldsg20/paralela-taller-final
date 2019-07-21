//BLOCKWISE
#include "omp.h"
#include <stdio.h>
#include <stdlib.h>
//For  CUDA
#include <cuda.h>
#include <helper_cuda.h>
#include <cuda_runtime.h>


using namespace std;

int main(int argc, char **argv)
{
    //define variables
    int  n  = 16;
    //Host matrix
    int* h_a;
    int* h_b;
    int* h_c;

    //Device  matrix
    int* d_a;
    int* d_b;
    int* d_c;

    size_t  bytes = n*n*sizeof(int);

    //Allocate memory in host
    h_a =(int*)malloc(bytes);
    h_b =(int*)malloc(bytes);
    h_c =(int*)malloc(bytes);

    //Initialize matrix
    for (int i=0;i<n;i++){
        for(int  j=0;j<n;j++){
            h_a[i*n+j]  =  rand()%10;
            h_b[i*n+j]  =  rand()%10;
            h_c[i*n+j] =  0;
        }
    }
    
    
    return 0;

}
