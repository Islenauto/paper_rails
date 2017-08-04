# == Schema Information
#
# Table name: word_infos
#
#  id              :integer          not null, primary key
#  svl_level       :integer
#  weblio_level    :integer
#  weblio_toeic    :integer
#  english_word_id :integer
#  created_at      :datetime
#  updated_at      :datetime
#

require 'test_helper'

class WordInfoTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
