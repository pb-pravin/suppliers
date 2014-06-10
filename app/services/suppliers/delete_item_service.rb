# encoding: utf-8

module Suppliers

  # Сервис удаляет поставщика/подразделение вместе со всеми дочерними
  # подразделениями, если ни на одно из них нет ссылок в базе данных.
  #
  # Принимает параметры с ключами:
  #
  # * <tt>:id</tt> - ID записи для удаления.
  #
  # Перед добавлением выполняются следующие проверки:
  #
  # * подразделение/поставщик существуе.
  #
  # Публикует одно из сообщений (вызывается метод подписчика):
  #
  # * <tt>:deleted(item)</tt> - запись удалена;
  # * <tt>:not_found(id)</tt> - запись не найдена;
  # * <tt>:error(messages)</tt> - прочие ошибки в ходе удаления.
  #
  class DeleteItemService < BasicApi::Service

    allow_params :id
    attr_reader  :item

    def initialize(options = {})
      super
      @item = Item.find_by_id(id)
    end

    validate :item_found

    private

      def run
        transaction do
          validate!
          item.branch.reverse.each(&:destroy!)
          publish :deleted, item
        end
      end

      # ID записи для удаления
      def id
        @id ||= params["id"]
      end

      # Проверяет, что запись найдена
      def item_found
        fail NotFound.new id unless item
      end
  end
end
