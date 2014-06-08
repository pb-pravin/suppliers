# encoding: utf-8

module Suppliers

  # Сервис TODO
  #
  # Принимает параметры с ключами:
  #
  # * <tt>TODO</tt> - TODO.
  #
  # Перед добавлением выполняются следующие проверки:
  #
  # * TODO.
  #
  # Публикует одно из сообщений (вызывается метод подписчика):
  #
  # * <tt>TODL</tt> - TODO.
  #
  class MergeItemsService < BasicApi::Service

    # allow_params TODO
    # attr_reader  TODO

    def initialize(options = {})
      super
      # TODO
    end

    # validate() { TODO }

    def run
      begin
        # TODO
        # publish TODO
      rescue
        # publish TODO
      end
    end

    private

      # Специфические (отдельно обрабатываемые) исключения
      # class TODO < Exception; end
  end
end
