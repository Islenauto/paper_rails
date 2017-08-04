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

class WordInfo < ActiveRecord::Base
  belongs_to :english_word
end
