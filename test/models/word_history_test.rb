# == Schema Information
#
# Table name: word_histories
#
#  id              :integer          not null, primary key
#  user_id         :integer
#  english_word_id :integer
#  is_known        :boolean
#  created_at      :datetime
#  updated_at      :datetime
#  spell           :text
#

require 'test_helper'

class WordHistoryTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
