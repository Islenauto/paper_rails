class UserArticlesController < ApplicationController
  def regist_read_status
    user_article = UserArticle.find_by(user_id: current_user.id, article_id: params[:article_id])
    if user_article.blank?
      user_article = UserArticle.new(user_id: current_user.id, article_id: params[:article_id], read_status: params[:read_status])
    else
      user_article.read_status = params[:read_status]
    end
    if user_article.save
      render json: { status: 'success', read_status: user_article.read_status }
    else
      render json: { status: 'error' }
    end
  end
end
