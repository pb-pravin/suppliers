# encoding: utf-8

module Suppliers
  module Api
    module V1

      # Контроллер операций с поставщиками
      class ItemsController < ApplicationController

        # ======================================================================
        # Запросы пользователя
        # ======================================================================

        def index
          service = GetItemsService.new params.permit(:search, :root_id)
          service.subscribe self
          service.run!
        end

        def create
          service = CreateItemService.new params.
            permit(:parent_id, :code, :name, :active)
          service.subscribe self
          service.run!
        end

        def show
          service = GetItemService.new params.permit(:id)
          service.subscribe self
          service.run!
        end

        def update
          service = UpdateItemService.new params.
            permit(:id, :code, :name, :active)
          service.subscribe self
          service.run!
        end

        def destroy
          service = DeleteItemService.new params.permit(:id)
          service.subscribe self
          service.run!
        end

        def move
          service = MoveItemsService.new params.permit(:parent_id, ids: [])
          service.subscribe self
          service.run!
        end

        def merge
          service = MergeItemsService.new params.permit(ids: [])
          service.subscribe self
          service.run!
        end

        # ======================================================================
        # Публикации сервисов
        # ======================================================================

        def found(item)
          @success, @item = true, item
          render "show"
        end

        def list(items)
          @success, @items = true, items
          render "index"
        end

        def created(item)
          @success, @item = true, item
          alert :success, :created, options
          render "show", status: 201
        end

        def updated(item)
          @success, @item = true, item
          alert :success, :updated, options
          render "show"
        end

        def deleted(item)
          @success, @item = true, item
          alert :success, :deleted, options
          render "show"
        end

        def moved(item)
          @success, @item = true, item
          alert :success, :moved, options
          render "show"
        end

        def merged(item)
          @success, @item = true, item
          alert :success, :merged, options
          render "show"
        end

        def not_found(id)
          @success = false
          alert :error, :not_found, id: id
          render_error 404
        end

        def not_changed
          @success = false
          alert :error, :not_changed
          render_error 422
        end

        def error(messages)
          @success = false
          messages.each{ |message| alert :error, message }
          render_error 422
        end

        private

          def options
            { code: @item.code, name: @item.name }
          end
      end
    end
  end
end
