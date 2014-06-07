# encoding: utf-8

Suppliers::Engine.routes.draw do

  # Маршруты для JSON API модуля
  namespace :api, defaults: { format: "json" } do
    namespace :v1, constraints: { format: :json } do
      resources :items, only: %w(index create show destroy)
      put   "items", to: "items#merge"
      put   "items/:parent_id", to: "items#move"
      patch "items/:id", to: "items#update", constraints: { id: /\d+/ }
      post  "items/:parent_id", to: "items#create"
    end
  end
end
