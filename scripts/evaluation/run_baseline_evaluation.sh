#!/bin/sh

require_params=4
if [ $# -lt $require_params ]; then
    echo "need at least $require_params argument"
    echo "Usage: $0 path_to_raw_value_files #ranks target_column path_to_gold [epsilon (default: 0)]"
    echo "e.g. $0 ../../result/gather/ver6 8 2 ./gold/gold0.csv [0]"
    exit 1
fi

path_to_raw_value_files=$1
num_of_ranks=$2
target_column=$3
path_to_gold=$4
baseline_output_prefix="${path_to_raw_value_files}/baseline_row${target_column}"
baseline_output="${baseline_output_prefix}/baseline.csv"
baseline_rhos_output="${baseline_output_prefix}/baseline_rhos.txt"
mkdir -p $baseline_output_prefix

epsilon=0
if [ $# -gt 4 ]; then
    epsilon=$5
fi

echo "path_to_raw_value_files: $path_to_raw_value_files"
echo "target_column: $target_column"
echo "num_of_ranks: $num_of_ranks"
echo "path_to_gold: $path_to_gold"
echo "epsilon: $epsilon"
echo "baseline output -> $baseline_output"
echo "baseline's rhos output -> $baseline_rhos_output"

> $baseline_output
echo "############### ./baseline/sort.rb ###############"
for i in `seq 1 $num_of_ranks`
do
    # Usage: ./sort.rb path_to_file target_column epsilon
    # e.g. ./sort.rb ../../result/gather/ver6/result1.txt 2 0.01
    ./baseline/sort.rb ${path_to_raw_value_files}/result${i}.txt \
        $target_column $epsilon >> $baseline_output
done
echo "############### !./baseline/sort.rb ###############"

# Usage: ./calc_spearman.rb ranking1 ranking2 [show_annotate (any value is ok)]
# e.g. ./calc_spearman.rb ./gold/gold0.csv ../../result/gather/ver1/svm_result.txt
final_result="`./util/calc_spearman.rb $path_to_gold $baseline_output`"
echo "$final_result" > $baseline_rhos_output
echo "$final_result"

echo "-------------- params (show again) -----------------"
echo "path_to_raw_value_files: $path_to_raw_value_files"
echo "target_column: $target_column"
echo "num_of_ranks: $num_of_ranks"
echo "path_to_gold: $path_to_gold"
echo "epsilon: $epsilon"
echo "baseline output -> $baseline_output"
echo "baseline's rhos output -> $baseline_rhos_output"
