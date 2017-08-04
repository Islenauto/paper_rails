# -*- coding: utf-8 -*-
# == Schema Information
#
# Table name: user_articles
#
#  id              :integer          not null, primary key
#  user_id         :integer          not null
#  article_id      :integer          not null
#  read_status     :integer          default(0), not null
#  known_rate      :float            default(0.0), not null
#  recommend_point :integer          default(0), not null
#  created_at      :datetime
#  updated_at      :datetime
#

class UserArticle < ActiveRecord::Base
  belongs_to :user
  belongs_to :article

  READ_STATUS =  ['0%', '20%', '40%', '60%', '80%', '100%']

  # 既知単語の割合の計算
  # input: 対象の単語集合，ユーザの未知単語の集合
  def self.cluc_known_rate(words, unknown_words)
    uw_c = 0 # 記事中の知らない単語の数
    words.uniq.each do |word_info|
      # 本文の単語で比較
      if unknown_words.include?(word_info[0].downcase) || unknown_words.include?(word_info[0])
        uw_c += 1
        next
      end
      # 原型での比較
      if unknown_words.include?(word_info[2].downcase) || unknown_words.include?(word_info[2])
        uw_c += 1
        next
      end
    end
    (words.uniq.size - uw_c.to_f) / words.uniq.size
  end

  # 既知単語の割合を登録
  def self.regist_known_rate(user, article)
    user_article = find_by(article_id: article.id, user_id: user.id)
    if user_article.blank?
      user_article = UserArticle.new(article_id: article.id, user_id: user.id)
    end
    user_article.known_rate = cluc_known_rate(article.analysis_content.content_arr_flatten, user.unknown_words)
    user_article.save
  end
end
