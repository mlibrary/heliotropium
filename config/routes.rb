# frozen_string_literal: true

Rails.application.routes.draw do
  resources :programs, only: %i[index show] do
    member do
      get :run
    end
  end

  resources :catalog_marcs
  resources :umpebc_kbarts
  resources :umpebc_marcs

  resources :identifiers
  resources :uuid_identifiers
  resources :uuids
end
