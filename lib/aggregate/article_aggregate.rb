# -*- coding: utf-8 -*-
class ArticleAggregate
  # 新聞社別のカテゴリ別の集計
  def self.aggregate_newspaper_and_category
    file = File.open("data/新聞社カテゴリ別の集計.csv", "w")
    output_text = "新聞社, カテゴリ, 件数, CLI_AVE, CLI_VAR, FKG_AVE, FKG_VAR"
    output_text += ", SVL_AVE_AVE, SVL_AVE_VAR, TOEIC_AVE_AVE, TOEIC_AVE_VAR"
    output_text += ", SVLの平均単語数, 平均単語数"
    file.puts output_text
    # 新聞社ごとに集計
    Newspaper.all.each do |newspaper|
      # 新聞社にあるtag(カテゴリ)情報を取得
      tags = newspaper.articles.pluck(:tags).uniq
      # tag(カテゴリ)ごとに集計
      tags.each do |tag|
        output_text = "#{newspaper.name}"
        output_text += ", #{tag.to_s.gsub(/\"|,|\[|\]/, "")}"
        # ArticleInfoの中から 条件に合うものを抽出
        article_infos = ArticleInfo.includes(:article).where(articles: {newspaper_id: newspaper.id, tags: tag.to_yaml})
        output_text += ", #{article_infos.count}"
        output_text += ", #{article_infos.pluck(:cli).average}, #{article_infos.pluck(:cli).variance}"
        output_text += ", #{article_infos.pluck(:fkg).average}, #{article_infos.pluck(:fkg).variance}"
        output_text += ", #{article_infos.pluck(:svl_average).average}, #{article_infos.pluck(:svl_average).variance}"
        output_text += ", #{article_infos.pluck(:toeic_average).average}, #{article_infos.pluck(:toeic_average).variance}"
        output_text += ", #{article_infos.pluck(:svl_count).average}, #{article_infos.pluck(:word_count).average}"
        file.puts output_text
      end
    end
    file.close
  end

  # 統一カテゴリ別の集計
  def self.aggregate_category(s_date = nil, e_date = nil)
    date_query = generate_date_query(s_date, e_date)
    # 出力用ファイル
    file = File.open("data/カテゴリ別の集計.csv", "w")
    output_text = "カテゴリ, 件数, CLI_AVE, CLI_VAR, FKG_AVE, FKG_VAR"
    output_text += ", SVL_AVE_AVE, SVL_AVE_VAR, TOEIC_AVE_AVE, TOEIC_AVE_VAR"
    output_text += ", SVLの平均単語数, 平均単語数"
    # ファイルへの書き込み
    file.puts output_text
    # カテゴリの一覧を取得
    categories = Article.pluck(:category).uniq
    # カテゴリ毎に集計
    categories.each do |category|
      output_text = "#{category}"
      query = date_query.empty? ? "articles.category = '#{category}'" : "articles.category = '#{category}' and #{date_query}"
      next if category.nil?
      # ArticleInfoの中から 条件に合うものを抽出
      article_infos = ArticleInfo.joins(:article).where(query)
      output_text += ", #{article_infos.count}"
      output_text += ", #{article_infos.pluck(:cli).average}, #{article_infos.pluck(:cli).variance}"
      output_text += ", #{article_infos.pluck(:fkg).average}, #{article_infos.pluck(:fkg).variance}"
      output_text += ", #{article_infos.pluck(:svl_average).average}, #{article_infos.pluck(:svl_average).variance}"
      output_text += ", #{article_infos.pluck(:toeic_average).average}, #{article_infos.pluck(:toeic_average).variance}"
      output_text += ", #{article_infos.pluck(:svl_count).average}, #{article_infos.pluck(:word_count).average}"
      file.puts output_text
    end
    file.close
  end

  # リーダビリティ値別カテゴリ別の集計
  # 引数として開始日，終了日を指定
  def self.aggregate_readability_and_category(s_date = nil, e_date = nil)
    date_query = generate_date_query(s_date, e_date)
    file = File.open("data/リーダビリティ値・カテゴリ別の集計.csv", "w")
    file.puts "#{s_date} ~ #{e_date}"
    # リーダビリティ毎に集計
    ['cli', 'ari', 'fkg'].each do |readability|
      file.puts readability
      # タイトル部の出力
      output_text = "カテゴリ"
      (1..14).each { |num| output_text += ", #{num}" }
      file.puts output_text
      # カテゴリの一覧を取得
      categories = Article.pluck(:category).uniq
      # カテゴリ毎に集計
      categories.each do |category|
        output_text = "#{category}"
        query = date_query.empty? ? "articles.category = '#{category}'" : "articles.category = '#{category}' and #{date_query}"
        next if category.nil?
        # ArticleInfoの中から カテゴリに該当するものを取得
        article_infos = ArticleInfo.joins(:article).where(query)
        # リーダビリティによる集計結果を結合
        output_text += aggregate_readability(article_infos, readability)
        file.puts output_text
      end
    end
    file.close
  end

  # リーダビリティ値別新聞社別の集計
  def self.aggregate_readability_and_newspaper
    file = File.open("data/リーダビリティ値・新聞社別の集計.csv", "w")
    # リーダビリティ毎に集計
    ['cli', 'ari', 'fkg'].each do |readability|
      file.puts readability
      # タイトル部の出力
      output_text = "新聞社"
      (1..14).each { |num| output_text += ", #{num}" }
      file.puts output_text
      # 新聞社毎に集計
      Newspaper.all.each do |newspaper|
        output_text = "#{newspaper.name}"
        # ArticleInfoの中から 新聞社に該当するものを取得
        article_infos = ArticleInfo.includes(:article).where(articles: {newspaper_id: newspaper.id})
        # リーダビリティによる集計結果を結合
        output_text += aggregate_readability(article_infos, readability)
        file.puts output_text
      end
    end
    file.close
  end

  # 新聞記事に含まれる単語の中で辞書の中に存在する単語の個数を集計
  # 辞書に含まれない単語については、個数を出力
  def self.aggregate_englishword
    file = File.open("data/出現単語.csv", "w")
    words = EnglishWord.convert_hash
    n_count = 0 # 辞書データに存在しない単語の個数
    # 出力用の配列
    english_words = {}
    words.each { |key, value| english_words[key] = [value, 0] }
    # 解析済みデータを順に回す
    AnalysisContent.all.each do |analysis_content|
      # 出現単語を順に回す
      analysis_content.content_arr_flatten.each do |words_info|
        # 単語が存在しない場合はスキップ
        next if words_info[0].nil?
        # 存在する場合は個数をカウント
        if english_words[words_info[0]].present?
          english_words[words_info[0]][1] += 1
          next
        end
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
        if english_words[words_info[2].downcase].present?
          english_words[words_info[2].downcase][1] += 1
          next
        end
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

  # 補助関数
  # ArticleInfo を 指定された readability で集計
  def self.aggregate_readability(article_infos, readability)
    output_text = ""
    # 値別に集計
    (1..14).each do |num|
      if num == 1
        count = article_infos.where("#{readability} < #{num+1}").count
      elsif num == 14
        count = article_infos.where("#{readability} >= #{num}").count
      else
        count = article_infos.where("#{readability} >= #{num} AND #{readability} < #{num+1}").count
      end
      output_text += ", #{count}"
    end
    output_text
  end

  # dateの指定により適したqueryを生成
  def self.generate_date_query(s_date, e_date)
    date_query = ""
    date_query = "articles.opend_at >= \"#{s_date}\"" unless s_date.nil?
    unless e_date.nil?
      if date_query.empty?
        date_query = "articles.opend_at <= \"#{e_date}\""
      else
        date_query += " and  articles.opend_at <= \"#{e_date}\""
      end
    end
    date_query
  end
end
