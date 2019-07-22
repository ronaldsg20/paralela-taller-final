//BLOCKWISE
#include "omp.h"
#include <stdio.h>
#include <stdlib.h>
//For  CUDA
#include <cuda.h>
#include <helper_cuda.h>
#include <cuda_runtime.h>


using namespace std;

__global__ void multiplication(int*  a,int* b,int*  c,int n){
    //Calculate row and column
    //int r =blockIdx.y*blockDim.y+threadIdx.y
    int row = (blockDim.y * blockIdx.y) + threadIdx.y;
    int col= (blockDim.x * blockIdx.x) + threadIdx.x;
    int partial=0;

    for(int i=0;i<n;i++){
        partial  += a[row * n +i] * b[i*n+col];
    }

    c[row*n+col]=partial;
}



int main(int argc, char **argv)
{
    printf("Inicio");
    //define variables
    int  n  = 1024;
    //Host matrix
    int* h_a;
    int* h_b;
    int* h_c;
    int* h_c2;

    //Device  matrix
    int* d_a;
    int* d_b;
    int* d_c;

    size_t  bytes = n*n*sizeof(int);

    //Allocate memory in host
    h_a =(int*)malloc(bytes);
    h_b =(int*)malloc(bytes);
    h_c =(int*)malloc(bytes);
    h_c2 =(int*)malloc(bytes);

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
    int threads_block =  16;
    dim3 block_size(threads_block,threads_block);
    dim3 grid_size(n/block_size.x,n/block_size.y);
    printf("Aqui");
      //<<<Bloques,hilos>>>
    multiplication  <<<grid_size,block_size>>> (d_a,d_b,d_c,n);
   
    //Copy  data  device to host
    printf("hola1");
    cudaMemcpy(h_c,d_c,bytes,cudaMemcpyDeviceToHost);
    printf("hola2");
    printf("%d %d\n",h_c[0],h_c2[0]);
    // free memory

    cudaFree(d_a);
    cudaFree(d_b);
    cudaFree(d_c);
    free(h_a);
    free(h_b);
    free(h_c);

    
    
    return 0;

}
