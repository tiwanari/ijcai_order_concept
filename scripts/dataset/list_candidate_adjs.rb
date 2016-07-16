#!/usr/bin/env ruby

require_params = 2
if ARGV.length < require_params
    STDERR.puts "This script needs at least #{require_params} parameters"
    STDERR.puts "Usage: #{__FILE__} path_to_reduced_data top#"
    STDERR.puts "e.g. #{__FILE__} ../../result/prep3/feed/queries4/query1/reduce/output.reduce 30"
    exit 1
end

path_to_reduced_data = ARGV[0]
num_of_adjs = ARGV[1].to_i

STDERR.puts "path_to_reduced_data: #{path_to_reduced_data}"
STDERR.puts "num_of_adjs: #{num_of_adjs}"

ADJ_FLAG = "ADJECTIVE"
CONCEPT_FLAG = "CONCEPT"

adj_counts = {}
concept_counts = {}
concept_adj_counts = {}
STDERR.puts "start reading..."
File.open(path_to_reduced_data) do |file|
    file.each_line do |line|
        hints = line.strip.split(",")
        if hints[0] == ADJ_FLAG
            adj_counts[hints[1]] = hints[3].to_i
        elsif hints[0] == CONCEPT_FLAG
            if hints.size() == 4    # occurrence
                concept_count = hints[3].to_i
                if concept_count >= 500
                    concept_counts[hints[1]] = concept_count
                else
                    STDERR.puts "#{hints[1]}: #{concept_count} is small"
                end
            else    # co-occurrence
                concept_adj_counts[hints[1]] = {} if concept_adj_counts[hints[1]].nil?
                concept_adj_counts[hints[1]][hints[2]] = hints[4].to_i
            end
        end
    end
end
STDERR.puts "read!"

top_k = []
(start_concept, co_c) = concept_counts.min_by {|(_, c)| c}
STDERR.puts "#{start_concept}: #{co_c} times"
concept_adj_counts[start_concept].each do |(adj, _)|
    # pmi p(x, y) / [p(x) p(y)]
    # cancel the common counts
    # -> count(x, y) / [count(x) count(y)]
    val = 0.0
    invalid = false
    concept_counts.each do |(concept, _)|
        if concept_adj_counts[concept][adj].nil? # not co-occurred
            invalid = true
            break
        end
        val += Math.log(concept_adj_counts[concept][adj]) \
                - (Math.log(concept_counts[concept]) \
                    + Math.log(adj_counts[adj]))
    end
    next if invalid
    val /= concept_counts.size()

    # concept, adjective, value
    if top_k.size() >= num_of_adjs
        min_index = top_k.index(top_k.min_by {|(_, v)| v})
        (_, min_val) = top_k[min_index]
        if min_val < val
            top_k[min_index] = [adj, val]
        end
    else
        top_k << [adj, val]
    end
end

(top_k.sort_by {|(_, v)| -v}).each do |(adj, val)|
    puts "#{adj}: #{val}"
end
