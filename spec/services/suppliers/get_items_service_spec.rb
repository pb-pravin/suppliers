# encoding: utf-8
require "spec_helper"

module Suppliers
  describe GetItemsService do

    let!(:listener) { double "listener" }
    let!(:division) { create(:item, code: "Кран") }
    let!(:parent)   { create(:item, name: "Главпоставка") }
    let!(:item)     { create(:item, name: "Сталькран") }
    before{ division.update_attributes! parent: parent }

    describe "#run!" do

      context "без фильтрации" do

        let!(:service) { GetItemsService.new }
        before { service.subscribe listener }

        it "публикует сообщение со списком всех поставщиков" do
          listener.should_receive(:list) do |result|
            result.should eq Item.all.order(lft: :asc, rgt: :desc)
          end
          service.run!
        end
      end

      context "с фильтром по подстроке поиска" do

        let!(:service) { GetItemsService.new search: "ран" }
        before { service.subscribe listener }

        it "публикует сообщение со списком найденных поставщиков" do
          listener.should_receive(:list) do |result|
            result.should eq [division, item]
          end
          service.run!
        end
      end

      context "с фильтром по корневому подразделению" do

        let!(:service) { GetItemsService.new root_id: parent.id }
        before { service.subscribe listener }

        it "публикует сообщение со списком найденных поставщиков" do
          listener.should_receive(:list) do |result|
            result.should eq [parent, division]
          end
          service.run!
        end
      end

      context "с фильтрами по корневому подразделению и подстроке" do

        let!(:service) { GetItemsService.new root_id: parent.id }
        before { service.subscribe listener }

        it "публикует сообщение со списком найденных поставщиков" do
          listener.should_receive(:list) do |result|
            result.should eq [division]
          end
          service.run!
        end
      end

      context "если корневое подразделение не найдено" do

        let!(:service) { GetItemsService.new root_id: 0 }
        before { service.subscribe listener }

        it "публикует сообщение что запись не найдена" do
          listener.should_receive(:not_found) do |id|
            id.should eq 0
          end
          service.run!
        end
      end
    end
  end
end
