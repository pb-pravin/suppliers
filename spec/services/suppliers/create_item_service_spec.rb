# encoding: utf-8
require "spec_helper"

module Suppliers
  describe CreateItemService do

    let!(:listener) { double "listener" }
    let!(:parent)   { create(:item) }
    let!(:params)   {{
      parent_id: parent.id,
      name: "Новый поставщик",
      code: "Код поставщика",
      active: true
    }}

    describe "#run!" do

      context "с ID вышестоящего подразделения" do

        let!(:service) { CreateItemService.new params }
        before { service.subscribe listener }

        it "добавляет запись в базу данных" do
          expect{ service.run! }.to change{ Item.count }.by(1)
          item = Item.last
          item.name.should eq params[:name]
          item.code.should eq params[:code]
          item.should be_active
          item.parent.should eq parent
        end

        it "публикует сообщение об успешном завершении операции" do
          listener.should_receive(:created) do |result|
            result.should eq Item.last
          end
          service.run!
        end
      end

      context "без ID вышестоящего подразделения" do

        before { params[:parent_id] = nil }
        let!(:service) { CreateItemService.new params }
        before { service.subscribe listener }

        it "добавляет запись в базу данных" do
          expect{ service.run! }.to change{ Item.count }.by(1)
          item = Item.last
          item.name.should eq params[:name]
          item.code.should eq params[:code]
          item.should be_active
          item.parent.should be_nil
        end

        it "публикует сообщение об успешном завершении операции" do
          listener.should_receive(:created) do |result|
            result.should eq Item.last
          end
          service.run!
        end
      end

      context "если код уже используется" do

        before { create(:item, code: params[:code]) }

        let!(:service) { CreateItemService.new params }
        before { service.subscribe listener }

        it "не добавляет запись в справочник" do
          expect{ service.run! }.not_to change{ Item.count }
        end

        it "публикует сообщение об ошибке" do
          listener.should_receive(:error) do |messages|
            messages.should_not be_blank
          end
          service.run!
        end
      end

      context "с недопустимым кодом" do

        before { params[:code] = "" }

        let!(:service) { CreateItemService.new params }
        before { service.subscribe listener }

        it "не добавляет запись в справочник" do
          expect{ service.run! }.not_to change{ Item.count }
        end

        it "публикует сообщение об ошибке" do
          listener.should_receive(:error) do |messages|
            messages.should_not be_blank
          end
          service.run!
        end
      end

      context "с недопустимым названием" do

        before { params[:name] = "" }

        let!(:service) { CreateItemService.new params }
        before { service.subscribe listener }

        it "не добавляет запись в справочник" do
          expect{ service.run! }.not_to change{ Item.count }
        end

        it "публикует сообщение об ошибке" do
          listener.should_receive(:error) do |messages|
            messages.should_not be_blank
          end
          service.run!
        end
      end

      context "если вышестоящее подразделение не найдено" do

        before { parent.destroy! }

        let!(:service) { CreateItemService.new params }
        before { service.subscribe listener }

        it "не добавляет запись в справочник" do
          expect{ service.run! }.not_to change{ Item.count }
        end

        it "публикует сообщение, что поставщик не найден" do
          listener.should_receive(:not_found) do |id|
            id.should eq params[:parent_id]
          end
          service.run!
        end
      end
    end
  end
end
