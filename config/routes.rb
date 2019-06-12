# frozen_string_literal: true

Rails.application.routes.draw do
  resources :umpebc_kbarts
  resources :uuid_identifiers
  resources :identifiers
  resources :uuids
end
