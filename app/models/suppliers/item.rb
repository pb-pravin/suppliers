# encoding: utf-8

module Suppliers
  class Item < ActiveRecord::Base
    extend  BasicApi::Attributes
    include Backlinks

    acts_as_nested_set

    attributes :name, :code, type: Attributes::StrippedString
    belongs_to :parent, class_name: :Item
    has_many   :divisions, class_name: :Item, foreign_key: :parent_id

    validates :name, :code, presence: true
    validate  :code_unique
    validate  :parent_is_not_self
    validate  :parent_is_not_division
    before_destroy :links_absent

    def branch
      self.class.where("lft >= :lft AND rgt <= :rgt", lft: lft, rgt: rgt).sort
    end

    scope :sort, ->() { order(lft: :asc, rgt: :desc) }

    scope :by_string, ->(str) {
      search = "%#{ str.to_s.strip.downcase }%"
      where("lower(code) LIKE :str OR lower(name) LIKE :str", str: search).sort
    }

    private

      def code_unique
        return unless code
        return unless found = self.class.where("lower(code) = ?", code).first
        errors.add :code, :taken, name: found.name unless found.id == id
      end

      def parent_is_not_self
        return unless parent_id
        errors.add :parent, :self, code: code, name: name if parent_id == id
      end

      def parent_is_not_division
        return unless parent
        return unless branch.include? parent
        errors.add :parent, :invalid, parent_code: parent.code,
          parent_name: parent.name, code: code, name: name
      end

      def links_absent
        return true if links.blank?
        errors.add :base, :has_links, code: code, name: name
        fail ActiveRecord::RecordInvalid.new self
      end
  end
end
