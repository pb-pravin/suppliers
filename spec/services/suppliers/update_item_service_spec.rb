# encoding: utf-8
require "spec_helper"

module Suppliers
  describe UpdateItemService do

    let!(:listener) { double "listener" }
    let!(:item) { create(:item) }
    let!(:params)   {{
      id: item.id,
      name: "Новое название",
      code: "Новый код",
      active: false
    }}

    describe "#run!" do

      context "с корректными параметрами" do

        let!(:service) { UpdateItemService.new params }
        before { service.subscribe listener }

        it "сохраняет изменения" do
          service.run!
          item.reload
          item.name.should eq params[:name]
          item.code.should eq params[:code]
          item.should_not be_active
        end

        it "публикует сообщение об успешном завершении операции" do
          listener.should_receive(:updated) do |result|
            result.should eq item.reload
          end
          service.run!
        end
      end

      context "если код уже зарегистрирован" do

        before { create(:item, code: params[:code]) }

        let!(:service) { UpdateItemService.new params }
        before { service.subscribe listener }

        it "не сохраняет изменения" do
          expect{ service.run! }.not_to change{ item.reload }
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

        let!(:service) { UpdateItemService.new params }
        before { service.subscribe listener }

        it "не сохраняет изменения" do
          expect{ service.run! }.not_to change{ item.reload }
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

        let!(:service) { UpdateItemService.new params }
        before { service.subscribe listener }

        it "не сохраняет изменения" do
          expect{ service.run! }.not_to change{ item.reload }
        end

        it "публикует сообщение об ошибке" do
          listener.should_receive(:error) do |messages|
            messages.should_not be_blank
          end
          service.run!
        end
      end

      context "в отсутствие изменений" do

        let!(:params) {{ id: item.id, name: item.name, code: item.code, active: item.active }}

        let!(:service) { UpdateItemService.new params }
        before { service.subscribe listener }

        it "публикует сообщение об отсутствии изменений" do
          listener.should_receive(:not_changed)
          service.run!
        end
      end

      context "если поставщик не найден" do

        before { item.destroy! }

        let!(:service) { UpdateItemService.new params }
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
