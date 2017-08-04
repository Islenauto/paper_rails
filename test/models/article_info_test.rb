# == Schema Information
#
# Table name: article_infos
#
#  id             :integer          not null, primary key
#  cpw            :float
#  wps            :float
#  ari            :float
#  cli            :float
#  article_id     :integer
#  created_at     :datetime
#  updated_at     :datetime
#  fkg            :float
#  svl_average    :float            default(0.0)
#  svl_variance   :float            default(0.0)
#  svl_count      :integer          default(0)
#  word_count     :integer          default(0)
#  toeic_average  :float            default(0.0)
#  toeic_variance :float            default(0.0)
#

require 'test_helper'

class ArticleInfoTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
