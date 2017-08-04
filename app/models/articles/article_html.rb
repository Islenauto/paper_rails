# == Schema Information
#
# Table name: article_htmls
#
#  id         :integer          not null, primary key
#  article_id :integer
#  html       :text
#  created_at :datetime
#  updated_at :datetime
#

class ArticleHtml < ActiveRecord::Base
  belongs_to :article
end
