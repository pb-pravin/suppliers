# encoding: utf-8

module Suppliers

  # Сервис перемещает выбранные подразделения в состав другого подразделения.
  #
  # Принимает параметры с ключами:
  #
  # * <tt>:parent_id</tt> - ID поставщика/подразделения, в состав которого 
  #   переносятся подразделения.
  # * <tt>:ids</tt> - список ID перемещаемых подразделений.
  #
  # Перед добавлением выполняются следующие проверки:
  #
  # * для перемещения выбрано хотя бы одно подразделение;
  # * поставщик и все перемещаемые подразделения существуют.
  #
  # Публикует одно из сообщений (вызывается метод подписчика):
  #
  # * <tt>moved(item)</tt> - подразделения успешно перемещены;
  # * <tt>not_found(id)</tt> - поставщик или одно из перемещаемых подразделений
  #   не найдены;
  # * <tt>error(message)</tt> - прочие ошибки при перемещении.
  #
  class MoveItemsService < BasicApi::Service

    allow_params :parent_id, :ids
    attr_reader  :parent, :items

    def initialize(options = {})
      super
      @parent = Item.find_by_id(parent_id)
      @items  = Item.where id: ids
      items.each{ |item| item.parent = parent }
    end

    validate :parent_found
    validate :ids_present
    validate :items_found

    private

      def run
        transaction do
          validate!
          items.map(&:save!)
          publish :moved, parent.reload
        end
      end

      # ID поставщика, в состав которого переносятся подразделения.
      def parent_id
        @parent_id ||= params["parent_id"].try(:to_i)
      end

      # Массив целочисленных ID подразделений.
      def ids
        @ids ||= Array(params["ids"]).map(&:to_i).compact.uniq
      end

      # Проверяет, что поставщик существует.
      def parent_found
        fail NotFound.new parent_id unless parent
      end

      # Проверяет, что все выбранные для переноса подразделения существуют.
      def items_found
        (ids - items.map(&:id)).each{ |id| fail NotFound.new id }
      end

      # Проверяет, что для переноса выбрано хотя бы одно подразделение.
      def ids_present
        if ids.blank?
          errors.add :ids, :blank, code: parent.code, name: parent.name
        end
      end
  end
end
