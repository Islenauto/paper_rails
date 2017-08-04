Rails.application.routes.draw do
  devise_for :users
  root to: 'users#top'

  namespace :admin do
    resources :articles, only: [:index, :show] do
      get 'toggle_public'
    end
  end

  resources :users, only: [] do
    collection do
      get 'calc_known_rate'
      post 'update_score'
    end
  end

  resources :articles, only: [:show]

  # resources :word_histories, only: [] do
  #   get 'change_known', param: :word
  # end
  get 'word_histories/change_known'
  get 'user_articles/regist_read_status'

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
