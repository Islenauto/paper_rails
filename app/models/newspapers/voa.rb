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

class Voa < Newspaper
  def scrap_articles
    super
  end

  # 記事一覧があるRSSリンク
  def article_rss
    {
      "USA" => 'http://www.voanews.com/api/zq$omekvi_',
      "Africa" => 'http://www.voanews.com/api/z-$otevtiq',
      "Asia" => 'http://www.voanews.com/api/zo$o_egviy',
      "Middle East" => 'http://www.voanews.com/api/zr$opeuvim',
      "Europe" => 'http://www.voanews.com/api/zj$oveytit',
      "Science Technology" => 'http://www.voanews.com/api/zyritequir',
      "Economy" => 'http://www.voanews.com/api/zy$oqeqtii',
      "Arts Entertainment" => 'http://www.voanews.com/api/zp$ove-vir'
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
    sentence_arr = mechanize.search('.articleContent p').map { |paragraph| paragraph.text }
    return sentence_arr if sentence_arr.present?
    sentence_arr = mechanize.search('.wysiwyg p').map { |paragraph| paragraph.text }
    return sentence_arr if sentence_arr.present?
  end

  def scrap_timestamp(mechanize)
    date = mechanize.search('p.article_date').text.to_date
    return date if date.present?
    date = mechanize.search('.publishing-details > .published span.date > time').text.to_date
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
    url_arr = mechanize.uri.to_s.split('/')
    return false if url_arr[4] == 'video' && url_arr[3] == 'media'
    true
  end
end
