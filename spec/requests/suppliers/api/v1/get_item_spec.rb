require "spec_helper"

module Suppliers
  describe "GET suppliers/api/v1/items/{id}" do

    # Начальные условия
    let!(:parent){ create(:item) }
    let!(:item)  { create(:item, parent: parent) }
    let!(:div)   { create(:item, parent: item) }

    # Маршрут и параметры запроса
    let!(:route)  { "suppliers/api/v1/items/#{ item.id }" }

    context "с корректными параметрами" do

      before { get route }

      it "возвращает корректный ответ сервера" do
        response.should be_success
        response.status.should eq 200
      end

      it "возвращает корректный JSON" do
        json = JSON.parse(response.body)
        json.should == {
          "success"  => true,
          "data" => {
            "id" =>     item.id,
            "name" =>   item.name,
            "code" =>   item.code,
            "active" => item.active?,
            "depth" =>  1,
            "parent" => {
              "id" =>     parent.id,
              "name" =>   parent.name,
              "code" =>   parent.code,
              "active" => parent.active?
            },
            "divisions" => [
              {
                "id" =>     div.id,
                "name" =>   div.name,
                "code" =>   div.code,
                "active" => div.active?
              }
            ]
          }
        }
      end
    end

    context "если запись не найдена" do

      before { item.destroy! }
      before { get route }

      it "возвращает корректный ответ сервера" do
        response.should_not be_success
        response.status.should eq 404
      end

      it "возвращает корректный JSON" do
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
