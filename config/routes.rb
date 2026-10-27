# frozen_string_literal: true

Automation::Engine.routes.draw do
  root to: "jobs#index"
  resources :jobs, only: :index
  resources :rules, only: :index do
    collection do
      post :upload
    end
    member do
      get :export
    end
  end
end
