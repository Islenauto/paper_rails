class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :load_user, :only => [:update_score, :top]

  def top
    @search = Article.includes(:newspaper, :article_info, :user_articles).where(is_public: true, user_articles: {user_id: current_user.id}).search(params[:q])
    #@search = Article.all
    @search.sorts = 'opend_at desc' if @search.sorts.empty?
    @articles = @search.result().page(params[:page])
    # @articles = Article.where(is_public: true)
  end

  def update_score
    @user.toeic_score = params[:user][:toeic_score]
    @user.save
    redirect_to root_path
  end

  def calc_known_rate
    current_user.regist_known_rates
    redirect_to :action => 'top'
  end

  private
  def load_user
    @user = current_user
  end
end
