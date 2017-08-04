# == Schema Information
#
# Table name: english_words
#
#  id           :integer          not null, primary key
#  spell        :text
#  syllable_num :integer
#  created_at   :datetime
#  updated_at   :datetime
#

require 'test_helper'

class EnglishWordTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
