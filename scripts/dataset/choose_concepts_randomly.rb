#!/usr/bin/env ruby
require_params = 2
if ARGV.length < require_params
    puts "This script needs at least #{require_params} parameters"
    puts "Usage: #{__FILE__} path_to_concepts_file #max_choose"
    puts "e.g. #{__FILE__} ../queries4/all.txt 8"
    exit 1
end

path_to_concepts_file = ARGV[0]
max_choose = ARGV[1].to_i

puts "path_to_concepts_file: #{path_to_concepts_file}"
puts "#max_choose: #{max_choose}"

File.open(path_to_concepts_file) do |file|
    file.each_line do |line|
        concepts = line.strip.split("，")
        if concepts.size <= max_choose
            puts concepts.join(",")
        else
            puts concepts.sample(max_choose).join(",")
        end
    end
end
