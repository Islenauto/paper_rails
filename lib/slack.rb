# -*- coding: utf-8 -*-
module Slack
  # slackに与えるparamsを生成
  def self.hash_params()
    {
      username: '',
      icon_emoji: '',
      attachments: [
        {
          fallback: '',
          color: 'good',
          pretext: '',
          fields: [
            {
              title: '',
              value: '',
              short: false
            }
          ]
        }
      ]
    }
  end

  # 成功時のparamsを生成
  def self.success_params(start_time, end_time)
    newspapers = Newspaper.all
    value = newspapers.map(&:name).join(", ") + "\n"
    value += newspapers.map(&:articles).map(&:size).join(", ")
    pretext = ""
    if start_time.present? && end_time.present?
      pretext += start_time.strftime("%F %T")
      pretext += " ~ "
      pretext += end_time.strftime("%T")
    else
      pretext = "定期:収集 #{Time.now.strftime('%F %T')}"
    end
    params = hash_params()
    params[:username] = '[新聞収集] 完了だよ'
    params[:icon_emoji] = ':envelope_with_arrow:'
    params[:attachments][0][:fallback] = '定期:収集'
    params[:attachments][0][:color] = 'good'
    params[:attachments][0][:pretext] = pretext
    params[:attachments][0][:fields][0][:title] = '収集結果'
    params[:attachments][0][:fields][0][:value] = value
    params
  end

  # スクレイピング終了時に失敗した件数を生成
  def self.failure_article_params(failure_articles)
    pretext = ""
    value = ""
    newspapers = Newspaper.all

    value = newspapers.map(&:name).join(", ") + "\n"
    newspapers.map(&:name).each do |name|
      count = 0
      if failure_articles[name].nil?
        value += "0,"
        next
      end
      failure_articles[name].values.each do |failure_list|
        count += failure_list.size
      end
      value += "#{count},"
    end

    # failure_articles.each do |k, v|
    #   count = 0
    #   value += "#{k}:"
    #   v.values.each do |failure_list|
    #     count += failure_list.size
    #   end
    #   value += "#{count}\r\n"
    # end

    params = hash_params()
    params[:username] = '[新聞収集] 失敗した記事情報'
    params[:icon_emoji] = ':envelope_with_arrow:'
    params[:attachments][0][:fallback] = '定期:収集'
    params[:attachments][0][:color] = 'good'
    params[:attachments][0][:pretext] = pretext
    params[:attachments][0][:fields][0][:title] = '収集結果'
    params[:attachments][0][:fields][0][:value] = value
    params
  end

  # エラー発生時のparamsを生成
  def self.failure_params(e)
    pretext = "失敗 #{Time.now.strftime('%F %T')}"
    value = "#{e.message}\n#{e.backtrace[0]}"
    params = hash_params()
    params[:username] = '[新聞収集] 失敗だよ'
    params[:icon_emoji] = ':no_entry_sign:'
    params[:attachments][0][:fallback] = '定期:収集'
    params[:attachments][0][:color] = 'danger'
    params[:attachments][0][:pretext] = pretext
    params[:attachments][0][:fields][0][:title] = 'エラー発生'
    params[:attachments][0][:fields][0][:value] = value
    params
  end

  # slackへメッセージを送る
  def self.send_message(params)
    return false if ENV['SLACK_URL'].nil?
    slack_url = ENV['SLACK_URL']
    uri = URI.parse("https://hooks.slack.com/services/#{slack_url}")
    response = Net::HTTP.post_form(uri, payload: params.to_json)
    response
  end

  # scrapping開始時のメッセージ
  def self.notice_start_scrapping()
    params = hash_params()
    params[:username] = '[新聞収集] 開始だよ'
    params[:icon_emoji] = ':squirrel:'
    params[:attachments][0][:fallback] = '定期:収集'
    params[:attachments][0][:color] = '#439FE0'
    params[:attachments][0][:pretext] = ''
    params[:attachments][0][:fields][0][:title] = "開始だよ #{Time.now.strftime('%F %T')}"
    params[:attachments][0][:fields][0][:value] = ''
    send_message(params)
  end

  # scrappingの結果を送信する
  def self.notice_scrapping_result(start_time = nil, end_time = nil, e = nil, failure_articles = nil)
    params = e.nil? ? success_params(start_time, end_time) : failure_params(e)
    if e.nil?
      send_message(failure_article_params(failure_articles))
    end
    send_message(params)
  end
end
