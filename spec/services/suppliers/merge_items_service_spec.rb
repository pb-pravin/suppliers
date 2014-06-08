# encoding: utf-8
require "spec_helper"

module Suppliers
  describe MergeItemsService do

    let!(:listener) { double "listener" }
    let!(:item)     { create(:item) }
    let!(:parent)   { create(:item) }
    let!(:link)     { create(:link, item: item) }
    before{ item.update_attributes! parent: parent }

    let!(:params)   {{ ids: Item.map(&:id) }}

    describe "#run!" do

      context "с корректными параметрами" do

        let!(:service) { MergeItemsService.new params }
        before { service.subscribe listener }

        it "удаляет лишние записи" do
          service.run!
          Item.count.should eq 1
          Item.first.id.should eq parent.id
        end

        it "перепривязывает ссылки на объединенную запись" do
          link.reload.item.should eq parent
        end

        it "публикует сообщение об успешном завершении операции" do
          listener.should_receive(:merged) do |result|
            result.should eq parent
          end
          service.run!
        end
      end

      context "если для объединения выбрано меньше двух разных записей" do

        before { params[:ids] = [item.id, item.id] }

        let!(:service) { MergeItemsService.new params }
        before { service.subscribe listener }

        it "не объединяет записи" do
          expect{ service.run! }.not_to change{ Item.all }
        end

        it "не перепривязывает ссылки" do
          expect{ service.run! }.not_to change{ Link.all }
        end

        it "публикует сообщение об ошибке" do
          listener.should_receive(:error) do |messages|
            messages.should_not be_blank
          end
          service.run!
        end
      end

      context "если одна из объединяемых записей не найдена" do

        before { params[:ids] << 0 }

        let!(:service) { MergeItemsService.new params }
        before { service.subscribe listener }

        it "публикует сообщение, что поставщик не найден" do
          listener.should_receive(:not_found) do |id|
            id.should eq 0
          end
          service.run!
        end
      end
    end
  end
end
