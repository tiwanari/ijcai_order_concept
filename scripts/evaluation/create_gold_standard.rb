#!/usr/bin/env ruby
require_relative "util/spearman"
require_relative "util/print"

def path_to_person(path_prefix, i)
    "#{path_prefix}/person#{i}.csv"
end

def path_to_concepts(path_prefix, q)
    "#{path_prefix}/query#{q+1}/concepts.txt"
end

def path_to_adjective(path_prefix, q)
    "#{path_prefix}/query#{q+1}/adjective.txt"
end

def path_to_antonym(path_prefix, q)
    "#{path_prefix}/query#{q+1}/antonym.txt"
end

def read_concepts(path_prefix, q)
    ranking = []
    # read each line
    File.foreach(path_to_concepts(path_prefix, q)).each do |line|
        ranking << line.strip
    end
    return ranking
end

def read_adjective(path_prefix, q)
    # read the first each line
    File.foreach(path_to_adjective(path_prefix, q)).each do |line|
        return line.strip
    end
end

def read_antonym(path_prefix, q)
    # read the first each line
    File.foreach(path_to_antonym(path_prefix, q)).each do |line|
        return line.strip
    end
end

require_params = 4
if ARGV.length < require_params
    puts "This script needs at least #{require_params} parameters"
    puts "Usage: #{__FILE__} path_to_persons_data #ranks #data path_to_queries"
    puts "e.g. #{__FILE__} ../../dataset/gold 8 4 ../queries0"
    exit 1
end

OUT_LENGTH = 80

path_to_persons = ARGV[0]
num_of_ranks = ARGV[1].to_i
num_of_data = ARGV[2].to_i
path_to_queries = ARGV[3]

STDERR.puts "path_to_persons: #{path_to_persons}"
STDERR.puts "num_of_ranks: #{num_of_ranks}"
STDERR.puts "num_of_data: #{num_of_data}"
STDERR.puts "path_to_queries: #{path_to_queries}"

# read concepts
puts_line("read concepts and adjectives", OUT_LENGTH, STDERR)
concept_list = []
adjective_list = []
antonym_list = []
num_of_ranks.times do |i|
    concept_list << read_concepts(path_to_queries, i)
    adjective_list << read_adjective(path_to_queries, i)
    antonym_list << read_antonym(path_to_queries, i)
end
puts_line("!read concepts and adjectives", OUT_LENGTH, STDERR)
STDERR.puts concept_list.to_s
STDERR.puts adjective_list.join(",")

puts_line("read persons data", OUT_LENGTH, STDERR)
persons = []
num_of_data.times do |i|
    x = path_to_person(path_to_persons, i)
    xss = read_ranks_from_file(x)
    xss = avg_ranks(xss)
    STDERR.puts "xss #{i}: #{xss}"
    STDERR.puts ""
    persons << xss
end
puts_line("!read persons data", OUT_LENGTH, STDERR)

puts_line("search optimized data", OUT_LENGTH, STDERR)
output_content = ""
rhos = []
for_plot = ""
concept_list.each.with_index do |concepts, i|
    max_rho = -2.0
    best = []
    rhos_of_best = []
    # puts "target: #{concepts.join(",")}"
    concepts.permutation do |candidate|
        yss = Hash[candidate.map.with_index {|concept, j| [concept, j + 1]}]
        # puts yss

        rho = 0.0
        candidate_rhos = []
        persons.each_with_index do |rankings, p|
            begin
                r = spearman(rankings[i], yss)
            rescue => ex
                STDERR.puts "#{p}, #{ex.message}"
            end
            rho += r
            candidate_rhos << r
        end
        rho /= num_of_data # average

        if max_rho < rho
            best = candidate
            max_rho = rho
            rhos_of_best = candidate_rhos
        end
    end
    puts "#{max_rho} #{adjective_list[i]} #{best.join(",")}"
    rhos_of_best.each do |r|
        for_plot.concat("#{r} ")
    end
    for_plot.concat("#{adjective_list[i]},#{antonym_list[i]} #{best.join(",")}\n")
    rhos << max_rho
    output_content.concat("# #{adjective_list[i]}\n")
    rank_with_index = best.map.with_index {|concept, rank| [concept, rank+1]}
    output_content.concat("#{rank_with_index.flatten.join(",")}\n")
end

puts "rho avg: #{rhos.reduce(:+) / rhos.size}"
puts_line("different format", OUT_LENGTH, STDERR)
puts output_content

puts_line("for plot", OUT_LENGTH, STDERR)
puts for_plot
