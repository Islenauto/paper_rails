# -*- coding: utf-8 -*-
# == Schema Information
#
# Table name: article_infos
#
#  id             :integer          not null, primary key
#  cpw            :float
#  wps            :float
#  ari            :float
#  cli            :float
#  article_id     :integer
#  created_at     :datetime
#  updated_at     :datetime
#  fkg            :float
#  svl_average    :float            default(0.0)
#  svl_variance   :float            default(0.0)
#  svl_count      :integer          default(0)
#  word_count     :integer          default(0)
#  toeic_average  :float            default(0.0)
#  toeic_variance :float            default(0.0)
#

class ArticleInfo < ActiveRecord::Base
  belongs_to :article

  # article情報をもとに SVLに関する情報を登録
  def self.regist_svl_info(article, again_flag = false)
    a_info = article.article_info
    a_info ||= ArticleInfo.new
    return if again_flag == false && a_info.svl_average != 0
    a_info.article_id ||= article.id
    analysis_content = article.analysis_content
    article.regist_analysis if analysis_content.nil?
    return if analysis_content.nil?
    sentence_info = analysis_content.content_arr_flatten
    words = sentence_info.map { |word_info| word_info[2] }
    words.uniq!
    a_info.word_count = words.size if words.present?
    a_info.svl_count = 0
    svl_levels = []
    words.each do |word|
      next if word.blank?
      svl_word = EnglishWord.find_by(spell: word)
      svl_word = EnglishWord.find_by(spell: word.downcase) if svl_word.blank?
      next if svl_word.blank?
      a_info.svl_count += 1
      svl_levels.push(svl_word.word_info.svl_level)
    end
    a_info.svl_average = svl_levels.average
    a_info.svl_variance = svl_levels.variance
    a_info.save
  end

  # article情報をもとに TOEICに関する情報を登録
  def self.regist_toeic_info(article, again_flag = false)
    a_info = article.article_info
    a_info ||= ArticleInfo.new
    return if again_flag == false && a_info.toeic_average != 0
    a_info.article_id ||= article.id
    analysis_content = article.analysis_content
    article.regist_analysis if analysis_content.nil?
    return if analysis_content.nil?
    sentence_info = analysis_content.content_arr_flatten
    words = sentence_info.map { |word_info| word_info[2] }
    words.uniq!
    a_info.word_count = words.size if words.present?
    toeic_scores = []
    words.each do |word|
      next if word.blank?
      toeic_word = EnglishWord.find_by(spell: word)
      toeic_word = EnglishWord.find_by(spell: word.downcase) if toeic_word.blank?
      next if toeic_word.blank? || toeic_word.word_info.weblio_toeic.nil?
      toeic_scores.push(toeic_word.word_info.weblio_toeic)
    end
    a_info.toeic_average = toeic_scores.average
    # p toeic_scores
    a_info.toeic_variance = toeic_scores.variance
    # p a_info
    a_info.save
  end

  # article情報をもとに cpw と wpsを計算し登録
  def self.regist_sentence_info(article)
    a_info = article.article_info
    a_info ||= ArticleInfo.new
    a_info.article_id ||= article.id
    analysis_content = article.analysis_content
    p article
    article.regist_analysis if analysis_content.nil?
    return if analysis_content.nil?
    return if a_info.cpw.present? && a_info.wps.present?
    # 3つ組の配列に変換したものを格納
    sentence_info = analysis_content.content_arr
    words = [] # 単語
    words_num = [] # 文毎の単語数
    words_info, words_num = analysis_sentence(sentence_info)
    a_info.cpw = words_info.map { |word_info| word_info[0] }.cpw
    a_info.wps = words_num.average
    a_info.save
  end

  # 形態素解析結果をもとに 出現単語(words)と文毎の単語数(words_num)を計算
  def self.analysis_sentence(sentence_info)
    words = [] # 単語
    words_num = [] # 文毎の単語数
    sentence_num = 0
    sentence_info.each do |words_info|
      words_info.each do |word_info|
        # word_info[0]本文 word_info[1] word_info[2]原形
        words.push([word_info[0], word_info[1], word_info[2]])
        words_num[sentence_num] ||= 0
        words_num[sentence_num] += 1
        sentence_num += 1 if word_info[1] == 'SENT'
      end
    end
    return words, words_num
  end

  # readabilityを一括登録
  def self.regist_all_readability
    Parallel.each(all, in_threads: 4) do |article_info|
      ActiveRecord::Base.connection_pool.with_connection do
        article_info.regist_readability
      end
    end
  end

  # readabilityを計算
  def regist_readability
    return if self.ari.present? && self.cli.present? && self.fkg.present?
    self.ari = (4.71 * self.cpw) + (0.5 * self.wps) - 21.43
    self.cli = (5.89 * self.cpw) + (0.3 * (100.0/self.wps)) - 15.8
    words_info = article.analysis_content.content_arr_flatten
    # 音節があった単語数
    word_num = 0
    syllable_sum = 0
    words_info.each do |word_info|
      next if word_info[0].nil? || word_info[2].nil?
      english_word = EnglishWord.find_by(spell: word_info[0])
      if english_word.present? && english_word.syllable_num.present?
        word_num += 1
        syllable_sum += english_word.syllable_num
        next
      end
      english_word = EnglishWord.find_by(spell: word_info[0].downcase)
      if english_word.present? && english_word.syllable_num.present?
        word_num += 1
        syllable_sum += english_word.syllable_num
        next
      end
      english_word = EnglishWord.find_by(spell: word_info[2])
      if english_word.present? && english_word.syllable_num.present?
        word_num += 1
        syllable_sum += english_word.syllable_num
        next
      end
      english_word = EnglishWord.find_by(spell: word_info[2].downcase)
      if english_word.present? && english_word.syllable_num.present?
        word_num += 1
        syllable_sum += english_word.syllable_num
        next
      end
    end
    self.fkg = (0.39 * self.wps) + (11.8 * syllable_sum/word_num) - 15.59
    self.save
  end
end
