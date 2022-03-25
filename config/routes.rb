# frozen_string_literal: true

Rails.application.routes.draw do
  root 'lands#index'

  resources :lands, except: %i[new create edit update destroy] do
    match :scrape, via: %i[post put patch], on: :collection
  end
end
