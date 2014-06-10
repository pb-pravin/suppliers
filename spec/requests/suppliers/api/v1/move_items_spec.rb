require "spec_helper"

module Suppliers
  describe "PUT suppliers/api/v1/items/{id}" do

    # Начальные условия
    let!(:parent) { create(:item) }
    let!(:item)   { create(:item) }

    # Маршрут и параметры запроса
    let!(:route)  { "suppliers/api/v1/items/#{ parent.id }" }
    let!(:params) {{ ids: [item.id] }}

    context "с корректными параметрами" do

      before { put route, params }

      it "возвращает корректный ответ сервера" do
        response.should be_success
        response.status.should eq 200
      end

      it "возвращает корректный JSON" do
        json = JSON.parse(response.body)
        json.should == {
          "success"  => true,
          "messages" => [
            { "success" => "Выбранные подразделения включены в состав #{ parent.code }: #{ parent.name }." }
          ],
          "data" => {
            "id"     => parent.id,
            "name"   => parent.name,
            "code"   => parent.code,
            "active" => parent.active?,
            "depth"  => 0,
            "parent" => {},
            "divisions" => [
              {
                "id"     => item.id,
                "name"   => item.name,
                "code"   => item.code,
                "active" => item.active?
              }
            ]
          }
        }
      end

      it "добавляет подразделения" do
        get route
        json = JSON.parse(response.body)
        json["data"]["divisions"].first["id"].should == item.id
      end
    end

    context "при попытке перенести поставщика в его собственное подразделение" do

      before { parent.update_attributes! parent: item }
      before { put route, params }

      it "возвращает корректный ответ сервера" do
        response.should_not be_success
        response.status.should eq 422
      end

      it "возвращает корректный JSON" do
        json = JSON.parse(response.body)
        json.should == {
          "success"  => false,
          "messages" => [
            { "error" => "Поставщик/подразделение #{item.code}: #{item.name} не может быть частью своего подразделения #{parent.code}: #{parent.name}." }
          ],
          "data" => {}
        }
      end

      it "не добавляет подразделения" do
        get route
        json = JSON.parse(response.body)
        json["data"]["divisions"].should be_blank
      end
    end

    context "если текущий поставщик не найден" do

      before { parent.destroy! }
      before { put route, params }

      it "возвращает корректный ответ сервера" do
        response.should_not be_success
        response.status.should eq 404
      end

      it "возвращает корректный JSON" do
        json = JSON.parse(response.body)
        json.should == {
          "success"  => false,
          "messages" => [
            { "error" => "Поставщик/подразделение с ID: #{ parent.id } не найден." }
          ],
          "data" => {}
        }
      end
    end

    context "если поставщик для переноса не найден" do

      before { item.destroy! }
      before { put route, params }

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
