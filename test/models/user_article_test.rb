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

require 'test_helper'

class UserArticleTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
