# frozen_string_literal: true

Rails.application.routes.draw do
  resources :uuid_identifiers
  resources :identifiers
  resources :uuids

  root to: 'identifiers#index'
end
