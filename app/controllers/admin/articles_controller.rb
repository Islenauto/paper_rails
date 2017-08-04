class Admin::ArticlesController < ApplicationController
  before_action :authenticate_user!
  before_action :clear_search_index, :only => [:index]
  before_action :load_article, :only => [:show]
  before_action :admin_user

  def index
    @search = Article.includes(:article_info, :newspaper).search(search_params)
    @search.sorts = 'opend_at' if @search.sorts.empty?
    @articles = @search.result().page(params[:page])
  end

  def show
  end

  def toggle_public
    @article = Article.find_by(id: params[:article_id])
    @article.is_public = @article.is_public ? false : true
    if @article.save
      @article.regist_known_rates if @article.is_public
      render json: { status: 'success', id: @article.id }
    else
      render json: { status: 'error' }
    end
    # redirect_to admin_articles_path
  end

  def search_params
    params[:q]
  end

  def clear_search_index
    if params[:search_cancel]
      params.delete(:search_cancel)
      if(!search_params.nil?)
        search_params.each do |key, param|
          search_params[key] = nil
        end
      end
    end
  end

  def load_article
    return unless params[:id]
    @article = Article.find_by(id: params[:id])
  end
end
