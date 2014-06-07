require "spec_helper"

module Suppliers
  describe "GET suppliers/api/v1/items" do
    
    # Начальные условия
    let!(:root) { create(:item, name: "Главснаб") }
    let!(:item) { create(:item, name: "Отдел поставки") }
    let!(:div)  { create(:item, code: "Рост", parent: root) }

    # Маршрут и параметры запроса
    let!(:route)  { "suppliers/api/v1/items" }

    context "без фильтрации" do

      before { get route }

      it "возвращает корректный ответ сервера" do
        response.should be_success
        response.status.should eq 200
      end

      it "верстает корректный JSON" do
        json = JSON.parse(response.body)
        json.should == {
          "success"  => true,
          "data" => [
            {
              "id" => root.id,
              "name" => root.name,
              "code" => root.code,
              "active" => root.active?,
              "depth" => root.depth,
              "parent_id" => nil,
              "divisions" => [div.id]
            },
            {
              "id" => div.id,
              "name" => div.name,
              "code" => div.code,
              "active" => div.active?,
              "depth" => div.depth,
              "parent_id" => root.id,
              "divisions" => []
            },
            {
              "id" => item.id,
              "name" => item.name,
              "code" => item.code,
              "active" => item.active?,
              "depth" => item.depth,
              "parent_id" => nil,
              "divisions" => []
            },
          ]
        }
      end
    end

    context "с отбором по корневому элементу" do

      before { get route, root_id: root.id }

      it "возвращает корректный ответ сервера" do
        response.should be_success
        response.status.should eq 200
      end

      it "верстает корректный JSON" do
        json = JSON.parse(response.body)
        json.should == {
          "success"  => true,
          "data" => [
            {
              "id" => root.id,
              "name" => root.name,
              "code" => root.code,
              "active" => root.active?,
              "depth" => root.depth,
              "parent_id" => nil,
              "divisions" => [div.id]
            },
            {
              "id" => div.id,
              "name" => div.name,
              "code" => div.code,
              "active" => div.active?,
              "depth" => div.depth,
              "parent_id" => root.id,
              "divisions" => []
            }
          ]
        }
      end
    end

    context "с отбором по строке" do

      before { get route, search: "ост" }

      it "возвращает корректный ответ сервера" do
        response.should be_success
        response.status.should eq 200
      end

      it "верстает корректный JSON" do
        json = JSON.parse(response.body)
        json.should == {
          "success"  => true,
          "data" => [
            {
              "id" => item.id,
              "name" => item.name,
              "code" => item.code,
              "active" => item.active?,
              "depth" => item.depth,
              "parent_id" => nil,
              "divisions" => []
            },
            {
              "id" => div.id,
              "name" => div.name,
              "code" => div.code,
              "active" => div.active?,
              "depth" => div.depth,
              "parent_id" => root.id,
              "divisions" => []
            }
          ]
        }
      end
    end

    context "с отбором по корневому элементу и строке" do

      before { get route, root_id: root.id, search: "ост" }

      it "возвращает корректный ответ сервера" do
        response.should be_success
        response.status.should eq 200
      end

      it "верстает корректный JSON" do
        json = JSON.parse(response.body)
        json.should == {
          "success"  => true,
          "data" => [
            {
              "id" => div.id,
              "name" => div.name,
              "code" => div.code,
              "active" => div.active?,
              "depth" => div.depth,
              "parent_id" => root.id,
              "divisions" => []
            }
          ]
        }
      end
    end

    context "если корневой элемент не найден" do

      before { item.destroy! }
      before { get route, root_id: item.id }

      it "возвращает корректный ответ сервера" do
        response.should_not be_success
        response.status.should eq 404
      end

      it "верстает корректный JSON" do
        json = JSON.parse(response.body)
        json.should == {
          "success"  => false,
          "messages" => [
            { "error" => "Поставщик/подразделение с ID: #{ item.id } не найден." }
          ],
          "data" => {}
        }
      end
    end
  end
end
