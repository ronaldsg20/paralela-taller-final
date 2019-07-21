#include <stdlib.h>
#include <omp.h>
#include <stdio.h>
#include <string.h>
 #include <math.h>
 // For the CUDA runtime routines (prefixed with "cuda_")
 #include <cuda.h>
 #include <helper_cuda.h>
 #include <cuda_runtime.h>
// Global variables


void readMatrix(char *filename, int M[][1024], int N){
    FILE *fstream = fopen(filename, "r");
    if(fstream == NULL){
        printf("\n file opening failed ");
        return;
    }
    char *record,*line;
    char buffer[1024];
    int i=0,j=0;
    while((line=fgets(buffer,sizeof(buffer),fstream))!=NULL){
        j = 0;
        record = strtok(line,",");
        while(record != NULL){
            M[i][j++] = atoi(record);
            record = strtok(NULL,",");
        }
        ++i;
    }
}

void printMatrix(int M[][1024], int N){
    // print matrix for testing
    int i;
    int j;
    for(i = 0; i < N; i++){
        for(j = 0; j < N; j++){
            printf("%d ",M[i][j]);
        }
        printf("\n");
    }
    printf("\n");
}

void multiplyMatrix(int A[][1024], int B[][1024], int C[][1024], int ini, int fin) 
{ 
    int i, j, k; 
    for (i = ini; i < fin; i++) { 
        for (j = 0; j < 1024; j++) { 
            C[i][j] = 0; 
            for (k = 0; k < 1024; k++) 
                C[i][j] += A[i][k]*B[k][j]; 
        } 
    } 
}

void writeMatrix(char *filename, int R[][1024], int N){
    FILE *fp;
    int i,j;
    fp=fopen(filename,"w+");
    for(i=0 ; i<N; i++){
        for(j=0; j<N; j++){
            fprintf(fp,",%d ",R[i][j]);
        }
        fprintf(fp,"\n%d",i+1);
    }
    fclose(fp);
}

__global__ void multiplyMat(int *N,int *H){
    int tn = (blockDim.x * blockIdx.x) + threadIdx.x;
    
    int ini = (int)((int)*N/(int)*H)*(tn);
    int fin = (int)((int)*N/(int)*H)+ini;

    int i, j, k; 
    if(tn <*N){
        for (i = ini; i < fin; i++) { 
            for (j = 0; j < 1024; j++) { 
                C[i][j] = 0; 
                for (k = 0; k < 1024; k++) 
                    C[i][j] += A[i][k]*B[k][j]; 
            } 
        }
    }
    

}

int main(int argc, char **argv){

    int A[1024][1024];
    int B[1024][1024];
    int C[1024][1024];
    //Handle errors
    cudaError_t error = cudaSuccess;

    // Arguments
    if ( argc !=  5){
        printf("usage: ./matrixMult_gpu MatA.csv MatB.csv N H\n");
        return -1;
    }
    char* fileA = argv[1];
    char* fileB = argv[2];
    int N = atoi(argv[3]);
    int H = atoi(argv[4]);    

    //device variables

    int *d_N;
    int *d_H;
    int d_C[1024][1024];
    int d_A[1024][1024];
    int d_B[1024][1024];

    // Read matrix A and B
    readMatrix(fileA, A, N);
    readMatrix(fileB, B, N);

    // Print matrix A and B
    printMatrix(A, N);
    printMatrix(B, N);
    
    // GPU data
    cudaSetDevice(0);
    cudaDeviceProp deviceProp;
    cudaGetDeviceProperties(&deviceProp,0);

    // malloc and cudaMalloc


    //set initial values

    //Memcpy: Host to device

    //Launch Kernel

    /* #pragma omp parallel num_threads(H)
    {
        int tn = omp_get_thread_num();
        int ini = (int)(N/H)*(tn);
        int fin = (int)(N/H)+ini;
        multiplyMatrix(A, B, C,ini,fin);
    } */ 

    // Memcpy : Device to Host

    //print results
    printMatrix(C, N);

    // Write the matrix
    writeMatrix("../Resultados/result.csv", C, N);
    
    return 0;
}