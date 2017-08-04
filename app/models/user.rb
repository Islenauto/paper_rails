# -*- coding: utf-8 -*-
# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#  toeic_score            :integer          default(0), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  is_admin               :boolean          default(FALSE), not null
#

class User < ActiveRecord::Base
  has_many :user_articles, dependent: :destroy
  has_many :articles, through: :user_articles
  has_many :word_histories
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  after_save :regist_known_rates

  # 未知の単語のリストを返却
  def unknown_words
    word_histories.where(is_known: false).pluck(:spell)
  end

  # 公開設定されている記事の既知単語割合を計算
  def regist_known_rates
    articles = Article.where(is_public: true)
    articles.each do |article|
      UserArticle.regist_known_rate(self, article)
    end
  end
end
