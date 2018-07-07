#!/bin/bash
set -e
MAINDIR=$( git rev-parse --show-toplevel)
echo $MAINDIR
echo "cleaning main directory"
rm -r -f $MAINDIR/CMakeFiles
rm -f $MAINDIR/CMakeCache.txt

# the directory of the script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
WORK_DIR=$MAINDIR/benchmark 
mkdir -p $WORK_DIR
cd $WORK_DIR


echo "working in " $PWD



cmake -DCMAKE_BUILD_TYPE=release $MAINDIR
make

for factor in 1 2 5 10 15 20 30 40 50 
do
  filename="data"$factor".txt"
  if [ ! -f $filename ]
  then
    echo "generating "$filename
    python $MAINDIR/datagenscripts/shufflecounts.py $factor > $filname
  else
    echo "file "$filename" already exists"
  fi
done

for algorithm in quicksort lcpquicksort_simd_cache8 multikey_cache8 burstsort_bagwell 
do
  echo $algorithm
  resultsfile=$WORK_DIR/$algorithm.txt
  if [ ! -f $resultsfile ]
  then
    echo "creating file "$resultsfile
    for factor in 1 2 5 10 15 20 30 40 50
    do
      timeval=`$WORK_DIR/sortstring --shuffle $algorithm ../benchmark/data$factor.txt | grep  -o -P "[0-9]+\.[0-9]+(?= ms : wall)"`
      echo $factor $timeval >> $resultsfile
      printf "($d,$d)" $factor $timeval
    done
    printf "\n"
    echo
  else
    awk  '{ for(i=NF; i>=2; --i)  printf "(%d,%d)", $1, $2 }' "$resultsfile"
    echo
    echo "result file "$resultsfile" already exist; if you want it recomputed, deleted it"
  fi
done
