# frozen_string_literal: true

Rails.application.routes.draw do
  root 'pages#home'
  get '/login' => 'sessions#new'
  post '/login' => 'sessions#create'
  delete '/logout' => 'sessions#destroy'

  get 'about' => 'pages#about'
  get 'find' => 'users#index'
  get 'help' => 'pages#help'
  get 'moderation' => 'pages#moderation'
  get 'news' => 'pages#news'
  get 'signup' => 'users#new'
  get 'welcome' => 'pages#home'

  resources :challenges
  get 'challenges/:id/entries' => 'challenges#entries'
  post 'challenges/:id/mod_action' => 'challenges#mod_action'

  resources :moderator_applications

  resources :notifications, only: %i[index] do
    collection do
      post :mark_as_read
    end
  end

  resources :password_resets, only: %i[new create edit update]

  resources :submissions do
    resources :comments
    post 'comments/:id/mod_action' => 'comments#mod_action'
  end
  post 'submissions/:id/mod_action' => 'submissions#mod_action'

  resources :users
  post 'users/:id/mod_action' => 'users#mod_action'
  get 'users/:id/submissions' => 'users#submissions'
  get 'users/:user_id/email_verification' => 'email_verifications#new',
    as: :new_email_verification
  post 'users/:user_id/email_verification' => 'email_verifications#create',
    as: :email_verifications
  get 'users/:user_id/email_verification/:token' => 'email_verifications#edit',
    as: :edit_email_verification
  post 'users/:user_id/email_verification/:token' => 'email_verifications#update',
    as: :email_verification

  if ENV['X_AUTH_HOST'].present?
    get 'x_site_auth/auto_login_available' => 'x_site_auth#auto_login_available'
    get 'x_site_auth/login' => 'x_site_auth#login'
    post 'x_site_auth/sign' => 'x_site_auth#sign'
  end
end
