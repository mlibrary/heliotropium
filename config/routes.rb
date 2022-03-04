# frozen_string_literal: true

Rails.application.routes.draw do
  resources :programs, only: %i[index show] do
    member do
      get :run
    end
  end

  resources :marc_records
  resources :kbart_files
  resources :kbart_marcs
  resources :marc_files
end
