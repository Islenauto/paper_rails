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

class NewYorkTimes < Newspaper
  # RSSのリンク一覧から各記事データを取得
  def scrap_articles
    super
  end

  # 記事一覧があるRSSリンク
  def article_rss
    {
      'world' => 'http://rss.nytimes.com/services/xml/rss/nyt/World.xml',
      'business' => 'http://feeds.nytimes.com/nyt/rss/Business',
      'sports' => 'http://www.nytimes.com/services/xml/rss/nyt/Sports.xml',
      'science' => 'http://www.nytimes.com/services/xml/rss/nyt/Science.xml',
      'technology' => 'http://feeds.nytimes.com/nyt/rss/Technology'
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
    sentence_arr = mechanize.search('.story-content').map { |paragraph| paragraph.text }
    return sentence_arr if sentence_arr.present?
    sentence_arr = mechanize.search('.story-body-text').map { |paragraph| paragraph.text }
    return sentence_arr if sentence_arr.present?
  end

  def scrap_timestamp(mechanize)
    if mechanize.search('time.dateline').children.size > 1
      date = mechanize.search('time.dateline').children[0].text.to_date
      return date if date.present?
    end
    date = mechanize.search('time.dateline').text.to_date
    return date if date.present?
  end

  def scrap_title(mechanize)
    title = mechanize.search('h1#story-heading').text
    return title if title.present?
    title = mechanize.search('h1 > .entry-title').text
    return title if title.present?
    title = mechanize.search('h1#headline').text
    return title if title.present?
  end

  def scrap_category(mechanize)
    nil
  end

  def scrapeable?(mechanize, category)
    super(mechanize, category)
  end

  # デバッグ用の関数
  def print_hash(hash)
    # hash.each do |key, value|
    #   p key
    #   p value
    # end
  end
end
