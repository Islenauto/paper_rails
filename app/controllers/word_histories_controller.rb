class WordHistoriesController < ApplicationController
  def change_known
    change_known = WordHistory.find_by(user_id: current_user.id, spell: params[:word])
    if change_known.blank?
      change_known = WordHistory.new(user_id: current_user.id, spell: params[:word], is_known: false)
    else
      change_known.is_known = change_known.is_known == false ? true : false
    end
    if change_known.save
      render json: { status: 'success', is_known: "#{change_known.is_known}" }
    else
      render json: { status: 'error' }
    end
  end
end
