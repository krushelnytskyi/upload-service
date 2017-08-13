Rails.application.routes.draw do
  devise_for :users
  root to: 'dashboard#index'
  get '/login', to: 'dashboard#index'

  get '/upload/download_all', to: 'upload#download_all', as: :download_all_upload
  resources :company
  resources :upload, exclude: [:new]
  resources :user, path: '/users/manage'
  post '/users/manage/revoke/:id', to: 'user#revoke_access', as: :revoke_user_access
  get '/upload/new/:company_id/:year', to: 'upload#new', as: :new_company_upload
end
