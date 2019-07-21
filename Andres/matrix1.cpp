//BLOCKWISE
#include <iostream>
#include "omp.h"


using namespace std;
//global variables
int  SIZE,THREADS;

int ** randomMatrix () {
	int **result = new int *[SIZE] ;

	for (int i = 0; i < SIZE; i++) {
		result[i] = new int [SIZE] ;

		for (int j = 0; j < SIZE; j++)
			result[i][j] = rand()%6;
	}

	return result;
}

void Multiply(int ** a, int ** b, int ** c, int ID) {
    
    int ini = (int)(SIZE/omp_get_num_threads())*ID;
	int fin = (int)(SIZE/omp_get_num_threads())+ini;
	for (int i = ini ; i < fin ;i++ ) {
		for (int j = 0 ; j < SIZE ; j++) {
			for (int k = 0; k < SIZE; k++) {
				c[i][j] += a[i][k] * b[k][j];
			}
		}
	}
}



int main(int argc, char **argv)
{
     // read arguments
    if ( argc != 3 )
    {
        printf("usage: ./matrix  <SIZE> <THREADS>\n");
        return -1;
    }
    
    SIZE =atoi(argv[1]);
    THREADS = atoi(argv[2]);

   
    int **a=new int*[SIZE];
    int **b=new int*[SIZE];
    int **c=new int*[SIZE];

    a=randomMatrix();
    b=randomMatrix();

    for (int i = 0; i < SIZE; i++) {
		c[i] = new int [SIZE] ;

		for (int j = 0; j < SIZE; j++){
            c[i][j] = 0;
        }
			
	}

   #pragma omp parallel num_threads(THREADS)
	{
		int ID = omp_get_thread_num();
		Multiply(a, b, c, ID);
	}
   // Displaying the multiplication of two matrix.
   cout << endl << "Output Matrix: " << endl;
    for(int i = 0; i <SIZE; ++i)
    for(int j = 0; j < SIZE; ++j)
    {
        cout << " " << a[i][j];
        if(j == SIZE-1)
            cout << endl;
    }

    cout<<endl;
    for(int i = 0; i <SIZE; ++i)
    for(int j = 0; j < SIZE; ++j)
    {
        cout << " " << b[i][j];
        if(j == SIZE-1)
            cout << endl;
    }
    cout<<endl;
    for(int i = 0; i <SIZE; ++i)
    for(int j = 0; j < SIZE; ++j)
    {
        cout << " " << c[i][j];
        if(j == SIZE-1)
            cout << endl;
    }
    cout<<endl; 
  
    
    
    return 0;

}
