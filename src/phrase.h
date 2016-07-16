#pragma once
#include <vector>
#include "morph.h"

namespace order_concepts {
class Phrase {
private:
    std::vector<Morph> m_morphs;
    bool m_is_negative;
    int m_depend;
public:
    Phrase() : m_is_negative(false) {}
    Phrase(const std::vector<Morph>& morphs)
        : m_is_negative(false) { m_morphs = morphs; }
    void add(const Morph& morph);
    bool find(const std::string& lemma, Morph::POS_TAG pos) const;
    bool isNegative() const { return m_is_negative; }
    void clear();
    const std::vector<Morph>& morphs() const { return m_morphs; }
    std::string phrase() const;
    const int& depend() const { return m_depend; }
    void setDepend(int d) { m_depend = d; }
    bool operator==(const Phrase& phrase) const;
    bool operator!=(const Phrase& phrase) const { return !(*this == phrase); }
};
} // namespace order_concepts
