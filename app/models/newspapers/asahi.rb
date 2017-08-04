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

class Asahi < Newspaper
  def scrap_articles
    failure_articles = {}
    article_links.each do |key, value|
      create_links(value, 2).each do |link|
        links = page_links(link)
        failure_articles[link] = scrap_links_article(links, key) unless links.blank?
      end
    end
    failure_articles
  end

  # 記事一覧があるRSSリンク
  def article_rss
  end

  # 記事一覧があるリンク
  def article_links
    {
      'science' => 'http://ajw.asahi.com/category/sci_tech/science/',
      'technology' => 'http://ajw.asahi.com/category/sci_tech/technology/',
      'business' => 'http://ajw.asahi.com/category/business/',
      'sports' => 'http://ajw.asahi.com/category/behind_news/sports/',
      # world?
      'chaina' => 'http://ajw.asahi.com/category/asia/china/',
      'korean' => 'http://ajw.asahi.com/category/asia/korean_peninsula/',
      'around_asia' => 'http://ajw.asahi.com/category/asia/around_asia/',
      # エンタメ?
      'style' => 'http://ajw.asahi.com/category/cool_japan/style/',
      'fun spots' => 'http://ajw.asahi.com/category/cool_japan/fun_spots/',
      'anime_news' => 'http://ajw.asahi.com/category/cool_japan/anime_news/',
      'movies' => 'http://ajw.asahi.com/category/cool_japan/movies/'
    }
  end

  # 指定回数だけリンクを増やす
  def create_links(url, count)
    (1..count).map { |num| "#{url}?page=#{num}" }
  end

  # 記事へのURLを取得
  def page_links(link)
    mechanize =  get_html(link)
    mechanize.search('.article_title').map do |title|
      url + title.children[0].attributes['href'].text
    end
  end

  # リンクに応じて処理を振り分けて記事を取得
  def scrap_links_article(links, title)
    super(links, title)
  end

  # articleの登録を行う
  def regist_article(article_hash, sentence_arr)
    super(article_hash, sentence_arr)
  end

  # 記事があるリンクから記事情報を取得し保存
  def scrap_article(mechanize, tags)
    super(mechanize, tags)
  end

  def scrap_sentence(mechanize, tags)
    sentence_arr = mechanize.search('#article > .body > .text > p').map { |paragraph| paragraph.text }
    return sentence_arr if sentence_arr.present?
  end

  def scrap_timestamp(mechanize)
    date = mechanize.search('#article > .meta > .date').text.to_date
    return date if date.present?
  end

  def scrap_title(mechanize)
    title = mechanize.search('#article_head > h1').text
    return title if title.present?
  end

  def scrap_category(mechanize)
    nil
  end

  def scrapeable?(mechanize, category)
    super(mechanize, category)
  end
end
