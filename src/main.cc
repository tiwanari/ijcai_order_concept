#include <cstdlib>
#include <sstream>
#include <future>
#include <string>
#include <unistd.h>
#include <atomic>
#include "util/stopwatch.h"
#include "util/trim.h"
#include "util/dir.h"
#include "counter.h"
#include "reducer.h"
#include "svm_data_formatter.h"
#include "file_format.h"

void showElapsedTime(
    const std::string& title,
    const order_concepts::util::Stopwatch<std::chrono::milliseconds>& sw)
{
    std::cout << "--- "
        << title << ": " << sw.showElapsedTime().c_str()
        << " ---" << std::endl;
}

void readLinesFromAFile(
    const std::string& input_filename,
    std::vector<std::string>* lines)
{
    std::ifstream input_file;
    input_file.open(input_filename);
    if (!input_file) {
        std::cerr << "Can't open file: " << input_filename << std::endl;
        input_file.close();
        exit(1);
    }
    std::string line;
    while (std::getline(input_file, line)) {
        if (line.empty()) continue;
        lines->emplace_back(order_concepts::util::trim(line));
    }
    input_file.close();
}

void writeQuery(
    const std::string& output_path,
    const std::vector<std::string>& concepts,
    const std::string& adjective)
{
    const std::string kFilename = "query.txt";
    std::ofstream output_file;
    order_concepts::util::mkdir(output_path);   // make directory
    output_file.open(output_path + "/" + kFilename);
    output_file << "adjective: " << adjective << std::endl;
    output_file << "concepts:" << std::endl;
    for (const auto& concept : concepts) {
        output_file << concept << std::endl;
    }
    output_file.close();
}

bool isSameQuery(
    const std::string& output_path,
    const std::vector<std::string>& concepts,
    const std::string& adjective)
{
    const std::string kFilename = "query.txt";
    const std::string kFilepath = output_path + "/" + kFilename;
    std::ifstream input_file;
    input_file.open(kFilepath);
    if (!input_file) {
        input_file.close();
        writeQuery(output_path, concepts, adjective);
        return true;
    }

    std::string line;
    // first line
    std::getline(input_file, line);
    if (line != ("adjective: " + adjective)) {
        input_file.close();
        return false;
    }
    std::getline(input_file, line); // skip a line ("concepts: ")
    for (const auto& concept : concepts) {
        // check concept
        if (!std::getline(input_file, line) || line != concept) {
            input_file.close();
            return false;
        }
    }
    input_file.close();
    return true;
}

std::string outputPath(
    const std::string& prefix,
    const std::string& input_filelist)
{
    const std::string& base = order_concepts::util::basename(input_filelist);
    const std::string& simple_name =
        order_concepts::util::removeExtention(base);
    return prefix + "/" + simple_name;
}

std::string outputFileName(
    const std::string& path,
    const std::string& extention,
    const std::string& input_filename)
{
    const std::string& base = order_concepts::util::basename(input_filename);
    const std::string& simple_name =
        order_concepts::util::removeExtention(base);
    return path + "/" + simple_name + "." + extention;
}

void showProgress(const int& current, const int& all)
{
    float progress = (float) current / all;
    int barWidth = 70;

    std::cerr << "[";
    int pos = barWidth * progress;
    for (int i = 0; i < barWidth; ++i) {
        if (i < pos) std::cerr << "=";
        else if (i == pos) std::cerr << ">";
        else std::cerr << " ";
    }
    std::cerr << "] " << int(progress * 100.0) << " %"
        << " (" << current << "/" << all << ")\r";
    std::cerr.flush();
}

int main(int argc, char* argv[])
{
    setlocale(LC_ALL, "ja_JP.UTF-8");

    // std::cout << "SVM" << std::endl;
    if (argc <= 3) {
        std::cout
            << "Usage: "
            << argv[0] << " mode input_file output_path [options]" << std::endl
            << "see README.md for more information." << std::endl;
        return 1;
    }

    order_concepts::util::Stopwatch<std::chrono::milliseconds> sw;

    // mode
    const int kModeMax = 2; // -1 to kModeMax (include)
    const int mode = std::atoi(argv[1]);
    if (mode < -1 || mode > kModeMax) {
        std::cout
            << "mode should be between " << 0
            << " and " << kModeMax << std::endl;
        return 1;
    }

    // output path
    const std::string kOutputPath = argv[3];
    // input files
    std::vector<std::string> input_files;
    // counted result
    std::vector<std::string> counted_result_files;
    // reduced result
    std::string reduced_result_file =
        kOutputPath + "/reduce/output.reduce";

    if (mode <= 0) {
        if (argc <= 5) {
            std::cout
                << "Not enough parameters for mode 0" << std::endl
                << "Usage: "
                << argv[0]
                << " mode input_file output_path"
                << " adjective concept_file [pattern_file_path]"
                << std::endl
                << "see README.md for more information." << std::endl;
            return 1;
        }
        // read input file names
        input_files.emplace_back(argv[2]);

        order_concepts::util::mkdir(kOutputPath + "/count");
        // read a query (adjective and concepts)
        std::string adjective = argv[4];    // read adjective
        std::vector<std::string> concepts;
        readLinesFromAFile(argv[5], &concepts); // read concepts from a file
        // write query to a file
        if (!isSameQuery(kOutputPath, concepts, adjective)) {
            throw std::runtime_error(
                "Other query result already exists in " + std::string(argv[3]) + "\n");
        }

        // create the file names of counted results
        std::cerr << "=== count target files ===" << std::endl;
        int i = 0;
        for (const auto& file : input_files) {
            std::stringstream ss;
            ss << kOutputPath << "/count/" << i++ << ".count";
            counted_result_files.emplace_back(ss.str());
            std::cerr << file << " -> " <<  ss.str() << std::endl;
        }

        // pattern file path for counter
        const std::string pattern_file_path =
            argc >= 7 ? argv[6] : "../dataset/ja/count_patterns";

        // counting hints
        order_concepts::Counter counter(concepts, adjective);
        counter.readPatternFilesInPath(pattern_file_path); // pattern file
        sw.start();
        std::cout << "--- counting ---" << std::endl;

        // counter mode = -1 (prepare for counting)
        if (mode == -1) counter.setPrepMode(true);

        counter.count(input_files[0], order_concepts::Format::XZ);
        sw.stop();
        showElapsedTime("counted", sw);
        counter.save(counted_result_files[0]);  // save to a file
    }

    if (mode == 1) {
        // input file is a list of counted result files
        readLinesFromAFile(argv[2], &counted_result_files);

        // create the directory of reduced result
        order_concepts::util::mkdir(kOutputPath + "/reduce");

        // show target files
        std::cerr << "=== reduce target files ===" << std::endl;
        for (const auto& file : counted_result_files) {
            std::cerr << file << std::endl;
        }
        std::cerr << "-> " << reduced_result_file << std::endl;

        // reducing hints
        order_concepts::Reducer reducer(counted_result_files);
        std::cout << "--- reducing ---" << std::endl;
        sw.start();
        reducer.reduce(reduced_result_file);
        sw.stop();
        showElapsedTime("reduced", sw);
    }

    if (mode == 1 || mode == 2) {
        // input file is a reduced file
        if (mode == 2) {
            reduced_result_file = argv[2];
        }
        // create the file name of formatted result
        const std::string kFormattedResultFilesPath = kOutputPath +"/format";
        order_concepts::util::mkdir(kFormattedResultFilesPath);

        // show target files
        std::cerr << "=== format target files ===" << std::endl;
        std::cerr << reduced_result_file
            << " -> " << kFormattedResultFilesPath << "/*" << std::endl;

        // formatting reduced hints for ranking-svm
        order_concepts::SvmDataFormatter formatter(reduced_result_file);
        std::cout << "--- formatting ---" << std::endl;
        sw.start();
        formatter.format(kFormattedResultFilesPath);
        sw.stop();
        showElapsedTime("formatted", sw);
    }

    return 0;
}
