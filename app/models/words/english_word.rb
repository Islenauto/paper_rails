# -*- coding: utf-8 -*-
# == Schema Information
#
# Table name: english_words
#
#  id           :integer          not null, primary key
#  spell        :text
#  syllable_num :integer
#  created_at   :datetime
#  updated_at   :datetime
#

require 'parallel'
require 'mechanize'

class EnglishWord < ActiveRecord::Base
  has_one :word_info, dependent: :destroy
  has_many :word_histories
  validates :spell, presence: true, uniqueness: true

  # SVL12000のデータを登録
  def self.regist_svl12000
    Parallel.each(get_svl12000_list, :in_threads => 50) do |word_data|
      ActiveRecord::Base.connection_pool.with_connection do
        result = find_by(spell: word_data[0])
        result = create(spell: word_data[0]) if result.nil?
        next if result.blank?
        word_info = result.word_info
        result.create_word_info(svl_level: word_data[1]) if word_info.nil?
        word_info.update(svl_level: word_data[1]) unless word_info.nil?
      end
    end
  end

  # SVL12000の単語データを取得し配列にして返却
  def self.get_svl12000_list
    word_list = []
    1.upto(12) do |num|
      num_st = "%02d" % num
      file_name = "data/SVL12000/level#{num_st}.txt"
      File.read(file_name).split(/\n/).each do |word|
        word_list.push([word, num])
      end
    end
    word_list
  end

  # 音節(syllable_num)を取得する ファイルからまとめて
  def self.regist_syllable
    File.open('data/ewd/ewd.txt', 'r:utf-8') do |f|
      while line = f.gets
        data = line.split(/\s/)
        word = find_by(spell: data[0])
        next if word.nil?
        word.syllable_num = data[1]
        word.save
      end
    end
  end

  # 音節数を登録 並列処理
  def self.regist_syllable_ewd
    file_list = []
    identifier = 'aa'
    loop do
      file_list.push("data/ewd/out_#{identifier}")
      identifier.next!
      break if identifier == "cr"
    end
    Parallel.each(file_list, in_threads: 20) do |file_name|
      ActiveRecord::Base.connection_pool.with_connection do
        File.open(file_name, 'r:utf-8') do |f|
          while line = f.gets
            data = line.split(/\t/)
            word = find_by(spell: data[0])
            next if word.nil?
            word.syllable_num = data[1]
            word.save
          end
        end
      end
    end
  end

  # 音節を取得する weblioから
  def self.regist_syllable_weblio
    agent = Mechanize.new
    where(syllable_num: nil).each do |word|
      page = agent.get("http://ejje.weblio.jp/content/#{word.spell}")
      sleep(5)
      result = page.search('.KejjeAcOs')
      if result.present?
        word.syllable_num = result.text.count('・') + 1
        word.save
        next
      end
      result = page.search('.KejjeOs')
      if result.present?
        word.syllable_num = result.text.count('・') + 1
        word.save
        next
      end
      word.syllable_num = nil
      word.save
    end
  end

  # 英単語のweblioに関する情報を取得
  def regist_weblio_wordinfo
    wordinfo = word_info
    if wordinfo.nil?
      return false
    end
    if wordinfo.weblio_level.present? && wordinfo.weblio_toeic.present?
      return false
    end
    if wordinfo.weblio_level.blank? || wordinfo.weblio_toeic.blank?
      wordinfo_hash = scrap_weblio
      p wordinfo_hash
      result = wordinfo.update(weblio_level: wordinfo_hash['level'], weblio_toeic: wordinfo_hash['toeic'])
    end
    result
  end

  def scrap_weblio
    agent = Mechanize.new
    page = agent.get("http://ejje.weblio.jp/content/#{spell}")
    wordinfo_hash = get_weblio_wordinfo(page.search(".pplLbT td"))
    wordinfo_hash
  end

  def get_weblio_wordinfo(word_data)
    wordinfo_hash = {}
    word_data.each_with_index do |data, index|
      if data.text == "レベル"
        word_data[index + 1].text =~ /\d+/
        wordinfo_hash['level'] = $&
        next
      end
      if data.text == "TOEICスコア"
        word_data[index + 1].text =~ /\d+/
        wordinfo_hash['toeic'] = $&
      end
    end
    wordinfo_hash
  end

  # 登録されている単語をHashに変換
  def self.convert_hash
    english_words = {}
    EnglishWord.all.map{ |word| english_words[word.spell] = word.word_info.svl_level }
    english_words
  end
end
