# About
This folder contains some scripts to evaluate the method.


# Evaluations

## Gold Standard
We use human annotated rankings to create gold standard.
Use the following script to create gold standard ranking into [gold](./gold).

Just run [create\_gold\_standard.rb](./create_gold_standard.rb),
a script to create gold standard, which uses [spearman.rb](./util/spearman.rb) as a module.


## Baseline Eval
We use raw values in the counter result files as a baseline.
See result#.txt in [results folder](../../results/gather).
After making a gold standard into [./gold](./gold) folder,
Just run `./run_baseline_evaluation.sh`. It shows parameters which are necessary in evaluation.

### Flow
The [run\_baseline\_evaluation.sh](./run_baseline_evaluation.sh) uses scripts in the following order:

1. sort.rb
1. calc\_spearman.rb



## SVM Eval
After making a gold standard into [./gold](./gold) folder,
Just run `./run_svm_evaluation.sh`. It shows parameters which are necessary in evaluation.

### Flow
The [run\_svm\_evaluation.sh](./run_svm_evaluation.sh) uses scripts in the following order:

1. create\_svm\_validation\_data.rb
1. run\_svm\_validation.sh
1. concat\_svm\_results.rb
1. calc\_spearman.rb



## SVR Eval
**This following description is as same as SVM Eval.**

After making a gold standard into [./gold](./gold) folder,
Just run `./run_svr_evaluation.sh`. It shows parameters which are necessary in evaluation.

### Flow
The [run\_svr\_evaluation.sh](./run_svr_evaluation.sh) uses scripts in the following order:

1. create\_svr\_validation\_data.rb
1. run\_svr\_validation.sh
1. concat\_svr\_results.rb
1. calc\_spearman.rb




# Folders
## gold
This folder contains gold standards created by [create\_gold\_standard.rb](./create_gold_standard.rb).

### gold*.txt
This is a gold standard file in a format
`rho adj concepts`. It looks like

```
0.9893939393939393 大きい クジラ,キリン,ゾウ,クマ,ウシ,ウマ,イヌ,サル,ネコ,ネズミ
0.9333333333333333 安い ハンバーガー,パン,焼きそば,チャーハン,カレー,パスタ,ピザ,ステーキ,寿司
...
```

### gold*.csv
This is a gold standard file in the same format of human annotated files. It looks like:

```
# 大きい
クジラ,1,キリン,2,ゾウ,3,クマ,4,ウシ,5,ウマ,6,イヌ,7,サル,8,ネコ,9,ネズミ,10
# 安い
ハンバーガー,1,パン,2,焼きそば,3,チャーハン,4,カレー,5,パスタ,6,ピザ,7,ステーキ,8,寿司,9
...
```

### rho\_avgs.csv
This is a file to keep gold standards' rhos. It looks like:

```
gold0, 0.8704605987945248
gold1, 0.7962997731732164
```



## util
This folder contains some helper scripts.

### [print.rb](./util/print.rb)
A module to help to print something.

### [spearman.rb](./util/spearman.rb)
A module to calculate speraman's rho (coefficient value)

### [calc\_spearman.rb](./util/calc_spearman.rb)
A script to calculate spearman's rho between 2 files (set of ranking).

### [gather\_results\_based\_on\_cs.rb](./util/gather_results_based_on_cs.rb)
A script to gather results base on super parameter C.





## baseline
This folder keeps some scripts to do baseline evaluation.

### [sort.rb](./baseline/sort.rb)
A script to sort concepts with raw values of counter (use normarized values).



## svm
This folder keeps some scripts to do svm evaluation.

### [create\_svm\_validation\_data.rb](./svm/create_svm_validation_data.rb)
A script to create svm cross validation data.

### [run\_svm\_validation.sh](./svm/run_svm_validation.sh)
A script to run svm cross validation.

### [concat\_svm\_results.rb](./svm/concat_svm_results.rb)
A script to concatenate svm results and format for spearman calculation.

### [tune\_param.rb](./svm/tune_param.rb)
A script to tune C parameter of SVM.



## svr
**This following description is as same as svr.**

This folder keeps some scripts to do svr evaluation.

### [create\_svr\_validation\_data.rb](./svr/create_svr_validation_data.rb)
A script to create svr cross validation data.

### [run\_svr\_validation.sh](./svr/run_svr_validation.sh)
A script to run svr cross validation.

### [concat\_svr\_results.rb](./svr/concat_svr_results.rb)
A script to concatenate svr results and format for spearman calculation.

### [tune\_param.rb](./svr/tune_param.rb)
A script to tune C parameter of SVM.

