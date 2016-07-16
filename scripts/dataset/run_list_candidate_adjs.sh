#!/bin/sh
require_params=3
if [ $# -lt $require_params ]; then
    echo "need at least $require_params argument"
    echo "Usage: $0 path_to_reduced_data top_k #queries"
    echo "e.g. $0 ../../result/prep3/feed/queries4 30 41"
    exit 1
fi

path_to_reduced_data=$1

top_k=$2

query_from=1
query_to=$3 # num of queries

echo "path_to_reduced_data: ${path_to_reduced_data}"
echo "top_k: ${top_k}"
echo "num_of_queries: ${query_to}"
echo "--------------"

output_path="${path_to_reduced_data}/adjs_threshold"
mkdir -p $output_path
for q in `seq $query_from $query_to`
do
    # Usage: ./list_candidate_adjs.rb path_to_reduced_data top#
    # e.g. ./list_candidate_adjs.rb ../../result/prep2/feed/queries4/query1/reduce/output.reduce 30
    data_path="${path_to_reduced_data}/query${q}/reduce/output.reduce"
    ./list_candidate_adjs.rb $data_path $top_k > "${output_path}/query${q}.txt"
done
