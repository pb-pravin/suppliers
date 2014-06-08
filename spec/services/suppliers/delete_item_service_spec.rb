# encoding: utf-8
require "spec_helper"

module Suppliers
  describe DeleteItemService do

    let!(:listener) { double "listener" }
    let!(:parent)   { create(:item) }
    let!(:item)     { create(:item, parent: parent) }
    let!(:params)   {{ id: parent.id }}

    describe "#run!" do

      context "с корректными параметрами" do

        let!(:service) { DeleteItemService.new params }
        before { service.subscribe listener }

        it "удаляет поставщика и все его подразделения" do
          expect{ service.run! }.to change{ Item.count }.to 0
        end

        it "публикует сообщение об успешном завершении операции" do
          listener.should_receive(:deleted) do |result|
            result.should eq parent
          end
          service.run!
        end
      end

      context "если на одно из подразделений есть ссылка" do

        before { create(:link, item: item) }

        let!(:service) { DeleteItemService.new params }
        before { service.subscribe listener }

        it "не удаляет записи" do
          expect{ service.run! }.not_to change{ Item.count }
        end

        it "публикует сообщение об ошибке" do
          listener.should_receive(:error) do |messages|
            messages.should_not be_blank
          end
          service.run!
        end
      end

      context "если поставщик для удаления не найден" do

        before { params[:id] = 0 }

        let!(:service) { DeleteItemService.new params }
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
