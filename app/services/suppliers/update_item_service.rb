# encoding: utf-8

module Suppliers

  # Сервис сохраняет изменения записи о поставщике/подразделении
  #
  # Принимает параметры с ключами:
  #
  # * <tt>:id</tt> - ID записи для сохранения;
  # * <tt>:name</tt> - новое название;
  # * <tt>:code</tt> - новый код;
  # * <tt>:active</tt> - возможность выбора записи в документах.
  #
  # Перед добавлением выполняются следующие проверки:
  #
  # * запись существует
  # * присутствуют изменения
  #
  # Публикует одно из сообщений (вызывается метод подписчика):
  #
  # * <tt>updated(item)</tt> - изменения сохранены;
  # * <tt>not_changed</tt> - изменения отсутствуют;
  # * <tt>not_found(id)</tt> - запись не найдена;
  # * <tt>errors(messages)</tt> - прочие ошибки.
  #
  class UpdateItemService < BasicApi::Service

    allow_params :id, :name, :code, :active
    attr_reader  :item

    def initialize(options = {})
      super
      @item = Item.find_by_id id
      @item.try :attributes=, params
    end

    validate :item_found
    validate :item_changed

    private

      def run
        begin
          validate!
          item.save!
          publish :updated, item
        rescue NotChanged
          publish :not_changed
        end
      end

      # Специфические (отдельно обрабатываемые) исключения
      class NotChanged < Exception; end

      def id
        @id ||= params.delete "id"
      end

      def item_found
        fail NotFound.new id unless item
      end

      def item_changed
        fail NotChanged unless item.changed?
      end
  end
end
