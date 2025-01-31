#include <stdlib.h>
#include <omp.h>
#include <stdio.h>
#include <string.h>

// Global variables
int **A;
int **B;
int **C;

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

void multiplyMatrix(int **A, int **B, int **C, int ini, int fin,int N) 
{ 
    int i, j, k,a,b; 
    for (i = ini; i < fin; i++) { 
        for (j = 0; j < N; j++) { 
            C[i][j] = 0; 
            for (k = 0; k < N; k++){
                a=A[i][k];
                b=B[k][j];
                C[i][j] += a*b;
            }  
        } 
    } 
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

int main(int argc, char **argv){
    // Arguments
    if ( argc !=  6){
        printf("usage: ./matrixMult MatA.csv MatB.csv N H  <PATH-TO-MatC.csv>\n");
        return -1;
    }
    char* fileA = argv[1];
    char* fileB = argv[2];
    int N = atoi(argv[3]);
    int H = atoi(argv[4]);    

    A = (int **)malloc(N * sizeof(int*));
    for(int i = 0; i < N; i++) A[i] = (int *)malloc(N * sizeof(int));
    B = (int **)malloc(N * sizeof(int*));
    for(int i = 0; i < N; i++) B[i] = (int *)malloc(N * sizeof(int));
    C = (int **)malloc(N * sizeof(int*));
    for(int i = 0; i < N; i++) C[i] = (int *)malloc(N * sizeof(int));
    // Read matrix A and B
    readMatrix(fileA, A, N);
    readMatrix(fileB, B, N);

    // Print matrix A and B
    printMatrix(A, N);
    printMatrix(B, N);
    
    // Obtain and print matrix C
    #pragma omp parallel num_threads(H)
    {
        int tn = omp_get_thread_num();
        int ini = (int)(N/H)*(tn);
        int fin = (int)(N/H)+ini;
        multiplyMatrix(A, B, C,ini,fin,N);
    }
    //multiplyMatrix(A, B, C);      
    //printMatrix(C, N);

    // Write the matrix
    writeMatrix(argv[5], C, N);

   
    return 0;
}