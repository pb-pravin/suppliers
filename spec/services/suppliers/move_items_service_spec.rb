# encoding: utf-8
require "spec_helper"

module Suppliers
  describe MoveItemsService do

    let!(:listener) { double "listener" }
    let!(:parent)   { create(:item) }
    let!(:item)     { create(:item) }
    let!(:params)   {{ parent_id: parent.id, ids: [item.id] }}

    describe "#run!" do

      context "с корректными параметрами" do

        let!(:service) { MoveItemsService.new params }
        before { service.subscribe listener }

        it "переносит выбранные записи в состав текущего поставщика" do
          expect{ service.run! }.to change{ item.reload.parent }.to parent
        end

        it "публикует сообщение об успешном завершении операции" do
          listener.should_receive(:moved) do |result|
            result.should eq parent.reload
          end
          service.run!
        end
      end

      context "при попытке включить поставщика в состав его собственного подразделения" do

        before { parent.update_attributes! parent: item }

        let!(:service) { MoveItemsService.new params }
        before { service.subscribe listener }

        it "не меняет записи" do
          expect{ service.run! }.not_to change{ Item.all }
        end

        it "публикует сообщение об ошибке" do
          listener.should_receive(:error) do |messages|
            messages.should_not be_blank
          end
          service.run!
        end
      end

      context "при попытке включить поставщика в состав самого себя" do

        before { params[:ids] << parent.id }

        let!(:service) { MoveItemsService.new params }
        before { service.subscribe listener }

        it "не меняет записи" do
          expect{ service.run! }.not_to change{ Item.all }
        end

        it "публикует сообщение об ошибке" do
          listener.should_receive(:error) do |messages|
            messages.should_not be_blank
          end
          service.run!
        end
      end

      context "если поставщики для переноса не указаны" do

        before { params[:ids] = nil }

        let!(:service) { MoveItemsService.new params }
        before { service.subscribe listener }

        it "не меняет записи" do
          expect{ service.run! }.not_to change{ Item.all }
        end

        it "публикует сообщение об ошибке" do
          listener.should_receive(:error) do |messages|
            messages.should_not be_blank
          end
          service.run!
        end
      end

      context "если поставщик не найден" do

        before { parent.destroy! }

        let!(:service) { MoveItemsService.new params }
        before { service.subscribe listener }

        it "публикует сообщение, что поставщик не найден" do
          listener.should_receive(:not_found) do |id|
            id.should eq params[:parent_id]
          end
          service.run!
        end
      end

      context "если поставщик для переноса не найден" do

        before { item.destroy! }

        let!(:service) { MoveItemsService.new params }
        before { service.subscribe listener }

        it "публикует сообщение, что поставщик не найден" do
          listener.should_receive(:not_found) do |id|
            id.should eq item.id
          end
          service.run!
        end
      end
    end
  end
end
