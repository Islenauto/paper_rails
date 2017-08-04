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

require 'test_helper'

class ArticleHtmlTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
