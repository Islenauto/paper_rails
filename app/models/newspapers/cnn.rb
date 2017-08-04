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
# 実行方法 Cnn.first.scrap_articles
class Cnn < Newspaper
  # RSSのリンク一覧から各記事データを取得
  def scrap_articles
    super
  end

  # 記事一覧があるRSSリンク
  def article_rss
    {
      'World' => 'http://rss.cnn.com/rss/edition_world.rss',
      'World Sport' => 'http://rss.cnn.com/rss/edition_sport.rss',
      'Money' => 'http://rss.cnn.com/rss/money_news_international.rss',
      'Science Space' => 'http://rss.cnn.com/rss/edition_space.rss',
      'Technology' => 'http://rss.cnn.com/rss/edition_technology.rss',
      'Entertainment' => 'http://rss.cnn.com/rss/edition_entertainment.rss'
    }
  end

  # RSSにある記事へのURLを取得
  def page_links(rss_link)
    super(rss_link)
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
    sentence_arr = mechanize.search('p.zn-body__paragraph').map { |paragraph| paragraph.text }
    return sentence_arr if sentence_arr.present?
    sentence_arr = mechanize.search('p').map { |paragraph| paragraph.text }
    if tags[0] == 'Money' || tags[1] == 'news'
      sentence_arr.unshift(mechanize.search('h2').text)
    end
    return sentence_arr if sentence_arr.present?
  end

  def scrap_timestamp(mechanize)
    date = mechanize.search('p.update-time').text.to_date
    return date if date.present?
    date = mechanize.search('.cnn_strytmstmp').text.to_date
    return date if date.present?
    date = mechanize.search('p.metadata__data-added').text.to_date
    return date if date.present?
    date = mechanize.search('.cnnDateStamp').text.to_date
    return date if date.present?
    date = mechanize.search('#cnnTimeStamp').text.scan(/\[.*\]/).join.to_date
    return date if date.present?
    date = mechanize.uri.to_s.to_date
    return date if date.present?
  end

  def scrap_title(mechanize)
    title = mechanize.search('h2.pg-headline').text
    return title if title.present?
    title = mechanize.search('h1').text
    return title if title.present?
  end

  def scrap_category(mechanize)
    mechanize.uri.to_s.split('/')[6]
  end

  def scrapeable?(mechanize, category)
    return false if mechanize.uri.to_s.split('/')[3] == 'videos'
    return false if mechanize.uri.to_s.split('/')[7] == 'gallery'
    return false if category.nil?
    true
  end
end
