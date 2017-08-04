# == Schema Information
#
# Table name: articles
#
#  id           :integer          not null, primary key
#  newspaper_id :integer
#  title        :string(255)
#  day          :integer
#  month        :integer
#  year         :integer
#  url_old      :string(255)
#  tags         :text
#  created_at   :datetime
#  updated_at   :datetime
#  url          :text
#  category     :string(255)
#  opend_at     :date
#  is_public    :boolean          default(FALSE), not null
#

require 'test_helper'

class ArticleTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
