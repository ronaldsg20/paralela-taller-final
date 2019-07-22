
echo "" > resultados.txt

for N in 8 16 32 64 128 512 1024;
do
    echo "|=========================|" >> resultados.txt
    echo "|-------Matriz $N X $N-----|" >> resultados.txt
    echo "|=========================|" >> resultados.txt

    for block in 2 3 4 5 6 7 8 9 10 11 12 13 14;
    do
        for hilo in 10 20 40 80 100 200 400 600 800 1000;
        do
            echo "-------Blocks: $block -- Hilos :$hilo  -----" >> resultados.txt
        { time ./matrixMult_gpu ../Matrices/${N}A.csv ../Matrices/${N}B.csv $N $hilo $block ../Resultados/${N}C-${hilo}-${block}.csv >/dev/null 2>&1;} |&  tee -a resultados.txt
        done
    done
done

