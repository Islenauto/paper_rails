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

class Thejapantimes < Newspaper
  def scrap_articles
    super
  end

  # 記事一覧があるRSSリンク
  def article_rss
    {
      'world' => 'http://www.japantimes.co.jp/news_category/world/feed/',
      'business' => 'http://www.japantimes.co.jp/news_category/business/feed/',
      'sport' => 'http://www.japantimes.co.jp/sports/feed/',
      'science-health' => 'http://www.japantimes.co.jp/news_category/science-health/feed/',
      'tech' => 'http://www.japantimes.co.jp/news_category/tech/feed/',
      'entertainment' => 'http://www.japantimes.co.jp/culture_category/entertainment-news/feed/'
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
    sentence_arr = mechanize.search('.entry#jtarticle > p').map { |paragraph| paragraph.text }
    return sentence_arr if sentence_arr.present?
  end

  def scrap_timestamp(mechanize)
    date = mechanize.search('li.post_time > time').text.to_date
    return date if date.present?
  end

  def scrap_title(mechanize)
    title = mechanize.search('hgroup > h1').text
    return title if title.present?
  end

  def scrap_category(mechanize)
    nil
  end

  def scrapeable?(mechanize, category)
    super(mechanize, category)
  end
end
