# -*- coding: utf-8 -*-
# == Schema Information
#
# Table name: newspapers
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  url        :string(255)
#  type       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

require 'mechanize'
require 'nokogiri'
require 'rss'

class Newspaper < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true

  has_many :articles
  has_many :contents, through: :articles
  has_many :article_infos, through: :articles

  @@agent = Mechanize.new
  def get_html(url)
    @@agent.get(url)
  end

  def scrap_articles
    failure_articles = {}
    article_rss.each do |key, value|
      links = page_links(value)
      if links.nil?
        failure_articles[value] = []
        next
      end
      failure_articles[value] = scrap_links_article(links, key)
      # failure_articles.push(scrap_links_article(links, key))
    end
    failure_articles
  end

  # 記事一覧があるRSSリンク
  def article_rss
  end

  # RSSにある記事へのURLを取得
  def page_links(rss_link)
    begin
      rss_data = RSS::Parser.parse(rss_link)
    rescue
      puts "parse error--------------------------------"
      puts "#{rss_link}, #{name}"
      puts "-------------------------------------------"
      return nil
    end
    rss_data.items.map { |item| item.link }
  end

  # リンクに応じて処理を振り分けて記事を取得
  def scrap_links_article(links, title)
    failure_articles = []
    links.each do |link|
      begin
        mechanize = get_html(link)
      rescue
        failure_articles.push(link)
        next
      end
      category = scrap_category(mechanize)
      article_hash = {}
      article_hash['category'] = category
      article_hash['link'] = link
      article_hash['url'] = mechanize.uri.to_s
      print_hash(article_hash)
      unless scrapeable?(mechanize, category)
        failure_articles.push(mechanize.uri.to_s)
        sleep(4)
        next
      end
      result = scrap_article(mechanize, [title]) if category.nil?
      result = scrap_article(mechanize, [title, category]) unless category.nil?
      failure_articles.push(mechanize.uri.to_s) if result.blank?
      sleep(4)
    end
    failure_articles
  end

  # articleの登録を行う
  def regist_article(article_hash, sentence_arr)
    article = articles.find_by(url: article_hash['url'])
    article = articles.new if article.blank?
    article.title = article_hash['title']
    article.url = article_hash['url']
    article.tags = article_hash['tags']
    article.day = article_hash['date'].day
    article.month = article_hash['date'].month
    article.year = article_hash['date'].year
    article.opend_at = article_hash['date']
    # < > を全角に変更
    sentence_arr = sentence_arr.map { |sentence| sentence.gsub(/</, "＜").gsub(/>/, "＞") }
    sentence = sentence_arr.join('<br>').sub_Em
    return false if sentence.blank?
    return false if article.title.blank?
    Article.regist(article, sentence)
  end

  # 記事があるリンクから記事情報を取得し保存
  def scrap_article(mechanize, tags)
    sentence_arr = scrap_sentence(mechanize, tags)
    # p sentence_arr
    return false if sentence_arr.blank?
    article_hash = {}
    article_hash['date'] = scrap_timestamp(mechanize)
    article_hash['title'] = scrap_title(mechanize)
    article_hash['url'] = mechanize.uri.to_s
    article_hash['tags'] = tags
    if article_hash['date'].blank? || article_hash['title'].blank? || article_hash['url'].blank?
      return nil
    end
    regist_article(article_hash, sentence_arr)
  end

  def scrap_sentence(mechanize, tags)
  end

  def scrap_timestamp(mechanize)
  end

  def scrap_title(mechanize)
  end

  def scrap_category(mechanize)
  end

  def scrapeable?(mechanize, category)
    true
  end
  # デバッグ用の関数
  def print_hash(hash)
  end

  # 新聞社ごとのリーダビリティの平均と分散をファイルに出力
  def self.output_readalibity
    File.open("data/output_readability.csv", "w") do |file|
      file.print("新聞社, ARI_AVE, ARI_VAR, CLI_AVE, CLI_VAR, FKG_AVE, FKG_VAR, TOEIC_AVE, TOEIC_SD_AVE, SVL_AVE, SVL_AVE_VAR, SVL_SD_AVE\n")
      all.each do |newspaper|
        file.print("#{newspaper.type}, #{newspaper.article_infos.pluck(:ari).average}, #{newspaper.article_infos.pluck(:ari).variance}")
        file.print(",#{newspaper.article_infos.pluck(:cli).average}, #{newspaper.article_infos.pluck(:cli).variance}")
        file.print(",#{newspaper.article_infos.pluck(:fkg).average}, #{newspaper.article_infos.pluck(:fkg).variance}")
        file.print(",#{newspaper.article_infos.pluck(:toeic_average).average}, #{newspaper.article_infos.pluck(:toeic_variance).map{|a| Math.sqrt(a)}.average}")
        svl_sds = newspaper.article_infos.pluck(:svl_variance).map { |a| Math.sqrt(a) }
        file.print(",#{newspaper.article_infos.pluck(:svl_average).average}, #{newspaper.article_infos.pluck(:svl_average).variance}, #{svl_sds.average}")
        file.puts("")
      end
    end
  end
end
