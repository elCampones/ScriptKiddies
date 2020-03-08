#!/bin/bash
PARALLEL_CLASS_PATH=.
SERIAL_CLASS_PATH=.

TIMES=(1000 10000 100000 100000 1000000 10000000 100000000)

usage (){
	echo "Usage: $0 [-options] output_file serial_estimator parallel_estimator num_iterations"
	echo "where options include:" 
	echo "		-s	<classpath>	set the classpath for the serial estimator"
	echo "		-p	<classpath>	set the classpath for the parallel estimator"
	echo
}

while getopts "s:p:" opt; do
	case "${opt}" in
		s) 
			SERIAL_CLASS_PATH=${OPTARG};;
		p) 
			PARALLEL_CLASS_PATH=${OPTARG};;
    	:)
      		echo "Option -$OPTARG requires an argument." >&2
			usage
      		exit 1
      		;;
		?)
      		echo "Invalid option: -$OPTARG" >&2
			usage
      		exit 1
      		;;
	esac
done
shift $((OPTIND-1))

if (($# < 4))
then
	usage
fi


output_file=$1
serial_estimator=$2
parallel_estimator=$3
num_iterations=$4

printf "Serial " >> $output_file
for (( i=1; i<${#TIMES[@]}; i++ ))
do
	printf " " >> $output_file
done

printf "Parallel" >> $output_file
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
		iteration_time=$({ time java -classpath $SERIAL_CLASS_PATH $serial_estimator $t 1>/dev/null 2>err.log;} 2>&1 | grep real | tail -c 7 | head -c 5)
		printf "$iteration_time " >> $output_file
	done

	for t in ${TIMES[@]}
	do
		iteration_time=$({ time java -classpath $PARALLEL_CLASS_PATH $parallel_estimator $t 1>/dev/null 2>err.log;} 2>&1 | grep real | tail -c 7 | head -c 5)
		printf "$iteration_time " >> $output_file
	done

	printf "\n" >> $output_file 
	echo "finnished $i th iteration"
done

printf "\n" >> $output_file
