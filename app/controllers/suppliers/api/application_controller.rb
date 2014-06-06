# encoding: utf-8

module Suppliers
  module Api
    class ApplicationController < ::ApplicationController
      include BasicApi::Controllers

      private

        # возвращает ответ сервера в случае ошибки.
        def render_error(status)
          render inline: "{}", status: status,
                 layout: "suppliers/api/application"
        end
    end
  end
end
