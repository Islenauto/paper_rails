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

class Mainichi < Newspaper
  def scrap_articles
    failure_articles = {}
    article_links.each do |key, value|
      links = page_links(value, key)
      failure_articles[value] = scrap_links_article(links, key) unless links.blank?
    end
    failure_articles
  end

  # 記事一覧があるRSSリンク
  def article_rss
  end

  # 記事一覧があるリンク
  def article_links
    {
      'world' => 'http://mainichi.jp/english/world/1',
      'business' => 'http://mainichi.jp/english/business/1',
      'sports' => 'http://mainichi.jp/english/sports/1',
      'arts entertainment' => 'http://mainichi.jp/english/entertainment/1'
    }
  end

  # 記事へのURLを取得
  def page_links(link, key)
    mechanize = get_html(link)
    mechanize.search("ul.list-typeA > li > a").map { |title| "http://mainichi.jp" + title.attributes['href'].value }
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
    sentence_arr = mechanize.search('.main-text > p.txt').map { |paragraph| paragraph.text}
    return sentence_arr if sentence_arr.present?
  end

  def scrap_timestamp(mechanize)
    date = mechanize.search('p.post').children.children.text.to_date
    return date if date.present?
  end

  def scrap_title(mechanize)
    title = mechanize.search('h1').text
    return title if title.present?
  end

  def scrap_category(mechanize)
    nil
  end

  def scrapeable?(mechanize, category)
    super(mechanize, category)
  end
end
