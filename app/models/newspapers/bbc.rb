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
# 実行方法 Bbc.first.scrap_articles
class Bbc < Newspaper
  # RSSのリンク一覧から各記事データを取得
  def scrap_articles
    super
  end

  # 記事一覧があるRSSリンク
  def article_rss
    {
      'World' => 'http://newsrss.bbc.co.uk/rss/newsonline_uk_edition/world/rss.xml',
      'Sport' => 'http://newsrss.bbc.co.uk/rss/sportonline_uk_edition/front_page/rss.xml',
      'Business' => 'http://newsrss.bbc.co.uk/rss/newsonline_uk_edition/business/rss.xml',
      'Science Nature' => 'http://newsrss.bbc.co.uk/rss/newsonline_uk_edition/sci/tech/rss.xml',
      'Technology' => 'http://newsrss.bbc.co.uk/rss/newsonline_uk_edition/technology/rss.xml',
      'Entertainment' => 'http://newsrss.bbc.co.uk/rss/newsonline_uk_edition/entertainment/rss.xml'
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
    sentence_arr = mechanize.search('.story-body p').map { |paragraph| paragraph.text }
    return sentence_arr if sentence_arr.present?
    sentence_arr = mechanize.search('#emp-content p').map { |paragraph| paragraph.text }
    return sentence_arr if sentence_arr.present?
  end

  def scrap_timestamp(mechanize)
    date = mechanize.search('.story-date').text.to_date
    return date if date.present?
    date = mechanize.search('.page-timestamp').text.to_date
    return date if date.present?
    date = mechanize.search('p.date.date--v1').text.to_date
    return date if date.present?
    return nil if mechanize.search('.date.date--v2')[0].blank?
    date = mechanize.search('.date.date--v2')[0].text.to_date
    return date if date.present?
  end

  def scrap_title(mechanize)
    title = mechanize.search('h1.story-header').text
    return title if title.present?
    title = mechanize.search('h1.story-body__h1').text
    return title if title.present?
  end

  def scrap_category(mechanize)
    uri_arr = mechanize.uri.to_s.split(/[\/,-]/)
    return uri_arr[4] if uri_arr[3] == 'news'
    uri_arr[3]
  end

  def scrapeable?(mechanize, category)
    super(mechanize, category)
  end
end
