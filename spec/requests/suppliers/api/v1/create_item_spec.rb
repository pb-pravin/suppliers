require "spec_helper"

module Suppliers
  describe "POST suppliers/api/v1/items" do

    # Маршрут и параметры запроса
    let!(:route)  { "suppliers/api/v1/items" }
    let!(:params) {{
      name: "Отдел поставки",
      code: "ОП",
      active: true
    }}

    context "с корректными параметрами" do

      before { post route, params }

      it "возвращает корректный ответ сервера" do
        response.should be_success
        response.status.should eq 201
      end

      it "возвращает корректный JSON" do
        json = JSON.parse(response.body)
        json.should == {
          "success"  => true,
          "messages" => [
            { "success" => "Поставщик/подразделение ОП: Отдел поставки добавлен в справочник." }
          ],
          "data" => {
            "id" => Item.last.id,
            "name" => "Отдел поставки",
            "code" => "ОП",
            "active" => true,
            "depth" => 0,
            "parent" => nil,
            "divisions" => []
          }
        }
      end

      it "добавляет запись в список поставщиков" do
        get route
        json = JSON.parse(response.body)
        json["data"].last["name"].should eq "Отдел поставки"
      end
    end

    context "если поставщик уже зарегистрирован" do

      let!(:item) { create(:item, code: "ОП") }
      before { post route, params }

      it "возвращает корректный ответ сервера" do
        response.should_not be_success
        response.status.should eq 422
      end

      it "возвращает корректный JSON" do
        json = JSON.parse(response.body)
        json.should == {
          "success"  => false,
          "messages" => [
            { "error" => "Поставщик/подразделение ОП: #{ item.name } уже зарегистрирован." }
          ],
          "data" => {}
        }
      end

      it "не добавляет запись в справочник" do
        get route
        json = JSON.parse(response.body)
        json["data"].count.should == 1
      end
    end

    context "с недопустимым названием" do

      before { params[:name] = "" }
      before { post route, params }

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

      it "не добавляет запись в справочник" do
        get route
        json = JSON.parse(response.body)
        json["data"].should be_blank
      end
    end

    context "с недопустимым кодом" do

      before { params[:code] = "" }
      before { post route, params }

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

      it "не добавляет запись в справочник" do
        get route
        json = JSON.parse(response.body)
        json["data"].should be_blank
      end
    end
  end
end
