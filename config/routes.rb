require 'sidekiq/web'
require 'sidekiq/cron/web'

Rails.application.routes.draw do

  use_doorkeeper
  admin = lambda do |request|
    request.env['warden'].authenticate? && request.env['warden'].user.admin?
  end

  constraints admin do
    mount Sidekiq::Web => '/sidekiq'
    ActiveAdmin.routes(self)
  end

  devise_for :participants
  resources :participants, only: [:show, :edit, :update, :destroy] do
    get :sync_mailchimp
    get :regen_api_key
    get :remove_image
    resources :email_preferences, only: [:edit, :update]
  end
  resources :job_postings, only: [:index, :show]

  # API
  namespace :api do
    resources :external_graders, only: [:create, :show, :update] do
      get :challenge_config, on: :collection
      get :presign, on: :member
      get :submission_info, on: :member
    end
    get 'mailchimps/webhook' => 'mailchimps#verify', as: :verify_webhook
    post 'mailchimps/webhook' => 'mailchimps#webhook', as: :update_webhook
  end

  resources :landing_page, only: [:index]
  match '/landing_page/host', to: 'landing_page#host', via: :get

  resources :organizer_applications, only: [:create]
  resources :organizers, except: [:new, :index] do
    resources :challenges
    get :remove_image
    get :regen_api_key
    get :members
    resources :clef_tasks
  end

  resources :clef_tasks do
    resources :task_dataset_files
  end

  resources :participant_clef_tasks

  resources :task_dataset_files do
    resources :task_dataset_file_downloads
  end

  resources :challenges do
    resources :dataset_files, only: [:new, :show, :index, :destroy, :create]
    resources :participant_challenges, only: [:index] do
      get :approve, on: :collection
      get :deny, on: :collection
    end
    resources :events
    resources :winners, only: [:index]
    resources :submissions do
      get :grade
      get :hub
      get :execute
    end
    resources :dynamic_contents, only: [:index]
    resources :leaderboards, only: [:index, :show] do
      get :submission_detail
    end
    get 'leaderboards/video_modal' => 'leaderboards#video_modal', as: :video_modal
    #get 'leaderboards/submission_detail' => 'leaderboards#submission_detail', as: :submission_detail
    resources :topics
    get :regrade
    get :remove_image
    get :clef_task
    resources :votes, only: [:create, :destroy]
    resources :follows, only: [:create, :destroy]
  end
  get '/load_more_challenges', to: 'challenges#load_more', as: :load_more_challenges

  resources :dataset_files, only: [] do
    resources :dataset_file_downloads, only: [:create]
  end


  resources :submissions, only: [] do
    resources :submission_comments, only: [:create, :delete, :edit, :update]
  end

  resources :submission_comments, only: [] do
    resources :votes, only: [:create, :destroy]
  end

  resources :topics do
    resources :comments, only: [:new, :create, :edit, :destroy, :update] do
      get :quote
    end
    resources :votes, only: [:create, :destroy]
  end
  match '/topics/:topic_id/discussion', to: 'comments#new', via: :get, as: :new_topic_discussion


  resources :comments, only: [] do
    resources :votes, only: [:create, :destroy]
  end

  resources :articles do
    resources :article_sections
    resources :votes, only: [:create, :destroy]
    get :remove_image
  end
  get '/load_more_articles', to: 'articles#load_more', as: :load_more_articles

  match '/contact', to: 'pages#contact', via: :get
  match '/privacy', to: 'pages#privacy', via: :get
  match '/terms',   to: 'pages#terms',   via: :get
  match '/faq',     to: 'pages#faq',     via: :get

  resources :markdown_editors, only: [:index, :create] do
    put :presign, on: :collection
  end

  root 'landing_page#index'
end
