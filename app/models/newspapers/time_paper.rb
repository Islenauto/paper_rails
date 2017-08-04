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

class TimePaper < Newspaper
  # RSSのリンク一覧から各記事データを取得
  def scrap_articles
    super
  end

  # 記事一覧があるRSSリンク
  def article_rss
    {
      'science' => 'http://feeds2.feedburner.com/time/scienceandhealth',
      'ecocentric' => 'http://feeds2.feedburner.com/timeblogs/ecocentric',
      'world' => 'http://feeds2.feedburner.com/time/world',
      'grobal spin' => 'http://feeds2.feedburner.com/timeblogs/globalspin',
      'moneyland' => 'http://moneyland.time.com/feed/rss/',
      'the curious capitalist' => 'http://feeds2.feedburner.com/timeblogs/curious_capitalist',
      'business' => 'http://feeds2.feedburner.com/time/business',
      'techland' => 'http://techland.time.com/feed/',
      'entertainment' => 'http://feeds2.feedburner.com/time/entertainment',
      # 'tuned in' => 'http://feeds2.feedburner.com/time/tunedin'
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
    sentence_arr = mechanize.search('section.article-body h2, section.article-body p').map { |paragraph| paragraph.text }
    return sentence_arr if sentence_arr.present?
  end

  def scrap_timestamp(mechanize)
    begin
      date = mechanize.search('time.modified-date')[0].attributes['datetime'].value.to_date
    rescue
      date = mechanize.search('time.modified-date').text.to_date
    end
    return date if date.present?
    begin
      date = mechanize.search('.publish-date')[0].attributes['datetime'].value.to_date
    rescue
      return nil
    end
    return date if date.present?
  end

  def scrap_title(mechanize)
    title = mechanize.search('h2.article-title').text
    return title if title.present?
    title = mechanize.search('h1.article-title').text
    return title if title.present?
  end

  def scrap_category(mechanize)
    nil
  end

  def scrapeable?(mechanize, category)
    super(mechanize, category)
  end
end
