# -*- coding: utf-8 -*-
# == Schema Information
#
# Table name: articles
#
#  id           :integer          not null, primary key
#  newspaper_id :integer
#  title        :string(255)
#  day          :integer
#  month        :integer
#  year         :integer
#  url_old      :string(255)
#  tags         :text
#  created_at   :datetime
#  updated_at   :datetime
#  url          :text
#  category     :string(255)
#  opend_at     :date
#  is_public    :boolean          default(FALSE), not null
#

ActiveSupport::Dependencies.require_or_load('config/initializers/tree_tagger.rb')
ActiveSupport::Dependencies.require_or_load('app/models/articles/analysis_content.rb')

class Article < ActiveRecord::Base
  has_many :user_articles, dependent: :destroy
  has_many :users, through: :user_articles
  has_one :content, dependent: :destroy
  has_one :article_info, dependent: :destroy
  has_one :analysis_content, dependent: :destroy
  has_one :article_html, dependent: :destroy
  belongs_to :newspaper

  validates :url, presence: true, uniqueness: true
  serialize :tags

  def self.all_category
    self.all.pluck(:category).uniq
  end

  # ソースコード(html)を取得し保存
  def regist_html
    body = Mechanize.new.get(url).body
    create_article_html(html: body) if body.present?
    sleep(4)
  end

  def self.regist(article, contents)
    article.save
    content = article.content
    result = article.create_content(sentence: contents) if content.blank?
    result = content.update(sentence: contents) unless content.blank?
    result
  end

  # 全ての記事をTreeTaggerで形態素解析
  # again_flag を trueにすると一度解析したものも再度解析する
  def self.regist_analysis_contents(again_flag = false)
    Parallel.each(all, in_threads: 4) do |article|
      ActiveRecord::Base.connection_pool.with_connection do
        article.regist_analysis(again_flag)
      end
    end
  end

  # TreeTaggerで形態素解析
  # again_flag を trueにすると一度解析したものも再度解析する
  def regist_analysis(again_flag = false)
    a = analysis_content
    # 既に解析済みのデータは解析しない
    return if again_flag == false && a.present? && a.content.present?
    # 形態素解析に不要な文字を空白に置換して<br>で分割
    content_arr = content.sentence.gsub(/"|\(|\)|{|}|\[|\]|-|:|`/, " ").split(/<br>/)
    # < > は解析の邪魔になるので空白に置換
    content_arr = content_arr.map { |sentence| sentence.gsub(/</, "＜").gsub(/>/, "＞") }
    result = content_arr.map { |text| TreeTagger.analysis(text) }
    # <br>の区切りごとにまとめる
    analysis_data = result.map { |res| res.join(" ") }.join("<br>")
    if a.nil?
      create_analysis_content(content: analysis_data)
      return
    end
    a.update(content: analysis_data)
  end

  # 記事の情報(wps, cpw)を一括登録
  def self.regist_article_info
    # all.each do |article|
    #   ArticleInfo.regist_sentence_info(article)
    # end
    Parallel.each(all, in_threads: 4) do |article|
      ActiveRecord::Base.connection_pool.with_connection do
        ArticleInfo.regist_sentence_info(article)
      end
    end
  end

  # 記事のSVLに関する情報を登録
  def self.regist_svl_info(flag = false)
    # all.each do |article|
    #   ArticleInfo.regist_sentence_info(article)
    # end
    Parallel.each(all, in_threads: 4) do |article|
      ActiveRecord::Base.connection_pool.with_connection do
        ArticleInfo.regist_svl_info(article, flag)
      end
    end
  end

  # 記事のTOEICに関する情報を登録
  def self.regist_toeic_info
    # all.each do |article|
    #   ArticleInfo.regist_sentence_info(article)
    # end
    Parallel.each(all, in_threads: 4) do |article|
      ActiveRecord::Base.connection_pool.with_connection do
        ArticleInfo.regist_toeic_info(article)
      end
    end
  end

  # 全ての記事の全角文字を一括で半角に置換
  def self.sub_Em
    all.each do |article|
      article_content = article.content
      article_content.sentence = NKF.nkf('-m0Z1 -w', article_content.sentence)
      article_content.save
    end
    # Parallel.each(all, in_threads: 4) do |article|
    #   ActiveRecord::Base.connection_pool.with_connection do
    #     article_content = article.content
    #     article_content.sentence = NKF.nkf('-m0Z1 -w', article_content.sentence)
    #     article_content.save
    #   end
    # end
  end

  # DBに存在しなかった単語を集めたファイルを作る
  def self.create_words_file
    words = {}
    Article.all.each do |article|
      next if article.analysis_content.nil? || article.analysis_content.content.blank?
      article.analysis_content.content_arr_flatten.each do |word_info|
        if EnglishWord.find_by(spell: word_info[0]).present? || EnglishWord.find_by(spell: word_info[2]).present? || word_info[0].nil? || word_info[2].nil?
          next
        end
        if EnglishWord.find_by(spell: word_info[0].downcase).present? || EnglishWord.find_by(spell: word_info[2].downcase).present?
          next
        end

        words["#{word_info[0]}\t#{word_info[1]}\t#{word_info[2]}"] ||= 0
        words["#{word_info[0]}\t#{word_info[1]}\t#{word_info[2]}"] += 1
      end
    end
    File.open("data/words_list.csv", "w") do |file|
      words.each do |key, value|
        file.puts("#{key}\t#{value}")
      end
    end
  end

  # 記事のカテゴリを登録
  # tagsの情報から[world, science, technology, business, sports, entertainment] の
  # どれかに分類する
  def regist_category
    # 1つ目のカテゴリの小文字を格納
    tag = self.tags[0].downcase
    self.category = "world" if Article.world_category.include?(tag)
    self.category = "science" if Article.science_category.include?(tag)
    self.category = "technology" if Article.technology_category.include?(tag)
    self.category = "business" if Article.business_category.include?(tag)
    self.category = "sports" if Article.sports_category.include?(tag)
    self.category = "entertainment" if Article.entertainment_category.include?(tag)
    self.save
  end

  # worldに分類されるtagを返却
  def self.world_category
    ["world", "europe", "usa", "asia", "middle east", "africa", "chaina",
     "korean", "around_asia", "grobal spin"]
  end

  # scienceに分類されるtagを返却
  def self.science_category
    ["science space", "science nature", "science-health", "science", "ecocentric"]
  end

  # technologyに分類されるtagを返却
  def self.technology_category
    ["technology", "tech", "techland"]
  end

  # businessに分類されるtagを返却
  def self.business_category
    ["business", "money", "economy", "moneyland", "the curious capitalist"]
  end

  # sportsに分類されるtagを返却
  def self.sports_category
    ["sports", "sport", "world sport"]
  end

  # entertainmentに分類されるtagを返却
  def self.entertainment_category
    ["arts entertainment", "arts entertainment2", "entertainment", "style", "fun spots",
     "anime_news", "movies", "tuned in"]
  end

  # すべてのユーザの既知単語割合を計算
  def regist_known_rates
    users = User.all
    users.each do |user|
      UserArticle.regist_known_rate(user, self)
    end
  end

  # スコープの指定
  scope :public_scope, -> (boolean=true) {
    if boolean
      includes(:article_info, :newspaper).where(is_public: true)
    else
      includes(:article_info, :newspaper)
    end
  }

  private
  def self.ransackable_scopes(auth_object=nil)
    %i(public_scope)
  end
end
