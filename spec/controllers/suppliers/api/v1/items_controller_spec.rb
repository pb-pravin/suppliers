require "spec_helper"

module Suppliers
  module Api
    module V1
      describe ItemsController do
        routes { Suppliers::Engine.routes }

        before { controller.stub(:render) }

        describe "в ответ на запрос" do

          let!(:service) { double "service" }
          before { service.stub(:subscribe) }
          before { service.stub(:run!) }

          let!(:params) {{
            "active"    => true,
            "format"    => "json",
            "id"        => "1",
            "ids"       => ["1", "3"],
            "parent_id" => "1",
            "root_id"   => "1",
            "search"    => "строка",
            "wrong"     => "Wrong",
          }}

          describe "#index" do

            let!(:service_class) { GetItemsService }
            before { service_class.stub(:new).and_return service }
            after  { get :index, params }

            it "инициализирует сервис с корректными параметрами" do
              service_class.should_receive(:new).with params.slice("search", "root_id")
            end

            it "подписывается на сервис и запускает его на исполнение" do
              service.should_receive(:subscribe).with(controller)
              service.should_receive(:run!)
            end
          end

          describe "#create" do

            let!(:service_class) { CreateItemService }
            before { service_class.stub(:new).and_return service }
            after  { post :create, params }

            it "инициализирует сервис с корректными параметрами" do
              service_class.should_receive(:new).with params.slice("code", "name", "parent_id", "active")
            end

            it "подписывается на сервис и запускает его на исполнение" do
              service.should_receive(:subscribe).with(controller)
              service.should_receive(:run!)
            end
          end

          describe "#show" do

            let!(:service_class) { GetItemService }
            before { service_class.stub(:new).and_return service }
            after  { get :show, params }

            it "инициализирует сервис с корректными параметрами" do
              service_class.should_receive(:new).with params.slice("id")
            end

            it "подписывается на сервис и запускает его на исполнение" do
              service.should_receive(:subscribe).with(controller)
              service.should_receive(:run!)
            end
          end

          describe "#update" do

            let!(:service_class) { UpdateItemService }
            before { service_class.stub(:new).and_return service }
            after  { patch :update, params }

            it "инициализирует сервис с корректными параметрами" do
              service_class.should_receive(:new).with params.slice("id", "name", "active", "code")
            end

            it "подписывается на сервис и запускает его на исполнение" do
              service.should_receive(:subscribe).with(controller)
              service.should_receive(:run!)
            end
          end

          describe "#destroy" do

            let!(:service_class) { DeleteItemService }
            before { service_class.stub(:new).and_return service }
            after  { delete :destroy, params }

            it "инициализирует сервис с корректными параметрами" do
              service_class.should_receive(:new).with params.slice("id")
            end

            it "подписывается на сервис и запускает его на исполнение" do
              service.should_receive(:subscribe).with(controller)
              service.should_receive(:run!)
            end
          end

          describe "#move" do

            let!(:service_class) { MoveItemsService }
            before { service_class.stub(:new).and_return service }
            after  { put :move, params }

            it "инициализирует сервис с корректными параметрами" do
              service_class.should_receive(:new).with params.slice("parent_id", "ids")
            end

            it "подписывается на сервис и запускает его на исполнение" do
              service.should_receive(:subscribe).with(controller)
              service.should_receive(:run!)
            end
          end

          describe "#merge" do

            let!(:service_class) { MergeItemsService }
            before { service_class.stub(:new).and_return service }
            after  { put :merge, params }

            it "инициализирует сервис с корректными параметрами" do
              service_class.should_receive(:new).with params.slice("ids")
            end

            it "подписывается на сервис и запускает его на исполнение" do
              service.should_receive(:subscribe).with(controller)
              service.should_receive(:run!)
            end
          end
        end

        describe "в ответ на публикацию сервиса" do

          let!(:items)    { double "items" }
          let!(:item)     { double "item" }
          let!(:messages) { %w(invalid) }

          before { item.stub(:name) }
          before { item.stub(:code) }

          describe "#list(items)" do

            it "присваивает true переменной @success" do
              controller.list(items)
              assigns(:success).should be_truthy
            end

            it "инициализирует переменную @items" do
              controller.list(items)
              assigns(:items).should eq items
            end

            it "верстает шаблон 'index'" do
              controller.should receive_render "index"
              controller.list(items)
            end
          end

          describe "#created(item)" do

            it "присваивает true переменной @success" do
              controller.created(item)
              assigns(:success).should be_truthy
            end

            it "инициализирует переменную @item" do
              controller.created(item)
              assigns(:item).should eq item
            end

            it "выводит сообщение об успехе операции" do
              controller.created(item)
              assigns(:messages).first["success"].should_not be_blank
            end

            it "верстает шаблон 'show'" do
              controller.should receive_render "show", with: 201
              controller.created(item)
            end
          end

          describe "#found" do

            it "присваивает true переменной @success" do
              controller.found(item)
              assigns(:success).should be_truthy
            end

            it "инициализирует переменную @item" do
              controller.found(item)
              assigns(:item).should eq item
            end

            it "верстает шаблон 'show'" do
              controller.should receive_render "show"
              controller.found(item)
            end
          end

          describe "#updated" do

            it "присваивает true переменной @success" do
              controller.updated(item)
              assigns(:success).should be_truthy
            end

            it "инициализирует переменную @item" do
              controller.updated(item)
              assigns(:item).should eq item
            end

            it "выводит сообщение об успехе операции" do
              controller.updated(item)
              assigns(:messages).first["success"].should_not be_blank
            end

            it "верстает шаблон 'show'" do
              controller.should receive_render "show"
              controller.updated(item)
            end
          end

          describe "#merged" do

            it "присваивает true переменной @success" do
              controller.merged(item)
              assigns(:success).should be_truthy
            end

            it "инициализирует переменную @item" do
              controller.merged(item)
              assigns(:item).should eq item
            end

            it "выводит сообщение об успехе операции" do
              controller.merged(item)
              assigns(:messages).first["success"].should_not be_blank
            end

            it "верстает шаблон 'show'" do
              controller.should receive_render "show"
              controller.merged(item)
            end
          end

          describe "#moved" do

            it "присваивает true переменной @success" do
              controller.moved(item)
              assigns(:success).should be_truthy
            end

            it "инициализирует переменную @item" do
              controller.moved(item)
              assigns(:item).should eq item
            end

            it "выводит сообщение об успехе операции" do
              controller.moved(item)
              assigns(:messages).first["success"].should_not be_blank
            end

            it "верстает шаблон 'show'" do
              controller.should receive_render "show"
              controller.moved(item)
            end
          end

          describe "#not_found(id)" do

            it "присваивает false переменной @success" do
              controller.not_found(1)
              assigns(:success).should be_falsey
            end

            it "выводит сообщение об ошибке" do
              controller.not_found(1)
              assigns(:messages).first["error"].should_not be_blank
            end

            it "верстает корректный макет" do
              controller.should render_layout "suppliers/api/application", with: 404
              controller.not_found(1)
            end
          end

          describe "#not_changed" do

            it "присваивает false переменной @success" do
              controller.not_changed
              assigns(:success).should be_falsey
            end

            it "выводит сообщение об ошибке" do
              controller.not_changed
              assigns(:messages).first["error"].should_not be_blank
            end

            it "верстает корректный макет" do
              controller.should render_layout "suppliers/api/application", with: 422
              controller.not_changed
            end
          end

          describe "#error(messages)" do

            it "присваивает false переменной @success" do
              controller.error(messages)
              assigns(:success).should be_falsey
            end

            it "выводит сообщение об ошибке" do
              controller.error(messages)
              assigns(:messages).first["error"].should_not be_blank
            end

            it "верстает корректный макет" do
              controller.should render_layout "suppliers/api/application", with: 422
              controller.error(messages)
            end
          end
        end
      end
    end
  end
end
