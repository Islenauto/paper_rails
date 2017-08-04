# -*- coding: utf-8 -*-
class WordAggregate

  # DBに存在しなかった単語を集めたファイルを作る
  def self.aggregate_notexist_word(s_date = nil, e_date = nil)
    words = {}
    db_word = EnglishWord.convert_hash
    Article.where("opend_at >= '#{s_date}' and opend_at <= '#{e_date}'").each do |article|
      analysis_content = article.analysis_content
      next if analysis_content.nil? || analysis_content.content.blank?
      analysis_content.content_arr_flatten.uniq.each do |word_info|
        if word_info[0].nil? || word_info[2].nil?
          next
        end
        if db_word[word_info[0]].present? || db_word[word_info[2]].present?
          next
        end
        if db_word[word_info[0].downcase].present? || db_word[word_info[2].downcase].present?
          next
        end
        # カンマ等はカウントしない
        next if unnecessary_word?(word_info[0])
        next unless is_word?(word_info[0])
        # if EnglishWord.find_by(spell: word_info[0]).present? || EnglishWord.find_by(spell: word_info[2]).present? || word_info[0].nil? || word_info[2].nil?
        #   next
        # end
        # if EnglishWord.find_by(spell: word_info[0].downcase).present? || EnglishWord.find_by(spell: word_info[2].downcase).present?
        #   next
        # end
        words["#{word_info[0]}\t#{word_info[1]}\t#{word_info[2]}"] ||= 0
        words["#{word_info[0]}\t#{word_info[1]}\t#{word_info[2]}"] += 1
      end
    end
    File.open("data/DBに存在しない単語.csv", "w") do |file|
      words.each do |key, value|
        file.puts("#{key}\t#{value}")
      end
    end
  end


  # 新聞記事に含まれる単語の中で辞書の中に存在する単語の個数を集計
  # 辞書に含まれない単語については、個数を出力
  # ex. WordAggregate.aggregate_englishword("2015/1/12", "2015/2/3")
  def self.aggregate_englishword(s_date = nil, e_date = nil)
    date_query = generate_date_query(s_date, e_date)
    file = File.open("data/出現単語_難易度別.csv", "w")
    words = EnglishWord.convert_hash
    n_count = 0 # 辞書データに存在しない単語の個数
    # 出力用の配列
    english_words = {}
    words.each { |key, value| english_words[key] = [value, 0] }
    p date_query
    analysis_contents = date_query.empty? ? AnalysisContent.all : AnalysisContent.joins(:article).where("#{date_query}")
    # 解析済みデータを順に回す
    analysis_contents.each do |analysis_content|
      # 出現単語を順に回す
      analysis_content.content_arr_flatten.uniq.each do |words_info|
        # 単語が存在しない場合はスキップ
        next if words_info[0].nil?
        # 存在する場合は個数をカウント
        if english_words[words_info[0]].present?
          english_words[words_info[0]][1] += 1
          next
        end
        # 小文字での検索
        if english_words[words_info[0].downcase].present?
          english_words[words_info[0].downcase][1] += 1
          next
        end
        # 単語が存在しない場合はスキップ
        next if words_info[2].nil?
        # 存在する場合は個数をカウント
        if english_words[words_info[2]].present?
          english_words[words_info[2]][1] += 1
          next
        end
        # 小文字での検索
        if english_words[words_info[2].downcase].present?
          english_words[words_info[2].downcase][1] += 1
          next
        end
        # カンマ等はカウントしない
        next if unnecessary_word?(words_info[0])
        next unless is_word?(words_info[0])
        # DBになかった単語のカウント
        n_count += 1
      end
    end
    file.puts "単語, SVL, 回数"
    english_words.each do |key, value|
      file.puts "#{key}, #{value[0]}, #{value[1]}"
    end
    file.puts n_count
    file.close
  end

  # dateの指定により適したqueryを生成
  def self.generate_date_query(s_date, e_date)
    date_query = ""
    date_query = "articles.opend_at >= '#{s_date}'" unless s_date.nil?
    unless e_date.nil?
      if date_query.empty?
        date_query = "articles.opend_at <= '#{e_date}'"
      else
        date_query += " and  articles.opend_at <= '#{e_date}'"
      end
    end
    date_query
  end

  # 不要語
  def self.unnecessary_word?(word)
    unn_word = [',', '.', "'s", "n't"]
    unn_word.include?(word)
  end

  # 英単語もしくは数値が含まれているかどうか
  def self.is_word?(word)
    /[a-zA-Z0-9]/ === word
  end
end
