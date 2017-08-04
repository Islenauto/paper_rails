class ArticlesController < ApplicationController
  before_action :authenticate_user!
  before_action :load_article, :only => [:show]

  def show
    @user_article = UserArticle.find_by(article_id: @article.id, user_id: current_user.id)
    @user_article = UserArticle.create(article_id: @article.id, user_id: current_user.id) if @user_article.nil?
  end

  def load_article
    return unless params[:id]
    @article = Article.find_by(id: params[:id])
    @article = ArticleDecorator.new(@article)
  end
end
