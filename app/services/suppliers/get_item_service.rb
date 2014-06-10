# encoding: utf-8

module Suppliers

  # Сервис находит поставщика/подразделение
  #
  # Принимает параметры с ключами:
  #
  # * <tt>:id</tt> - ID записи для вывода.
  #
  # Перед добавлением выполняются следующие проверки:
  #
  # * запись существует
  #
  # Публикует одно из сообщений (вызывается метод подписчика):
  #
  # * <tt>found(item)</tt> - запись найдена;
  # * <tt>not_found(id)</tt> - запись не найдена.
  #
  class GetItemService < BasicApi::Service

    allow_params :id
    attr_reader  :item

    def initialize(options = {})
      super
      @item = Item.find_by_id(id)
    end

    validate :item_found

    private

      def run
        validate!
        publish :found, id
      end

      # ID записи для поиска
      def id
        @id ||= params["id"]
      end

      # Проверяет, что запись найдена
      def item_found
        fail NotFound.new id unless item
      end
  end
end
