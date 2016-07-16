#!/bin/sh
set -eu

require_params=5
if [ $# -lt $require_params ]; then
    echo "need at least $require_params argument"
    echo "Usage: $0 gold_num eval_data_path num_of_queries svm_path make_valid_data(true:1,false:other) [c_value (default: 0.01)] [ablation column id (default: 0 = do not)] [kernel (default: 0)] [epsilon (default: 0)]"
    echo "e.g. $0 5 ../../result/gather/ver11/feed/queries8/ 35 ../../tools/linear_svm/liblinear-ranksvm-2.1 1 0.01"
    exit 1
fi

gold_num=$1
eval_data_path=$2
num_of_queries=$3
svm_path=$4
make_valid_data=$5

c_value="0.01"
ablation="0"
kernel="0"
epsilon="0"
if [ $# -gt 5 ]; then
    c_value=$6
fi
if [ $# -gt 6 ]; then
    ablation=$7
fi
if [ $# -gt 7 ]; then
    kernel=$8
fi
if [ $# -gt 8 ]; then
    epsilon=$9
fi


gold_txt="./gold/gold${gold_num}.txt"
gold_csv="./gold/gold${gold_num}.csv"
output_path_prefix=""
if [ $ablation = "0" ]; then
    output_path_prefix="${eval_data_path}/svm"
else
    output_path_prefix="${eval_data_path}/svm_wo${ablation}"
fi
svm_rank_output="${output_path_prefix}/svm_result_ep${epsilon}_c${c_value}_k${kernel}.txt"
rhos_output="${output_path_prefix}/rhos_ep${epsilon}_c${c_value}_k${kernel}.txt"
avg_output="${output_path_prefix}/rho_averages.csv"
mkdir -p $output_path_prefix

echo "gold_num: $gold_num"
echo "eval_data_path: $eval_data_path"
echo "num_of_queries: $num_of_queries"
echo "make_valid_data: $make_valid_data"
echo "svm_path: $svm_path"
echo "epsilon: $epsilon"
echo "c value: $c_value"
echo "ablation: $ablation"
echo "kernel: $kernel"

echo "gold_txt: $gold_txt"
echo "gold_csv: $gold_csv"
echo "svm result -> $svm_rank_output"
echo "spearman's rho result -> $rhos_output"
echo "append average -> $avg_output"

echo "-----------------------------------------------------"

echo "this script runs evaluation in the following order:"
echo "do this yourself -> ./create_gold_standard.rb"
echo "./create_svm_validation_data.rb"
echo "./run_svm_validation.sh"
echo "./concat_svm_results.rb"
echo "./calc_spearman.rb"


# Usage: ./create_svm_validation_data.rb path_to_gold path_to_output #data
# e.g. ./create_svm_validation_data.rb ./gold/gold0.txt ../../result/gather/ver1 8
echo "############### ./svm/create_svm_validation_data.rb ###############"
# echo "./svm/create_svm_validation_data.rb $gold_txt $eval_data_path $num_of_queries"
# this script outputs its result into $eval_data_path/svm
if [ $make_valid_data = "1" ]; then
    ./svm/create_svm_validation_data.rb $gold_txt $eval_data_path $num_of_queries
else
    echo "make_valid_data = 0. skip this"
fi
echo "############### !./svm/create_svm_validation_data.rb ###############"

# Usage: ./run_svm_validation.sh train_test_output_path svm_path
# e.g. ./run_svm_validation.sh ../../result/gather/ver1/svm ../../tools/svm_rank/src [c_value (default: 0.01)] [kernel (default: 0)]
echo "###############     ./svm/run_svm_validation.sh     ###############"
# echo "./run_svm_validation.sh $eval_data_path $svm_path $c_value $kernel"
# the first script outputs its result into $eval_data_path/svm, so add suffix (svm)
./svm/run_svm_validation.sh $eval_data_path/svm $svm_path $c_value $kernel $ablation
echo "###############     !./svm/run_svm_validation.sh     ###############"

# Usage: ./concat_svm_results.rb path_to_prediction_and_test output_path epsilon
# e.g. ./concat_svm_results.rb ../../result/gather/ver1/svm ../../result/gather/ver1/svm/svm_result.txt 0.01
echo "###############     ./svm/concat_svm_results.rb     ###############"
# echo "./concat_svm_results.rb $eval_data_path $svm_rank_output $epsilon"
# the first script outputs its result into $eval_data_path/svm, so add suffix (svm)
./svm/concat_svm_results.rb $eval_data_path/svm $svm_rank_output $epsilon
echo "###############     !./svm/concat_svm_results.rb     ###############"

# Usage: ./calc_spearman.rb ranking1 ranking2 [show_annotate (any value is ok)]
# e.g. ./calc_spearman.rb ./gold/gold0.csv ../../result/gather/ver1/svm_result.txt
echo "###############        ./util/calc_spearman.rb       ###############"
# echo "./calc_spearman.rb $gold_csv $svm_rank_output"
final_result="`./util/calc_spearman.rb $gold_csv $svm_rank_output`"
echo "$final_result" > $rhos_output
echo "$final_result"
avg=`echo "$final_result" | grep "average" -A 1 | tail -n 1`
echo "###############        !./util/calc_spearman.rb       ###############"

echo "------------------ params (show again) -----------------------"
echo "gold_num: $gold_num"
echo "eval_data_path: $eval_data_path"
echo "num_of_queries: $num_of_queries"
echo "svm_path: $svm_path"
echo "epsilon: $epsilon"
echo "c value: $c_value"
echo "ablation: $ablation"
echo "kernel: $kernel"

echo "gold_txt: $gold_txt"
echo "gold_csv: $gold_csv"
echo "svm result -> $svm_rank_output"
echo "spearman's rho result -> $rhos_output"
echo "append average -> $avg_output"

echo "epsilon: $epsilon"
echo "c value: $c_value"
echo "kernel: $kernel"

if [ -f "$avg_output" ]
then
    echo "$avg_output is found. append average."
else
    echo "$avg_output is not found. add first column."
    echo "epsilon, c, kernel, avg" >> $avg_output
fi

if grep "^${epsilon}, ${c_value}, ${kernel}, ${avg}" "$avg_output" > /dev/null; then
    # pattern found
    echo "'${epsilon}, ${c_value}, ${kernel}, ${avg}' exists in ${avg_output}"
else
    # pattern not found
    echo "append '${epsilon}, ${c_value}, ${kernel}, ${avg}'"
    echo "${epsilon}, ${c_value}, ${kernel}, ${avg}" >> $avg_output
fi
