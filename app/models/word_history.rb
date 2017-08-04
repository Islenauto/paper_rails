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

class WordHistory < ActiveRecord::Base
  belongs_to :user
  belongs_to :english_word
end
