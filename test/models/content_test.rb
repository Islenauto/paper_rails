# == Schema Information
#
# Table name: contents
#
#  id         :integer          not null, primary key
#  sentence   :text
#  article_id :integer
#  created_at :datetime
#  updated_at :datetime
#

require 'test_helper'

class ContentTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
