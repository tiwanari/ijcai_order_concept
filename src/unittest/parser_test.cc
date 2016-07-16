#include <gtest/gtest.h>
#include <stdexcept>
#include <string>
#include <future>
#include "../parser.h"
#include "../phrase.h"
#include "../file_format.h"

using namespace order_concepts;

struct ParserTestData {
    std::string filename;
    Format format;
} kSmall[] = {
    { "./unittest/dataset/parser_test_data0.JDP", Format::PLAIN, },
    { "./unittest/dataset/parser_test_data0.JDP.xz", Format::XZ, },
};

class ParserTest : public ::testing::TestWithParam<ParserTestData> {
protected:
    virtual void SetUp() {}
    virtual void TearDown() {}
};

TEST_P(ParserTest, openFileSuccessfully)
{
    const std::string kExistingDataset = GetParam().filename;
    const Format kFileFormat = GetParam().format;
    ASSERT_NO_THROW({
        Parser parser(kExistingDataset, kFileFormat);
    });
}

TEST_P(ParserTest, openFileUnsuccessfully)
{
    const std::string kNotExistingDataset = "./not_exist.txt";
    const Format kFileFormat = GetParam().format;
    ASSERT_THROW({
        Parser parser(kNotExistingDataset, kFileFormat);
    }, std::runtime_error);
}

TEST_P(ParserTest, readEmptyRawValue)
{
    const std::string kSmallDataset = GetParam().filename;
    const Format kFileFormat = GetParam().format;
    Parser parser(kSmallDataset, kFileFormat);
    ASSERT_EQ("", parser.raw());
}

TEST_P(ParserTest, parseASentence)
{
    const std::string kSmallDataset = GetParam().filename;
    const Format kFileFormat = GetParam().format;
    const std::string kFirstLine =
        "すくすくと育ち早いものであと３日で４ヶ月です。";
    Parser parser(kSmallDataset, kFileFormat);
    ASSERT_TRUE(parser.next());
    ASSERT_EQ(kFirstLine, parser.raw());
}

TEST_P(ParserTest, parseSentences)
{
    const std::string kSmallDataset = GetParam().filename;
    const Format kFileFormat = GetParam().format;
    const std::string kFirstLine =
        "すくすくと育ち早いものであと３日で４ヶ月です。";
    const std::string kSecondLine =
        "元気に育ってくれてるのでそれだけで嬉しいです。";
    Parser parser(kSmallDataset, kFileFormat);
    ASSERT_TRUE(parser.next());
    ASSERT_EQ(kFirstLine, parser.raw());
    ASSERT_TRUE(parser.next());
    ASSERT_EQ(kSecondLine, parser.raw());
    ASSERT_FALSE(parser.next());
}

// TEST_F(ParserTest, parseLargeData)
// {
//     const std::string kLargeDataset =
//         "./unittest/dataset/parser_test_data1.JDP";
//     const long kNumOfLines = 10000;
//     Parser parser(kLargeDataset);
//     while (parser.next()) {
//     }
//     ASSERT_EQ(kNumOfLines, parser.numberOfLines());
// }

TEST_P(ParserTest, parseASentenceAsPhrases)
{
    const std::string kSmallDataset = GetParam().filename;
    const Format kFileFormat = GetParam().format;
    const std::vector<std::string> kPhrases =
        {"すくすくと",
        "育ち",
        "早い",
        "もので",
        "あと",
        "３日で",
        "４ヶ月です。", };
    Parser parser(kSmallDataset, kFileFormat);
    ASSERT_TRUE(parser.next());

    const std::vector<Phrase>& parsed_phrases = parser.phrases();
    ASSERT_EQ(kPhrases.size(), parsed_phrases.size());
    for (int i = 0; i < kPhrases.size(); ++i) {
        ASSERT_EQ(kPhrases[i], parsed_phrases[i].phrase());
    }
}

// TEST_F(ParserTest, parseInParallel)
// {
//     const std::string kLargeDataset =
//         "./unittest/dataset/parser_test_data1.JDP";
//     const long kNumOfLines = 10000;
//     const int kNumParser = 3;
// 
//     std::vector<int> count(kNumParser);
//     std::vector<std::thread> threads;
//     for (int i = 0; i < kNumParser; ++i) {
//         threads.push_back(
//             std::thread([i, kLargeDataset, &count] {
//                 Parser parser(kLargeDataset);
//                 while (parser.next()) {
//                 }
//                 count[i] = parser.numberOfLines();
//             })
//         );
//     }
//     for (std::thread& th : threads) {
//         th.join();
//     }
//     for (int i = 0; i < kNumParser; ++i) {
//         ASSERT_EQ(kNumOfLines, count[i]);
//     }
// }

TEST_P(ParserTest, parseASentenceAsConnections)
{
    const std::string kSmallDataset = GetParam().filename;
    const Format kFileFormat = GetParam().format;
    const std::vector<int> kConnections = {1, 2, 3, 6, 5, 6, -1, };
    Parser parser(kSmallDataset, kFileFormat);
    ASSERT_TRUE(parser.next());

    const std::vector<int>& connections = parser.connections();
    ASSERT_EQ(kConnections.size(), connections.size());
    for (int i = 0; i < kConnections.size(); ++i) {
        ASSERT_EQ(kConnections[i], connections[i]);
    }
}

TEST_P(ParserTest, followConnections)
{
    const std::string kSmallDataset = GetParam().filename;
    const Format kFileFormat = GetParam().format;
    Parser parser(kSmallDataset, kFileFormat);
    ASSERT_TRUE(parser.next());

    const std::vector<int> kConnections[] =
        {{1, 2, 3, 6, -1, },
         {2, 3, 6, -1},
         {3, 6, -1},
         {6, -1},
         {5, 6, -1},
         {6, -1},
         {-1}};
    const std::vector<int>& connections = parser.connections();
    for (int i = 0; i < connections.size(); ++i) {
        int index = connections[i];
        int j = 0;
        while (index != -1) {
            ASSERT_EQ(kConnections[i][j], index);
            index = connections[index];
            j++;
        }
    }
}

INSTANTIATE_TEST_CASE_P(
    TestWithSmallDataSet,
    ParserTest,
    ::testing::ValuesIn(kSmall));
