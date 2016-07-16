#include <iostream>
#include "phrase.h"

namespace order_concepts {
void Phrase::add(const Morph& morph)
{
    if (m_morphs.size() != 0 && morph == Morph::negative()) {
        m_is_negative = true;
    }
    m_morphs.emplace_back(morph);
}

bool Phrase::find(const std::string& lemma, Morph::POS_TAG pos) const
{
    std::string concatenated_morphs = "";
    bool is_started = false;
    // reverse traversal (concept can be separated into 2 or more parts)
    // e.g. 冷蔵 庫
    for (int i = m_morphs.size() - 1; i >= 0; --i) {
        const auto& morph = m_morphs[i];
        if (morph.POS() != pos) {
            if (is_started) break;
            continue;
        }
        is_started = true;  // start checking

        // concatenate
        if (pos == Morph::POS_TAG::NOUN) {
            // if it is a noun, concatenate its morph not lemma
            // because some nouns are unknown and don't have lemma
            concatenated_morphs.insert(0, morph.morph());
        }
        else {
            concatenated_morphs.insert(0, morph.lemma());
        }
        // check it size is over the lemma
        if (concatenated_morphs.size() > lemma.size()) break;

        // check lemma
        if (concatenated_morphs == lemma) return true;
    }
    return false;
}

void Phrase::clear()
{
    m_is_negative = false;
    std::vector<Morph>().swap(m_morphs);
}

bool Phrase::operator==(const Phrase& phrase) const
{
    const std::vector<Morph> morphs0 = this->morphs();
    const std::vector<Morph> morphs1 = phrase.morphs();
    return morphs0 == morphs1;
}

std::string Phrase::phrase() const
{
    std::string connected_morphs = "";
    for (const auto& morph : m_morphs) {
        connected_morphs += morph.morph();
    }
    return connected_morphs;
}
} // namespace order_concepts
