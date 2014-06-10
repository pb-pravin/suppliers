# encoding: utf-8

module Suppliers

  # Сервис объединяет несколько подразделений в одну запись.
  # При объединении сохраняется самая старая запись, не входящая в состав
  # никакой из объединяемых записей. Все ссылки на прочие записи
  # перепривязываются к объединенной записи.
  #
  # Принимает параметры с ключами:
  #
  # * <tt>:ids</tt> - ID объединяемых записей.
  #
  # Перед добавлением выполняются следующие проверки:
  #
  # * для объединения выбрано не менее 2 различных записей;
  # * все объединяемые записи существуют.
  #
  # Публикует одно из сообщений (вызывается метод подписчика):
  #
  # * <tt>merged(item)</tt> - записи объединены;
  # * <tt>not_found(id)</tt> - одна из объединяемых записей не найдена;
  # * <tt>error(messages)</tt> - прочие ошибки объединения.
  #
  class MergeItemsService < BasicApi::Service

    allow_params :ids
    attr_reader :items, :target, :sources, :links

    def initialize(options = {})
      super
      return unless @items = Item.where(id: ids).sort
      @target  = items.first
      @sources = items[1..-1]
      @links   = find_links
    end

    validate :two_or_more_items
    validate :items_found

    private

      def run
        transaction do
          validate!
          links.map(&:save!)
          sources.map(&:destroy!)
          publish :merged, target.reload
        end
      end

      # Массив целочисленных уникальных ID объединяемых записей.
      def ids
        @ids ||= Array(params["ids"]).map(&:to_i).compact.uniq
      end

      # Проверяет, что для объединения выбрано не менее 2 записей.
      def two_or_more_items
        errors.add :ids, :less_than_two if ids.count < 2
      end

      # Проверяет, что все выбранные записи существуют.
      def items_found
        (ids - items.map(&:id)).each{ |id| fail NotFound.new id }
      end

      # Находит список ссылок на объединяемые записи и перепривязывает их
      # к объединенной записи.
      def find_links
        sources.map(&:links).flatten.map do |link|
          record = link.record
          record.send "#{ link.foreign_key }=", target.id
          record
        end
      end
  end
end
