# encoding: utf-8

module Suppliers

  # Сервис возвращает список записей с возможностью отбора по подразделению
  # (возвращаются только подразделение и все его дочерние подразделения любого
  # уровня) и подстроке названия или кода.
  #
  # Принимает параметры с ключами:
  #
  # * <tt>:root_id</tt> - ID подразделения, в ветке которого ведется поиск;
  # * <tt>:search</tt> - строка для поиска в названии или коде.
  #
  # Перед добавлением выполняются следующие проверки:
  #
  # * подразеделение найдено (если :root_id указан)
  #
  # Публикует одно из сообщений (вызывается метод подписчика):
  #
  # * <tt>list(items)</tt> - найден список записей, удовлетворяющий условиям
  #   поиска;
  # * <tt>not_found(id)</tt> - не найдено подразделение, в ветке которого
  #   выполняется поиск.
  #
  class GetItemsService < BasicApi::Service

    allow_params :root_id, :search
    attr_reader  :root

    def initialize(options = {})
      super
      @root = Item.find_by_id id
    end

    validate :root_found

    private

      def run
        validate!
        items = root ? root.branch : Item.all
        items = items.by_string(search) if search
        publish :list, items.sort
      end

      def id
        @id ||= params["root_id"]
      end

      def search
        @search ||= params["search"]
      end

      def root_found
        fail NotFound.new id if id && !root
      end
  end
end
