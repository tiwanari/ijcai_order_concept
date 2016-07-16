#include <stdexcept>
#include "parser.h"
#include "morph.h"
#include "xz_decoder.h"
#include "util/split.h"

namespace order_concepts {
void Parser::init(
    const std::string& input_filename,
    const Format& format)
{
    m_num_of_lines = 0;
    m_cur_sentence = "";
    m_input_filename = input_filename;
    m_format = format;
    m_decoder = nullptr;

    // open file
    m_input_file.open(m_input_filename);
    if (!m_input_file) {
        m_input_file.close();
        throw std::runtime_error(
            "Can't open file: " + m_input_filename + "\n");
    }

    // create decoder
    switch (m_format) {
        case Format::PLAIN:
            m_decoder = nullptr;
            break;
        case Format::XZ:
            m_decoder = new XzDecoder(&m_input_file);
            break;
    }
}

Parser::Parser(
    const std::string& input_filename,
    const Format& format)
{
    init(input_filename, format);
}

Parser::Parser(const std::string& input_filename)
{
    init(input_filename, Format::PLAIN);
}

Parser::~Parser()
{
    m_input_file.close();
    if (m_decoder != nullptr) {
        delete m_decoder;
    }
    m_decoder = nullptr;
}

Parser::Type
Parser::sentenceType(const std::vector<std::string>& splitted_line) const
{
    // blank
    if (splitted_line.size() == 0) {
        return Type::UNKNOWN;
    }

    const std::string& first_word = splitted_line[0];
    if (first_word == EOS_PREFIX) {
        return Type::EOS;
    } else if (first_word == SOS_OR_SOURCE_PREFIX) {
        if (splitted_line[1] == SOS_SECOND_PREFIX) {
            return Type::SOS;
        } else {
            return Type::SOURCE;
        }
    } else if (first_word == DIRECTIVE_PREFIX) {
        return Type::DIRECTIVE;
    }
    return Type::PLAIN;
}

/**
 * parse line
 * @param line
 * @return the first word
 */
Parser::Type Parser::parseLine(const std::string& line)
{
    std::vector<std::string> splitted_line;
    util::splitStringWithWhitespaces(line, &splitted_line);
    switch (sentenceType(splitted_line)) {
        case Type::SOURCE: {
            // e.g. # http://foo.com http://bar.html 1357052399 年が明けたら
            // TODO: save this information
            // if (m_num_of_lines != 0) {
            // }
            return Type::SOURCE;
        }

        case Type::SOS: {
            // e.g. # S-ID: 399625; J.DepP
            return Type::SOS;
        }

        case Type::PLAIN: {
            // e.g. 知り合い	名詞,普通名詞,*,*,知り合い,未知語
            // create morph and add it into current phrase
            try {
                if (splitted_line.size() < 2) {
                    throw std::runtime_error("Not enough params\n");
                }
                Morph morph(splitted_line[0], splitted_line[1]);
                m_cur_phrase.add(morph);
            } catch (const std::runtime_error& e) {
                std::stringstream ss;
                ss << e.what();
                ss << "error at " << m_input_filename
                    << std::endl
                    << " (S-ID: " << (m_num_of_lines + 1) << "): "
                    << line << std::endl
                    << "so, skip this morph" << std::endl;
                std::cerr << ss.str() << std::endl;
                // add invalid morph
                m_cur_phrase.add(Morph::invalid());
            }
            return Type::PLAIN;
        }

        case Type::DIRECTIVE: {
            // e.g. * 0 1D
            // connect words
            // atoi converts 1D (string) to 1 (int), D is ignored
            const int depend = std::atoi(splitted_line[2].c_str());
            // add current phrase into a vector and concatenate sentence
            if (splitted_line[1] != "0") {
                m_cur_phrases.emplace_back(m_cur_phrase);
                m_cur_sentence += m_cur_phrase.phrase();
            }
            m_cur_phrase.clear();
            m_cur_phrase.setDepend(depend);

            m_cur_connections.emplace_back(depend);
            return Type::DIRECTIVE;
        }

        case Type::EOS: {
            // e.g. EOS
            // add the last word
            m_cur_phrases.emplace_back(m_cur_phrase);
            m_cur_sentence += m_cur_phrase.phrase();
            m_num_of_lines++;
            return Type::EOS;
        }

        case Type::UNKNOWN:
            return Type::UNKNOWN;
    }
    return Type::UNKNOWN;
}

bool Parser::next()
{
    // initialize variables
    m_cur_sentence = "";
    std::vector<Phrase>().swap(m_cur_phrases);
    std::vector<int>().swap(m_cur_connections);

    while (true) {
        // read a line
        bool is_eof;
        std::string line;
        if (m_decoder != nullptr) {
            // read data from an encoded file
            is_eof = !m_decoder->getline(&line);
        }
        else {
            // read data from a normal file
            is_eof = !std::getline(m_input_file, line);
        }

        // break if input reaches its end
        if (is_eof) {
            break;
        }

        if (parseLine(line) == Type::EOS) {
            return true;
        }
    }
    return false;
}

std::vector<Morph> Parser::morphs() const
{
    std::vector<Morph> morphs;
    for (const auto& phrase : m_cur_phrases) {
        for (const auto& morph : phrase.morphs()) {
            morphs.emplace_back(morph);
        }
    }
    return morphs;
}
} // namespace order_concepts
