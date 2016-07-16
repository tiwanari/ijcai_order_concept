#pragma once
#include <string>
#include <vector>
#include <stdexcept>
#include "util/split.h"

namespace order_concepts {
/**
 * Morph information container class
 * The items in this class are based on
 * Juman dictionary:
 * see http://nlp.ist.i.kyoto-u.ac.jp/index.php?cmd=read&page=JUMAN
 */
class Morph {
public:
   enum class POS_TAG : unsigned char {
       NOUN,
       VERB,
       ADJECTIVE,
       OTHER
   };
private:
   static constexpr const char* STR_POS_NOUN = "名詞";
   static constexpr const char* STR_POS_VERB = "動詞";
   static constexpr const char* STR_POS_ADJECTIVE = "形容詞";
   static constexpr const char* STR_POS_SUFFIX = "接尾辞";
   static constexpr const char* STR_POS_PARTICLE = "助詞";
private:
    std::string m_morph;
    POS_TAG m_pos;
    std::string m_sub_pos0;
    std::string m_ctype;
    std::string m_cform;
    std::string m_lemma;
public:
    void init(const std::string& morph, const std::vector<std::string>& infos)
        throw (std::runtime_error);
    Morph(const std::string& infos);
    Morph(const std::string& morph, const std::string& infos);
    Morph(const std::string& morph, const std::vector<std::string>& infos);
    const std::string& morph() const { return m_morph; }
    const POS_TAG& POS() const { return m_pos; }
    const std::string& subPOS() const { return m_sub_pos0; }
    const std::string& ctype() const { return m_ctype; }
    const std::string& cform() const { return m_cform; }
    const std::string& lemma() const { return m_lemma; }
    bool operator==(const Morph& morph) const;
    bool operator!=(const Morph& morph) const { return !(*this == morph); }
public:
    static inline Morph invalid() { return Morph("!!invalid", "*,*,*,*,*,*"); }
    static inline Morph negative() {
        return Morph("ない",
            "接尾辞,形容詞性述語接尾辞,イ形容詞アウオ段,基本形,ない");
    }
    static POS_TAG POSFrom(const std::string& str);
};
} // namespace order_concepts
