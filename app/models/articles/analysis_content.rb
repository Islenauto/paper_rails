# -*- coding: utf-8 -*-
# == Schema Information
#
# Table name: analysis_contents
#
#  id         :integer          not null, primary key
#  content    :text
#  article_id :integer
#  created_at :datetime
#  updated_at :datetime
#

class AnalysisContent < ActiveRecord::Base
  belongs_to :article

  # 単語 情報 原形をひとつのセットbr区切りごとにまとめて返却
  def content_arr
    content.split(/<br>/).map { |b| b.split(" ").each_slice(3).to_a }
  end

  # br区切りではなく単に単語のリストとして返却
  def content_arr_flatten
    content_arr.flatten.each_slice(3).to_a
  end

  # SVLでの出現頻度を計算 uniq_flagで単語の重複を認めるかどうか変更
  def self.cluc_svl_freq(uniq_flag = true)
    svl_levels = { 'none' => 0 }
    (1..12).each { |num| svl_levels[num] = 0 }
    self.all.each do |analysis_content|
      return if analysis_content.nil?
      sentence_info = analysis_content.content_arr_flatten
      next if sentence_info.blank?
      words = sentence_info.map { |word_info| word_info[2] }
      words.uniq! if uniq_flag == true
      words.each do |word|
        next if word.blank?
        svl_word = EnglishWord.find_by(spell: word)
        svl_word = EnglishWord.find_by(spell: word.downcase) if svl_word.blank?
        if svl_word.blank?
          svl_levels['none'] += 1
          next
        end
        svl_levels[svl_word.word_info.svl_level] += 1
      end
    end
    svl_levels
  end

  # SVLでの出現頻度を計算 uniq_flagで単語の重複を認めるかどうか変更
  def cluc_svl_freq(uniq_flag = true)
    sentence_info = self.content_arr_flatten
    return if sentence_info.blank?
    words = sentence_info.map { |word_info| word_info[2] }
    words.uniq! if uniq_flag == true
    svl_levels = { 'none' => 0 }
    (1..12).each { |num| svl_levels[num] = 0 }
    words.each do |word|
      next if word.blank?
      svl_word = EnglishWord.find_by(spell: word)
      svl_word = EnglishWord.find_by(spell: word.downcase) if svl_word.blank?
      p svl_levels
      if svl_word.blank?
        svl_levels['none'] += 1
        next
      end
      p svl_levels
      svl_levels[svl_word.word_info.svl_level] += 1
    end
    svl_levels
  end
end
