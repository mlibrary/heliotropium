# frozen_string_literal: true

Rails.application.routes.draw do
  resources :lib_ptg_folders
  resources :uuid_identifiers
  resources :identifiers
  resources :uuids

  root to: 'lib_ptg_folders#index'
end
