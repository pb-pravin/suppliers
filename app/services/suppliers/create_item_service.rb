# encoding: utf-8

module Suppliers

  # Сервис регистрирует нового поставщика (подразделение)
  #
  # Принимает параметры с ключами:
  #
  # * <tt>:name</tt> - название поставщика;
  # * <tt>:code</tt> - код поставщика;
  # * <tt>:active</tt> - возможность выбирать поставщика в документах (true|false);
  # * <tt>:parent_id</tt> - ссылка на вышестоящее подразделение/поставщика.
  #
  # Перед добавлением выполняются следующие проверки:
  #
  # * вышестоящее подразделение существует (если указан id).
  #
  # Публикует одно из сообщений (вызывается метод подписчика):
  #
  # * <tt>:created(item)</tt> - запись добавлена в справочник;
  # * <tt>:not_found(id)</tt> - вышестоящее подразделение/поставщик не найдено;
  # * <tt>:error(messages)</tt> - прочие ошибки.
  #
  class CreateItemService < BasicApi::Service

    allow_params :name, :code, :active, :parent_id
    attr_reader  :parent, :item

    def initialize(options = {})
      super
      @parent = Item.find_by_id(id) if id
      @item   = Item.new params
    end

    validate :parent_found

    private

      def run
        validate!
        item.save!
        publish :created, item
      end

      # ID вышестоящего подразделения/поставщика
      def id
        @id ||= params["parent_id"].try(:to_i)
      end

      # Проверяет,что вышестоящее подразделение существует
      def parent_found
        fail NotFound.new id if id && !parent
      end
  end
end
