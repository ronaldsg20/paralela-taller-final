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

void readMatrix(char *filename, int **M, int N){
    FILE *fstream = fopen(filename, "r");
    if(fstream == NULL){
        printf("\n file opening failed ");
        return;
    } 
    char *record,*line;
    char buffer[2300];
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

void printMatrix(int **M, int N){
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



void writeMatrix(char *filename, int **R, int N){
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

__global__ void multiplyMat(int *A,int *B, int *C,int *H,int *N){
    int tn,ini,fin;
    tn = (blockDim.x * blockIdx.x) + threadIdx.x;

    if(*H<=*N){
        ini = (int)((int)*N/(int)*H)*(tn);
        fin = (int)((int)*N/(int)*H)+ini;
    }else{
        ini = tn;
        fin = tn+1;
    }
    //printf("Thread : %d - ini: %d - fin: %d \n",tn,ini,fin);
    int i, j, k; 
    if(tn <*N){
        for (i = ini; i < fin; i++) { 
            for (j = 0; j < *N; j++) { 
                C[(i * *N) +j] = 0; 
                for (k = 0; k < *N; k++)
                    //if(tn==0) printf("multiplying %d  with  %d \n",A[(i * *N) +k],B[(k * *N) +j]);
                    C[(i * *N) +j] += A[(i * *N) +k]*B[(k * *N) +j]; 
            } 
        }
    }
    

}

int main(int argc, char **argv){

    int **C;
    int **A;
    int **B;
    int *h_A;
    int *h_B;
    int *h_C;
    //Handle errors
    cudaError_t error = cudaSuccess;

    // Arguments
    if ( argc !=  7){
        printf("usage: ./matrixMult_gpu <MatA.csv> <MatB.csv> <N> <THREADSxBLOCK> <BLOCKS> <PATH-TO-MatC.csv> \n");
        return -1;
    }
    char* fileA = argv[1];
    char* fileB = argv[2];
    int N = atoi(argv[3]);
    int H = atoi(argv[4]);    

    //device variables

    int *d_N;
    int *d_H;
    int *d_C;
    int *d_A;
    int *d_B;
  
    // GPU data
    cudaSetDevice(0);
    cudaDeviceProp deviceProp;
    cudaGetDeviceProperties(&deviceProp,0);

    // malloc and cudaMalloc
    A = (int **)malloc(N * sizeof(int*));
    for(int i = 0; i < N; i++) A[i] = (int *)malloc(N * sizeof(int));
    B = (int **)malloc(N * sizeof(int*));
    for(int i = 0; i < N; i++) B[i] = (int *)malloc(N * sizeof(int));
    C = (int **)malloc(N * sizeof(int*));
    for(int i = 0; i < N; i++) C[i] = (int *)malloc(N * sizeof(int));

    h_A = (int *)malloc(N*N*sizeof(int));
    h_B = (int *)malloc(N*N*sizeof(int));
    h_C = (int *)malloc(N*N*sizeof(int));

    error = cudaMalloc(&d_A,N*N*sizeof(int));
     if (error != cudaSuccess){
        fprintf(stderr, "Failed to allocate mem for d_A (error code %s)!\n", cudaGetErrorString(error));
        exit(EXIT_FAILURE);
    }
    error = cudaMalloc(&d_B,N*N*sizeof(int));
     if (error != cudaSuccess){
        fprintf(stderr, "Failed to allocate mem for d_B (error code %s)!\n", cudaGetErrorString(error));
        exit(EXIT_FAILURE);
    }
    error = cudaMalloc(&d_C,N*N*sizeof(int));
     if (error != cudaSuccess){
        fprintf(stderr, "Failed to allocate mem for d_C (error code %s)!\n", cudaGetErrorString(error));
        exit(EXIT_FAILURE);
    }
    error = cudaMalloc(&d_N,sizeof(int));
     if (error != cudaSuccess){
        fprintf(stderr, "Failed to allocate mem for d_N (error code %s)!\n", cudaGetErrorString(error));
        exit(EXIT_FAILURE);
    }
    error = cudaMalloc(&d_H,sizeof(int));
     if (error != cudaSuccess){
        fprintf(stderr, "Failed to allocate mem for d_H (error code %s)!\n", cudaGetErrorString(error));
        exit(EXIT_FAILURE);
    }
    /**************set initial values****************/

    // Read matrix A and B
    readMatrix(fileA, A, N);
    readMatrix(fileB, B, N);

    // write A and B on array
    for(int i=0;i<N;i++){
        for(int j=0;j<N;j++){
            h_A[(i*N)+j]=A[i][j];
            h_B[(i*N)+j]=B[i][j];
        }
    }

    // Print matrix A and B
    //printMatrix(A, N);
    //printMatrix(B, N);
  
    //Memcpy: Host to device

    error = cudaMemcpy(d_A, h_A, N*N*sizeof(int), cudaMemcpyHostToDevice);
    if (error != cudaSuccess){
        fprintf(stderr, "Failed to  to copy on device(error code %s)!\n", cudaGetErrorString(error));
        exit(EXIT_FAILURE);
    }
    error = cudaMemcpy(d_B, h_B, N*N*sizeof(int), cudaMemcpyHostToDevice);
    if (error != cudaSuccess){
        fprintf(stderr, "Failed to  to copy on device(error code %s)!\n", cudaGetErrorString(error));
        exit(EXIT_FAILURE);
    }
    error = cudaMemcpy(d_C, h_C, N*N*sizeof(int), cudaMemcpyHostToDevice);
    if (error != cudaSuccess){
        fprintf(stderr, "Failed to  to copy on device(error code %s)!\n", cudaGetErrorString(error));
        exit(EXIT_FAILURE);
    }
    error = cudaMemcpy(d_H, &H, sizeof(int), cudaMemcpyHostToDevice);
    if (error != cudaSuccess){
        fprintf(stderr, "Failed to  to copy on device(error code %s)!\n", cudaGetErrorString(error));
        exit(EXIT_FAILURE);
    }
    error = cudaMemcpy(d_N, &N, sizeof(int), cudaMemcpyHostToDevice);
    if (error != cudaSuccess){
        fprintf(stderr, "Failed to  to copy on device(error code %s)!\n", cudaGetErrorString(error));
        exit(EXIT_FAILURE);
    }

    //Blocks and threads definition
    int blocks = atoi(argv[5]);

    //Launch Kernel

    multiplyMat<<<blocks,H>>>(d_A,d_B, d_C, d_H, d_N);

    error = cudaGetLastError();
    if (error != cudaSuccess){
        fprintf(stderr, "Failed to launch multiplyMatrix (error code %s)!\n", cudaGetErrorString(error));
        exit(EXIT_FAILURE);
    }


    // Memcpy : Device to Host


    error = cudaMemcpy(h_C, d_C, N*N*sizeof(int), cudaMemcpyDeviceToHost);
     if (error != cudaSuccess){
        fprintf(stderr, "Failed to  to copy from device (error code %s)!\n", cudaGetErrorString(error));
        exit(EXIT_FAILURE);
    }
    for(int i=0;i<N;i++){
        for(int j=0;j<N;j++){
            C[i][j]=h_C[(i*N)+j];
        }
    }

    //print results
    //printMatrix(C, N);

    // Write the matrix
    writeMatrix(argv[6], C, N);
    
    // free memory
    
    cudaFree(d_N);
    cudaFree(d_H);
    cudaFree(d_C);
    cudaFree(d_A);
    cudaFree(d_B);

    free(h_A);
    free(h_B);
    free(h_C);

    return 0;
}
