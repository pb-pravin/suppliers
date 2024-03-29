require "spec_helper"

module Suppliers
  describe "PATCH suppliers/api/v1/items/{id}" do

    # Начальные условия
    let!(:item) { create(:item) }

    # Маршрут и параметры запроса
    let!(:route)  { "suppliers/api/v1/items/#{ item.id }" }
    let!(:params) {{
      "name" => "Новое название",
      "code" => "НН",
      "active" => true
    }}

    context "с корректными параметрами" do

      before { patch route, params }

      it "возвращает корректный ответ сервера" do
        response.should be_success
        response.status.should eq 200
      end

      it "возвращает корректный JSON" do
        json = JSON.parse(response.body)
        json.should == {
          "success"  => true,
          "messages" => [
            { "success" => "Поставщик/подразделение НН: Новое название сохранен." }
          ],
          "data" => {
            "id" => item.id,
            "name" => "Новое название",
            "code" => "НН",
            "active" => true,
            "depth" => 0,
            "parent" => {},
            "divisions" => []
          }
        }
      end

      it "сохраняет изменения" do
        get route
        json = JSON.parse(response.body)
        json["data"]["name"].should eq params["name"]
        json["data"]["code"].should eq params["code"]
      end
    end

    context "если код уже зарегистрирован" do

      let!(:another_item) { create(:item, code: params["code"]) }
      before { patch route, params }

      it "возвращает корректный ответ сервера" do
        response.should_not be_success
        response.status.should eq 422
      end

      it "возвращает корректный JSON" do
        json = JSON.parse(response.body)
        json.should == {
          "success"  => false,
          "messages" => [
            { "error" => "Поставщик/подразделение #{ another_item.code }: #{ another_item.name } уже зарегистрирован." }
          ],
          "data" => {}
        }
      end

      it "не сохраняет изменения" do
        get route
        json = JSON.parse(response.body)
        json["data"]["name"].should_not eq params["name"]
        json["data"]["code"].should_not eq params["code"]
      end
    end

    context "с недопустимым названием" do

      before { params[:name] = "" }
      before { patch route, params }

      it "возвращает корректный ответ сервера" do
        response.should_not be_success
        response.status.should eq 422
      end

      it "возвращает корректный JSON" do
        json = JSON.parse(response.body)
        json.should == {
          "success"  => false,
          "messages" => [
            { "error" => "Необходимо указать название поставщика/подразделения." }
          ],
          "data" => {}
        }
      end

      it "не сохраняет изменения" do
        get route
        json = JSON.parse(response.body)
        json["data"]["code"].should_not eq "НН"
      end
    end

    context "с недопустимым кодом" do

      before { params[:code] = "" }
      before { patch route, params }

      it "возвращает корректный ответ сервера" do
        response.should_not be_success
        response.status.should eq 422
      end

      it "возвращает корректный JSON" do
        json = JSON.parse(response.body)
        json.should == {
          "success"  => false,
          "messages" => [
            { "error" => "Необходимо указать код поставщика/подразделения." }
          ],
          "data" => {}
        }
      end

      it "не сохраняет изменения" do
        get route
        json = JSON.parse(response.body)
        json["data"]["name"].should_not eq "Новое название"
      end
    end

    context "если запись не найдена" do

      before { item.destroy! }
      before { patch route, params }

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
