#!/bin/sh
set -eu

require_params=5
if [ $# -lt $require_params ]; then
    echo "need at least $require_params argument"
    echo "Usage: $0 gold_num eval_data_path num_of_queries svr_path make_valid_data(true:1,false:other) [c_value (default: 0.01)] [ablation column id (default: 0 = do not)] [type (default: 11)] [epsilon (default: 0)]"
    echo "e.g. $0 0 ../../result/gather/ver6 8 ../../tools/svr/liblinear 0 [0.01]"
    exit 1
fi

gold_num=$1
eval_data_path=$2
num_of_queries=$3
svr_path=$4
make_valid_data=$5

c_value="0.01"
ablation="0"
type="11"
epsilon="0"
if [ $# -gt 5 ]; then
    c_value=$6
fi
if [ $# -gt 6 ]; then
    ablation=$7
fi
if [ $# -gt 7 ]; then
    type=$8
fi
if [ $# -gt 8 ]; then
    epsilon=$9
fi


gold_txt="./gold/gold${gold_num}.txt"
gold_csv="./gold/gold${gold_num}.csv"
output_path_prefix=""
if [ $ablation = "0" ]; then
    output_path_prefix="${eval_data_path}/svr"
else
    output_path_prefix="${eval_data_path}/svr_wo${ablation}"
fi
svr_rank_output="${output_path_prefix}/svr_result_ep${epsilon}_c${c_value}_t${type}.txt"
rhos_output="${output_path_prefix}/rhos_ep${epsilon}_c${c_value}_t${type}.txt"
avg_output="${output_path_prefix}/rho_averages.csv"
mkdir -p $output_path_prefix

echo "gold_num: $gold_num"
echo "eval_data_path: $eval_data_path"
echo "num_of_queries: $num_of_queries"
echo "make_valid_data: $make_valid_data"
echo "svr_path: $svr_path"
echo "epsilon: $epsilon"
echo "c value: $c_value"
echo "ablation: $ablation"
echo "type: $type"

echo "gold_txt: $gold_txt"
echo "gold_csv: $gold_csv"
echo "svr result -> $svr_rank_output"
echo "spearman's rho result -> $rhos_output"
echo "append average -> $avg_output"

echo "-----------------------------------------------------"

echo "this script runs evaluation in the following order:"
echo "do this yourself -> ./create_gold_standard.rb"
echo "./create_svr_validation_data.rb"
echo "./run_svr_validation.sh"
echo "./concat_svr_results.rb"
echo "./calc_spearman.rb"


# Usage: ./create_svr_validation_data.rb path_to_gold path_to_output #data
# e.g. ./create_svr_validation_data.rb ./gold/gold0.txt ../../result/gather/ver1 8
echo "############### ./svr/create_svr_validation_data.rb ###############"
# echo "./svr/create_svr_validation_data.rb $gold_txt $eval_data_path $num_of_queries"
# this script outputs its result into $eval_data_path/svr
if [ $make_valid_data = "1" ]; then
    ./svr/create_svr_validation_data.rb $gold_txt $eval_data_path $num_of_queries
else
    echo "make_valid_data = 0. skip this"
fi
echo "############### !./svr/create_svr_validation_data.rb ###############"

# Usage: ./run_svr_validation.sh train_test_output_path svr_path
# e.g. ./run_svr_validation.sh ../../result/gather/ver1/svr ../../tools/svr/liblinear [c_value (default: 0.01)] [type (default: 0)]
echo "###############     ./svr/run_svr_validation.sh     ###############"
# echo "./run_svr_validation.sh $eval_data_path $svr_path $c_value $type"
# the first script outputs its result into $eval_data_path/svr, so add suffix (svr)
./svr/run_svr_validation.sh $eval_data_path/svr $svr_path $c_value $type $ablation
echo "###############     !./svr/run_svr_validation.sh     ###############"

# Usage: ./concat_svr_results.rb path_to_prediction_and_test output_path epsilon
# e.g. ./concat_svr_results.rb ../../result/gather/ver1/svr ../../result/gather/ver1/svr/svr_result.txt 0.01
echo "###############     ./svr/concat_svr_results.rb     ###############"
# echo "./concat_svr_results.rb $eval_data_path $svr_rank_output $epsilon"
# the first script outputs its result into $eval_data_path/svr, so add suffix (svr)
./svr/concat_svr_results.rb $eval_data_path/svr $svr_rank_output $epsilon
echo "###############     !./svr/concat_svr_results.rb     ###############"

# Usage: ./calc_spearman.rb ranking1 ranking2 [show_annotate (any value is ok)]
# e.g. ./calc_spearman.rb ./gold/gold0.csv ../../result/gather/ver1/svr_result.txt
echo "###############        ./util/calc_spearman.rb       ###############"
# echo "./calc_spearman.rb $gold_csv $svr_rank_output"
final_result="`./util/calc_spearman.rb $gold_csv $svr_rank_output`"
echo "$final_result" > $rhos_output
echo "$final_result"
avg=`echo "$final_result" | grep "average" -A 1 | tail -n 1`
echo "###############        !./util/calc_spearman.rb       ###############"

echo "------------------ params (show again) -----------------------"
echo "gold_num: $gold_num"
echo "eval_data_path: $eval_data_path"
echo "num_of_queries: $num_of_queries"
echo "svr_path: $svr_path"
echo "epsilon: $epsilon"
echo "c value: $c_value"
echo "ablation: $ablation"
echo "type: $type"

echo "gold_txt: $gold_txt"
echo "gold_csv: $gold_csv"
echo "svr result -> $svr_rank_output"
echo "spearman's rho result -> $rhos_output"
echo "append average -> $avg_output"

if [ -f "$avg_output" ]
then
    echo "$avg_output is found. append average."
else
    echo "$avg_output is not found. add first column."
    echo "epsilon, c, type, avg" >> $avg_output
fi

if grep "^${epsilon}, ${c_value}, ${type}, ${avg}" "$avg_output" > /dev/null; then
    # pattern found
    echo "'${epsilon}, ${c_value}, ${type}, ${avg}' exists in ${avg_output}"
else
    # pattern not found
    echo "append '${epsilon}, ${c_value}, ${type}, ${avg}'"
    echo "${epsilon}, ${c_value}, ${type}, ${avg}" >> $avg_output
fi
