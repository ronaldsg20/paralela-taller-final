//BLOCKWISE
#include "omp.h"
#include <stdio.h>
#include <stdlib.h>
//For  CUDA
#include <cuda.h>
#include <helper_cuda.h>
#include <cuda_runtime.h>


using namespace std;

__global__ void multiplication(int*  a,int* b,int*  c,int n,int threads){
    //Calculate row and column
    //int r =blockIdx.y*blockDim.y+threadIdx.y
    int tn = (blockDim.x * blockIdx.x) + threadIdx.x;
    
    int ini = n/threads*(tn);
    int fin = n/threads+ini;

    int i, j, k; 
    if(tn <n){
        for (i = ini; i < fin; i++) { 
            for (j = 0; j < n; j++) { 
                for (k = 0; k < n; k++) 
                    c[i*n+j]  += a[i*n+k] * b[k*n+j];
            } 
        }
    }
}
/*__host__  void  multiplication2(int* a,int* b,int* c,int  size){
    for(int i=0;i<size;i++){
        for(int   j=0;j<size;i++){
            for(int k=0;k<size;k++){
                c[i*size+j]  += a[i*size+k] * b[k*size+j];
            }
        }
    }
}*/


int main(int argc, char **argv)
{
    
    //define variables
    int  n  = atoi(argv[1]);

    cudaSetDevice(0);
    cudaDeviceProp deviceProp;
    cudaGetDeviceProperties(&deviceProp,0);

    int blocks = deviceProp.multiProcessorCount;
    int threads= (int)(n/blocks);
    //Host matrix
    int* h_a;
    int* h_b;
    int* h_c;
    //int* h_c_s;

    //Device  matrix
    int* d_a;
    int* d_b;
    int* d_c;

    size_t  bytes = n*n*sizeof(int);

    //Allocate memory in host
    h_a =(int*)malloc(bytes);
    h_b =(int*)malloc(bytes);
    h_c =(int*)malloc(bytes);
   // h_c_s =(int*)malloc(bytes);

    //Initialize matrix
    for (int i=0;i<n;i++){
        for(int  j=0;j<n;j++){
            h_a[i*n+j]  =  rand()%10;
            h_b[i*n+j]  =  rand()%10;
        }
    }

    //Allocate memory  in device
    cudaMalloc(&d_a,bytes);
    cudaMalloc(&d_b,bytes);
    cudaMalloc(&d_c,bytes);

    //Copy  data  host to   device
    cudaMemcpy(d_a,h_a,bytes,cudaMemcpyHostToDevice);
    cudaMemcpy(d_b,h_b,bytes,cudaMemcpyHostToDevice);

    //Write blocks  and threads
    
    //dim3 block_size(threads_block,threads_block);
      //<<<Bloques,hilos>>>
    
    multiplication  <<<blocks,threads>>> (d_a,d_b,d_c,n,threads);
    //multiplication2(h_a,h_b,h_c_s,n);
  
    //Copy  data  device to host
  
    cudaMemcpy(h_c,d_c,bytes,cudaMemcpyDeviceToHost);
 
   if (n<9){
    printf( "Output Matrix: \n");
    for(int i = 0; i <n; ++i)
    for(int j = 0; j < n; ++j)
    {
        printf(" %d",h_a[n*i+j]) ;
        if(j == n-1)
            printf("\n");
    }

    printf("\n");
    for(int i = 0; i <n; ++i)
    for(int j = 0; j < n; ++j)
    {
        printf(" %d",h_b[n*i+j]) ;
        if(j == n-1)
           printf("\n");
    }
    printf("\n");
    for(int i = 0; i <n; ++i)
    for(int j = 0; j < n; ++j)
    {
        printf(" %d",h_c[n*i+j]) ;
        if(j == n-1)
           printf("\n");
    }
    printf("\n");

   }
    
    // free memory

    cudaFree(d_a);
    cudaFree(d_b);
    cudaFree(d_c);
    free(h_a);
    free(h_b);
    free(h_c);
    //free(h_c_s);

    
    
    return 0;

}
