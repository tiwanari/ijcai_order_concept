#include <gtest/gtest.h>
#include <string>
#include "../morph.h"

using namespace order_concepts;

class MorphTest : public ::testing::Test {
protected:
    virtual void SetUp() {}
    virtual void TearDown() {}
};

TEST_F(MorphTest, createAMorphFromASentence)
{
    const std::string kInputText =
        "ました	接尾辞,動詞性接尾辞,"
        "動詞性接尾辞ます型,タ形,ます,既知語";
    Morph morph(kInputText);

    ASSERT_EQ(morph.morph(), "ました");
    ASSERT_EQ(morph.POS(), Morph::POS_TAG::OTHER);
    ASSERT_EQ(morph.subPOS(), "動詞性接尾辞");
    ASSERT_EQ(morph.ctype(), "動詞性接尾辞ます型");
    ASSERT_EQ(morph.cform(), "タ形");
    ASSERT_EQ(morph.lemma(), "ます");
}

TEST_F(MorphTest, createAMorphFromSentences)
{
    const std::string kMorph = "ました";
    const std::string kInfos =
        "接尾辞,動詞性接尾辞,"
        "動詞性接尾辞ます型,タ形,ます,既知語";
    Morph morph(kMorph, kInfos);

    ASSERT_EQ(morph.morph(), "ました");
    ASSERT_EQ(morph.POS(), Morph::POS_TAG::OTHER);
    ASSERT_EQ(morph.subPOS(), "動詞性接尾辞");
    ASSERT_EQ(morph.ctype(), "動詞性接尾辞ます型");
    ASSERT_EQ(morph.cform(), "タ形");
    ASSERT_EQ(morph.lemma(), "ます");
}

TEST_F(MorphTest, createAMorphFromASentenceAndAVector)
{
    const std::string kMorph = "ました";
    const std::string kInfos =
        "接尾辞,動詞性接尾辞,"
        "動詞性接尾辞ます型,タ形,ます,既知語";
    std::vector<std::string> infos;
    util::splitStringUsing(kInfos, ",", &infos);
    Morph morph(kMorph, infos);

    ASSERT_EQ(morph.morph(), "ました");
    ASSERT_EQ(morph.POS(), Morph::POS_TAG::OTHER);
    ASSERT_EQ(morph.subPOS(), "動詞性接尾辞");
    ASSERT_EQ(morph.ctype(), "動詞性接尾辞ます型");
    ASSERT_EQ(morph.cform(), "タ形");
    ASSERT_EQ(morph.lemma(), "ます");
}

TEST_F(MorphTest, createAMorphFromASentence2)
{
    const std::string kInputText =
        "切り返し	名詞,普通名詞,*,*,切り返し,未知語";
    Morph morph(kInputText);

    ASSERT_EQ(morph.morph(), "切り返し");
    ASSERT_EQ(morph.POS(), Morph::POS_TAG::NOUN);
    ASSERT_EQ(morph.subPOS(), "普通名詞");
    ASSERT_EQ(morph.ctype(), "*");
    ASSERT_EQ(morph.cform(), "*");
    ASSERT_EQ(morph.lemma(), "切り返し");
}
