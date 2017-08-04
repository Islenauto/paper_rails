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

class Content < ActiveRecord::Base
  belongs_to :article
end
