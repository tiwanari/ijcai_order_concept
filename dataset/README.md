# Dataset Repository for Ordering Concepts
This repository contains queries to be processed and pattern files to count signal patterns.

## Structure of Directories
This structure of this repository should look like this:

```
.
├── README.md
└── language0
    ├── count_patterns
    │   ├── comparative.txt
    │   ├── ...
    │   └── simile.txt
    └── queries
        └── ...
└── language1
    ├── count_patterns
    │   ├── comparative.txt
    │   ├── ...
    │   └── simile.txt
    └── queries
        └── ...
```

Please use _the same lexer_ on the dataset and patterns.

## Usage
Specify the path of the language you want to use when you use counter.h of order\_concepts.

## Pattern File
The list of pattern files is shown bellow.

| name | content |
|:-----|:--------|
| simile.txt | Simile patterns. |
| comparative.txt | Comparative patterns. |

### Tags
Tags should begin with '!' and the list is shown bellow.

| name | in pattern file |
|:-----|:--------|
| concept 0 | !CONCEPT0 |
| concept 1 | !CONCEPT1 |
| adjective | !adjective |
