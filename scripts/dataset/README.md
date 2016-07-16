# About
scripts to make dataset.

# Files
## make\_dataset.sh
Create queries from a concept file, an adjective file and an antonym file.

### Usage
1. Go to a query folder (e.g. queries3).
    - This folder should have ``all.txt``, ``all_adj.txt`` and ``all_ant.txt``.
2. Run this script:
```
(PATH_TO_THIS_FOLDER)/make_dataset.sh
```
3. Some folder will be made such as query1, query2, ..., queryN
and they have ``concepts.txt``, ``adjective.txt``, ``antonym.txt``.

## run\_list\_candidate\_adjs.sh
A runner script to run [list\_candidate\_adjs.rb](./list_candidate_adjs.rb) for many times.
This script picks up Top K average PMI adjectives from reduced counts file for preparation (order\_concepts' mode=-1)
into ``(path_to_reduced_data)/adjs_threshold``.

### Usage
```
./run_list_candidate_adjs.sh path_to_reduced_data top_k #queries
e.g. ./run_list_candidate_adjs.sh ../../result/prep3/feed/queries4 30 41
```


## list\_candidate\_adjs.rb
A script which can be run with [run\_list\_candidate\_adjs.sh](./run_list_candidate_adjs.sh)
This script picks up Top K average PMI adjectives from a file and show them into stdout.

### Usage
```
./list_candidate_adjs.rb path_to_reduced_data top#
e.g. ./list_candidate_adjs.sh ../../result/prep3/feed/queries4/query1/reduce/output.reduce 30
```


## format\_human\_annotation.rb
Format human annotated data to a readable file for a computer in order to make gold standards from them.

### Usage
```
./format_human_annotation.rb path_to_human_data
e.g. ./format_human_annotation.rb.rb ../../dataset/gold/gold2/yokoyama/yokoyama.txt
```


## choose\_concepts\_randomly.rb
Choose some concepts from a query's concept file.
This script will be used for reducing # of concepts to avoid large time consumption.
I used it to reduce # of concepts from 9 or more to less than 8 for IJCAI2016
and, after running this script,
I used [remove\_concepts\_from\_human\_annotation.py](remove_concepts_from_human_annotation.py).

### Usage
```
./choose_concepts_randomly.rb path_to_concepts_file #max_choose
e.g. ./choose_concepts_randomly.rb ../queries4/all.txt 8"
```


## remove\_concepts\_from\_human\_annotation.py
Remove selected concepts from human annotated file and adjust the file based on the changes.
I used it with [choose\_concepts\_randomly.rb](./choose_concepts_randomly.rb) for IJCAI2016.

### Usage
```
./remove_concepts_from_human_annotation.py all_concepts_file < human_annnoatation
e.g. ./format_human_annotation.rb.rb ../queries4/all.txt < ../../dataset/gold/gold2/yokoyama/yokoyama.txt
```
