# Ordering Concepts Based on Common Attribute Intensity
- **This is a snapshot of program sources for [IJCAI 16](http://ijcai-16.org/), an top international AI conference.**
    - See [our paper](http://www.ijcai.org/Proceedings/16/Papers/527.pdf).
- **This has not been refactored and will not be maintained.**

author: Tatsuya Iwanari

## Make
Move to _src_ folder and run a command ``make``.

## Usage
In _src_ folder, type the following command
``./main mode input_file output_path [options]``

### mode
_mode_ is an integer parameter to specify what the program will do.

| value | mode name | explanation |
|:------|:----------|:------------|
| 0 | count/reduce/format | do all processes. |
| 1 | reduce/format | do from the second process. |
| 2 | format | do the last process only. |

### input\_file
_input\_file_ differs based on the mode parameter.

| mode value | input\_file |
|:-----------|:------------|
| 0 | a list file of social data files. |
| 1 | a list file of counted files. |
| 2 | a file to be formatted in svm rank format. |

A list file is composed of lines, each line expresses a file like this:

```
/path/to/data0
/path/to/data1
...
```

### output\_path
_output\_path_ is a string parameter to specify the output folder.
All the output of this program will be output into it.

| process | location |
|:--------|:---------|
| count | output\_path/count |
| reduce | output\_path/reduce |
| format | output\_path/format |

### options
_options_ are mode dependent options.

| mode value | options |
|:-----------|:------------|
| 0 | adjective concept\_file [pattern\_file\_path] |
| 1 | [none] |
| 2 | [none] |

_adjective_ is a string parameter which specifies adjective.
_concept\_file_ is the same format as input\_file.
_pattern\_file\_path_ is a path to pattern files for its counter.

## Environment
I checked it will run on Linux (CentOS release 5.11 (Final)).

## Dependency
This program has a depency on liblzma to decode .xz data files and it
needs the following programs:

- Autoconf 2.64
- Automake 1.12
- gettext 0.18 (Note: autopoint depends on cvs!)
- libtool 2.2

If you do not use .xz files, you can remove xz submodule.
