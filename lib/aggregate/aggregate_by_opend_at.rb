module AggregateByOpendAt
  class << self
    # 新聞社別記事件数集計
    def aggregate_by_newspaper
      aggregate_data = {}
      Newspaper.all.each do |newspaper|
        output_as_csv("#{newspaper.type}_article_number_of_each_day.csv", aggregate_by_opend_at(newspaper.articles.order(:opend_at)))
      end
    end

    # 日付別記事件数集計
    def aggregate_by_opend_at(articles)
      hash = Hash.new(0)
      articles.each do |article|
        hash[article.opend_at] += 1
      end
      hash
    end

    def output_as_csv(file_name = 'article_number_of_each_day.csv', hash)
      File.open(file_name, 'w') do |f|
        hash.each do |key, value|
          f.puts "#{key}, #{value}"
        end
      end
    end
  end
end
