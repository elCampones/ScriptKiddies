#!/bin/bash

#change this if you need
ARGS1=(1000 10000 100000 100000 1000000 10000000 100000000) #java arg1, times in my program
ARGS2=(1 2 4 8) #java arg2, threads in my program

#default values
PARALLEL_CLASSPATH=.
SERIAL_CLASSPATH=.
OUTPUT_FILE=results.csv
OUTPUT_SEPARATOR=","
ITERATIONS=1

usage(){
	echo "Usage: $0 [-options] serial_estimator parallel_estimator"
	echo "where options include:" 
	echo "		-s  <classpath>			set the classpath for the serial estimator"
	echo "		-p <classpath>			set the classpath for the parallel estimator"
	echo "		-f <file>			set the output file (results.csv by default)"
	echo "		-o <separator>			set the separator in the output file (, by default)"
	echo "		-i <number of iterations>	set a number of iterations (1 by default)" 
	echo "		-h				display this message" 
	echo
}

while getopts "s:p:i:o:f:h" opt; do
	case "${opt}" in
		p) 
			PARALLEL_CLASSPATH=${OPTARG};;
		s) 
			SERIAL_CLASSPATH=${OPTARG};;
		f)
			OUTPUT_FILE=${OPTARG};;
		o)
			OUTPUT_SEPARATOR=${OPTARG};;
		i)
			ITERATIONS=${OPTARG};;
		h) 
			usage;;
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

if (($# < 2)); then usage; fi
SERIAL_PROGRAM=$1
PARALLEL_PROGRAM=$2

#aux functions
write_array(){
    local -n arr=$1
    for val in "${arr[@]}"; do
        write_cell "$val"
    done
    write_eol
}

write_cell(){
    printf "%s%s" "$1" "$OUTPUT_SEPARATOR" >> $OUTPUT_FILE
}

write_eol(){
    printf "\n">> $OUTPUT_FILE
}

#main loop
for ((i = 1; i <= ITERATIONS; i++)); do
	echo "Iteration $i/$ITERATIONS, running:"

    echo "	$SERIAL_PROGRAM (Serial)"

    printf "Serial %s\n" $i >> $OUTPUT_FILE #table title
	write_array ARGS1 #times
	for arg1 in "${ARGS1[@]}"; do
		t=$({ time java -classpath "$SERIAL_CLASSPATH" "$SERIAL_PROGRAM" "$arg1" 1>/dev/null 2>java.log;} 2>&1 | grep real | tail -c 7 | head -c 5)
		write_cell "$t" #curr result
	done
    write_eol

	write_eol #offset between serial and parallel tables

    printf "Parallel %s\n%s" $i "$OUTPUT_SEPARATOR" >> "$OUTPUT_FILE" #table title
    write_array ARGS1 #times
    for arg2 in "${ARGS2[@]}"; do
		
		echo "	$PARALLEL_PROGRAM (Parallel) with $arg2 threads" 

		write_cell "$arg2" #number of threads 
        for arg1 in "${ARGS1[@]}"; do
		    t=$({ time java -classpath "$PARALLEL_CLASSPATH" "$PARALLEL_PROGRAM" "$arg1" "$arg2" 1>/dev/null 2>java.log;} 2>&1 | grep real | tail -c 7 | head -c 5)
		    write_cell "$t" #curr result
        done
        write_eol
	done
    write_eol
done
write_eol

echo "Done, output(time): $OUTPUT_FILE, log(java): java.log"


