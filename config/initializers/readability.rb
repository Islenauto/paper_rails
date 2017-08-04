# -*- coding: utf-8 -*-
class Readability
  def self.ARI(paragraph_arr)
    words = [] # 単語
    words_num = [] # 文毎の単語数
    words, words_num = paragraphs_analysis(paragraph_arr)
    cpw_words = words.map { |word| word[0] }
    p cluc_cpw(cpw_words)
    p words_num
    p cluc_wps(words_num)
    ari = (4.71 * cluc_cpw(cpw_words)) + (0.5 * cluc_wps(words_num)) - 21.43
    return ari, words
  end

  def self.CLI(paragraph_arr)
    words = [] # 単語
    words_num = [] # 文毎の単語数
    words, words_num = paragraphs_analysis(paragraph_arr)
    cpw_words = words.map { |word| word[0] }
    cli = (5.89 * cluc_cpw(cpw_words)) + (0.3 * (100.0/cluc_wps(words_num))) - 15.8
    return cli, words
  end

  # character per word
  def self.cluc_cpw(words)
    words.sum_length.to_f / words.size
  end

  # word per sentence
  def self.cluc_wps(words_num)
    words_num.average
  end

  # TreeTaggerを用いて解析
  # 引数   文章の配列
  # 返却値 文章に含まれる全単語, 文毎の単語数
  def self.paragraphs_analysis(paragraph_arr)
    words = [] # 単語
    words_num = [] # 文毎の単語数
    sentence_num = 0 # 何個目の文章か
    paragraph_arr.each do |paragraph|
      result = TreeTagger.analysis(paragraph)
      result.each do |word|
        # word[0]本文 word[1] word[2]原形
        words.push([word[0], word[1]])
        words_num[sentence_num] ||= 0
        words_num[sentence_num] += 1
        sentence_num += 1 if word[1] == 'SENT'
      end
    end
    return words, words_num
  end
end

