#!/usr/bin/env ruby
require 'open3'
require 'fileutils'
require_relative '../util/print'
require "parallel"

require_params = 3
if ARGV.length < require_params
    puts "This script needs at least #{require_params} parameters"
    puts "Usage: #{__FILE__} gold_num data_path #data [ablation columns (default: 0 = do not)]"
    puts "e.g. #{__FILE__} 0 ../../result/gather/ver6 8 [\"1&2\"]"
    exit 1
end

c_params = \
[\
0.000001, 0.000002, 0.000005, \
0.00001, 0.00002, 0.00005, \
0.0001, 0.0002, 0.0005, \
0.001, 0.002, 0.005, \
0.01, 0.02, 0.05, \
0.1, 0.2, 0.5, \
1.0, 2.0, 5.0, \
10.0, 20.0, 50.0, \
100.0, 200.0, 500.0, \
1000.0, 2000.0, 5000.0, \
10000.0]

OUT_LENGTH = 80
TEST_PATH_SUFFIX = "test_data"
TUNE_PATH_SUFFIX = "tune_data"

gold_num = ARGV[0].to_i
data_path = ARGV[1]
num_of_data = ARGV[2].to_i
ablation = ARGV.length < require_params + 1 ? "0" : ARGV[3]
output_path = "#{data_path}/svr"
tune_data_path = "#{output_path}/#{TUNE_PATH_SUFFIX}"
test_data_path = "#{output_path}/#{TEST_PATH_SUFFIX}"
svr_path = "../../../tools/svr/liblinear" # assume this folder exists
gold_path = "../gold/gold#{gold_num}.csv"

puts "gold num: #{gold_num} (#{gold_path})"
puts "data path: #{data_path}"
puts "num of data: #{num_of_data}"
puts "ablation: #{ablation}"
puts "test data path: #{test_data_path}"
puts "tune data path: #{tune_data_path}"
puts "svr path (check its existence): #{svr_path}"

puts_line("running ", OUT_LENGTH)

gold_standard = []
File.open(gold_path) do |f|
    f.readlines.each_slice(2) do |adj, ranking|
        # # 大きい
        # クジラ,1,キリン,2,ゾウ,3,クマ,4,ウシ,5,ウマ,6,イヌ,7,サル,8,ネコ,9,ネズミ,10
        # # 安い
        # ...
        gold_standard << "#{adj}#{ranking}"
    end
end

Parallel.each(0...num_of_data, in_processes: 40) do |i|
    puts "tuning for test#{i}"

    test_data = "#{test_data_path}/test#{i}.txt"
    # tune_train_data_path = "#{tune_data_path}/tune#{i}/train_data"
    # tune_test_data_path = "#{tune_data_path}/tune#{i}/test_data"

    max_rho = -1.0
    max_c = 0
    c_params.each do |c_value|
        epsilon = "0.0000001"
        type = 11
        tune_data_sub_path = "#{tune_data_path}/tune#{i}"


        puts_line("run a cross validation", OUT_LENGTH, STDERR)
        STDERR.puts "c_value: #{c_value}"
        STDERR.puts "tune_data_sub_path: #{tune_data_sub_path}"
        STDERR.puts "training on #{tune_data_sub_path} for test: #{test_data}"


        # "Usage: $0 train_test_output_path svr_path [c_value (default: 0.01)]
        #                       [type (default: 11)] [ablation (default: 0 = do not)]"
        # "e.g. $0 ../../result/gather/ver1/svr ../../tools/svr/liblinear [0.01] [11] [0]"
        STDERR.puts "./run_svr_validation.sh #{tune_data_sub_path} #{svr_path} #{c_value} #{type} \"#{ablation}\""
        puts_line("svr_validation", OUT_LENGTH, STDERR)
        `./run_svr_validation.sh #{tune_data_sub_path} #{svr_path} #{c_value} #{type} \"#{ablation}\"`


        # "Usage: #{__FILE__} path_to_prediction_and_test output_path epsilon"
        # "e.g. #{__FILE__} ../../result/gather/ver1 ../../result/gather/ver1/svr_result.txt 0.01"
        svr_rank_output = "#{tune_data_sub_path}/eval/svr_result_ep#{epsilon}_c#{c_value}_t#{type}.csv"
        FileUtils.mkdir_p(File.dirname(svr_rank_output))
        STDERR.puts "./concat_svr_results.rb #{tune_data_sub_path} #{svr_rank_output} #{epsilon}"
        puts_line("concate_svr_results", OUT_LENGTH, STDERR)
        `./concat_svr_results.rb #{tune_data_sub_path} #{svr_rank_output} #{epsilon}`


        # create test gold (N - 1) results
        test_gold = gold_standard - [gold_standard[i]]
        test_gold_data = "../tmp/test#{i}/test_gold.csv"
        FileUtils.mkdir_p(File.dirname(test_gold_data))
        # write test gold
        File.write(test_gold_data, test_gold.join())


        STDERR.puts "./calc_spearman.rb #{svr_rank_output} #{test_gold_data}"
        puts_line("calc_spearman", OUT_LENGTH, STDERR)
        out_spearman = `../util/calc_spearman.rb #{svr_rank_output} #{test_gold_data}`
        # puts out_spearman
        rho = out_spearman.split("\n").last.to_f
        if rho > max_rho
            max_rho = rho
            max_c = c_value
        end
        puts "checked (i, c, rho) = (#{i}, #{c_value}, #{rho})"
    end
    puts "best (i, c, rho) = (#{i}, #{max_c}, #{max_rho})"
end
