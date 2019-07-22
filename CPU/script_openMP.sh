
echo "" > resultados.txt

for N in 8 16 32 64 128 512 1024;
do
    echo "|=========================|" >> resultados.txt
    echo "|-------Matriz $N X $N-----|" >> resultados.txt
    echo "|=========================|" >> resultados.txt

        for hilo in 1 2 3 4 5 6 7 8 9 10 11 12;
        do
        echo "----------- Hilos :$hilo  -----" >> resultados.txt
        { time ./matrixMult_cpu ../Matrices/${N}A.csv ../Matrices/${N}B.csv $N $hilo ../ResultadosO/${N}C-${hilo}.csv >/dev/null 2>&1;} |&  tee -a resultados.txt
        
    done
done

