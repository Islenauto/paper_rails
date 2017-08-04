# == Schema Information
#
# Table name: analysis_contents
#
#  id         :integer          not null, primary key
#  content    :text
#  article_id :integer
#  created_at :datetime
#  updated_at :datetime
#

require 'test_helper'

class AnalysisContentTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
