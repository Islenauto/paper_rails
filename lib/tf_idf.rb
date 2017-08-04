# -*- coding: utf-8 -*-
require 'matrix'

class TfIdf
  def initialize()
    # 全ての文書で出現した単語
    @vocabulary = []
    # 文書のID管理
    @centences = []
    # 文書の数
    @centence_count = 0
    # 文書に出現する単語を行列で管理
    @centences_matrix = [[]]
    # tf-idfの行列
    @tfidf_matrix = [[]]
  end

  # 単語の集合と文書の番号を引数としてもらい
  # 文書毎の単語頻度を数え上げ
  def train(words, centence_id = nil)
    @centences.push(centence_id) if @centences.index(centence_id).nil?
    if centence_id.nil? || centence_id > @centence_count
      @centence_count += 1
      centence_id = @centence_count
    end
    @centences_matrix[centence_id] ||= Array.new
    words.each do |word|
      @vocabulary.push(word) if @vocabulary == []
      word_id = @vocabulary.index(word)
      if word_id.nil?
        @vocabulary.push(word)
        word_id = @vocabulary.size - 1
      end
      @centences_matrix[centence_id][word_id] ||= 0
      @centences_matrix[centence_id][word_id] += 1
    end
  end

  # tf-idfを計算
  def cluc_tf_idf
    @tfidf_matrix = [[]]
    # 行列の整形と単語の文書頻度の計測
    word_info = Array.new # 単語の文書頻度
    (0..@centence_count).each do |c_id|
      (0...@vocabulary.size).each do |w_id|
        @centences_matrix[c_id][w_id] = 0 if @centences_matrix[c_id][w_id].nil?
        word_info[w_id] ||= 0
        word_info[w_id] += 1 if @centences_matrix[c_id][w_id] != 0
      end
    end
    # tf-idfの計算
    (0..@centence_count).each do |c_id|
      # 文章に出現する単語の合計
      word_sum = sum(@centences_matrix[c_id])
      (0...@vocabulary.size).each do |w_id|
        next if word_info[w_id] == 0
        tf = @centences_matrix[c_id][w_id] * 1.0 / word_sum
        idf = Math.log((@centence_count+1) / word_info[w_id]) + 1
        @tfidf_matrix[c_id] ||= []
        @tfidf_matrix[c_id][w_id] = tf * idf
      end
    end
  end

  # コサイン類似度の計算
  def cluc_cos_sim(words)
    # 検索対象を追加前の状態を保存
    pre_centences_matrix = Marshal.load(Marshal.dump(@centences_matrix))
    pre_vocabulary =  Marshal.load(Marshal.dump(@vocabulary))
    # 検索対象をデータに追加しtf-idfを計算
    train(words)
    cluc_tf_idf
    p @tfidf_matrix
    # 検索対象のベクトルを取り出す
    input_vector = Vector.elements(@tfidf_matrix.pop())
    # 追加前の状態に戻す
    @centence_count -= 1
    @centences_matrix = pre_centences_matrix
    @vocabulary = pre_vocabulary
    p @tfidf_matrix
    # 結果配列の初期化
    result = {}
    @tfidf_matrix.each_with_index do |row, index|
      row_vector = Vector.elements(row)
      cos = row_vector.inner_product(input_vector) / (row_vector.norm * input_vector.norm)
      result[index] = cos
    end
    # 降順ソート
    result.sort_by { |k, v| -v }.to_h
  end

  # 配列の総和を返却
  def sum(array)
    array.inject {|sum, n| sum + n }
  end

  def print_matrix
    p @vocabulary.size
    p @centence_count
    # p @vocabulary
    # p @centences
    # p @centences_matrix
    p @tfidf_matrix
  end

  def get_tfidf_matrix
    @tfidf_matrix
  end

  def self.test
    a = TfIdf.new
    a.train("accb".split(//), 0)
    a.train("accceef".split(//),1)
    a.train("afc".split(//),2)
    a.train("badc".split(//),3)
    a.cluc_tf_idf
    a.print_matrix
  end

  def self.test2
    sentence_count = -1
    nline_count = 0
    hoge = TFIDF.new
    File.foreach("doc_set.txt") do |line|
      if line == "\n"
        nline_count += 1
        if nline_count == 2
          sentence_count += 1
          nline_count = 0
          p sentence_count
        end
        next
      end
      hoge.train(line.split(/\s/), sentence_count)
      # hoge.print_matrix
      # hoge.print_matrix
      nline_count = 0
    end
    hoge
  end
  
  def self.title_tf_idf
    hoge = TfIdf.new
    a = 0
    #Article.all.each do |article|
    " 23"
    Article.where.not(title: nil).where("month = ? and day = ?", 1, 21).each do |article|
    # Article.where.not(title: nil).where("month = ? and day = ?", 1, 9).each do |article|
      next if article.title.nil?
      p a
      hoge.train(article.title.split(/\s{2,}/), a)
      sentence_arr = article.content.sentence.gsub(/\s{2,}/, "").split(/<br>/)
      p sentence_arr
      hoge.train(sentence_arr[0].split(/\s/), a) unless sentence_arr[0].nil? && !sentence_arr[0].include?("January 21, 2015")
      hoge.train(sentence_arr[1].split(/\s/), a) unless sentence_arr[1].nil?
      a += 1
    end
    # hoge.cluc_tf_idf
    hoge
  end

  def cluc_cos_sim2(centences_id)
    # 検索対象のベクトルを取り出す
    input_vector = Vector.elements(@tfidf_matrix[centences_id])
    # 結果配列の初期化
    result = {}
    @tfidf_matrix.each_with_index do |row, index|
      row_vector = Vector.elements(row)
      cos = row_vector.inner_product(input_vector) / (row_vector.norm * input_vector.norm)
      result[index] = cos
    end
    # 降順ソート
    result.sort_by { |k, v| -v }.to_h
  end

end


