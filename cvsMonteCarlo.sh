#!/bin/bash

TIMES=(1000 10000 100000 100000 1000000 10000000 100000000)

if (($# < 4))
then
	echo $0 output_file serial_estimator paralel_estimator num_iterations
	exit 1
fi

output_file=$1
serial_estimator=$2
paralel_estimator=$3
num_iterations=$4

printf "Serial " >> $output_file
for (( i=1; i<${#TIMES[@]}; i++ ))
do
	printf " " >> $output_file
done

printf "Paralel" >> $output_file
printf "\n" >> $output_file

for i in ${TIMES[@]}
do
	printf "$i " >> $output_file
done
for i in ${TIMES[@]}
do
	printf "$i " >> $output_file
done

printf "\n" >> $output_file

for ((i = 1; i <= $num_iterations; i++))
do
	for t in ${TIMES[@]}
	do
		iteration_time=$({ time java $serial_estimator $t >/dev/null;} 2>&1 | grep real | tail -c 7 | head -c 5)
		printf "$iteration_time " >> $output_file
	done

	for t in ${TIMES[@]}
	do
		iteration_time=$({ time java $paralel_estimator $t >/dev/null;} 2>&1 | grep real | tail -c 7 | head -c 5)
		printf "$iteration_time " >> $output_file
	done

	printf "\n" >> $output_file 
	echo "finnished $i th iteration"
done

printf "\n" >> $output_file
