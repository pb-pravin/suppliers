# encoding: utf-8

Suppliers::Engine.routes.draw do

  # Маршруты для JSON API модуля
  namespace :api, defaults: { format: "json" } do
    namespace :v1 do
      # resources :TODO, constraints: { format: :json }
    end
  end
end
