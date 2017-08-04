# -*- coding: utf-8 -*-
namespace :scrap_article do
  desc "新聞記事をスクレイピングして収集"

  task :scrapping => :environment do
    start_time = Time.now
    Slack::notice_start_scrapping()
    begin
      p Cnn.first.scrap_articles
    rescue => e
      Slack::notice_scrapping_result(nil, nil, e)
    end
    begin
      p Bbc.first.scrap_articles
    rescue => e
      Slack::notice_scrapping_result(nil, nil, e)
    end
    begin
      p Voa.first.scrap_articles
    rescue => e
      Slack::notice_scrapping_result(nil, nil, e)
    end
    begin
      p Thejapantimes.first.scrap_articles
    rescue => e
      Slack::notice_scrapping_result(nil, nil, e)
    end
    begin
      p Asahi.first.scrap_articles
    rescue => e
      Slack::notice_scrapping_result(nil, nil, e)
    end
    begin
      p Mainichi.first.scrap_articles
    rescue => e
      Slack::notice_scrapping_result(nil, nil, e)
    end
    begin
      p NewYorkTimes.first.scrap_articles
    rescue => e
      Slack::notice_scrapping_result(nil, nil, e)
    end
    begin
      p TimePaper.first.scrap_articles
    rescue => e
      Slack::notice_scrapping_result(nil, nil, e)
    end
    end_time = Time.now
    if ENV['SLACK_URL'].present?
      Slack::notice_scrapping_result(start_time, end_time)
    end
  end
  task :run_multithread => :environment do
    start_time = Time.now
    failure_articles = {}
    Slack::notice_start_scrapping()
    Parallel.each(Newspaper.all, in_threads: 4) do |newspaper|
      next if newspaper.name == 'Asahi'
      #next if newspaper.name == 'TIME'
      puts "start: #{newspaper.name}"
      begin
        failure_articles[newspaper.name] =  newspaper.scrap_articles
        p failure_articles
      rescue => e
        Slack::notice_scrapping_result(nil, nil, e, nil)
      end
      puts "end: #{newspaper.name}"
    end
    end_time = Time.now
    if ENV['SLACK_URL'].present?
      Slack::notice_scrapping_result(start_time, end_time, nil, failure_articles)
    end
  end
  task :test => :environment do
    puts "test"
  end
end
