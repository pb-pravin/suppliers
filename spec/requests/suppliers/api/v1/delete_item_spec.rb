require "spec_helper"

module Suppliers
  describe "DELETE suppliers/api/v1/items/{id}" do

    # Начальные условия
    let!(:item) { create(:item) }

    # Маршрут и параметры запроса
    let!(:route)  { "suppliers/api/v1/items/#{ item.id }" }

    context "с корректными параметрами" do

      before { delete route, params }

      it "возвращает корректный ответ сервера" do
        response.should be_success
        response.status.should eq 200
      end

      it "верстает корректный JSON" do
        json = JSON.parse(response.body)
        json.should == {
          "success"  => true,
          "messages" => [
            { "success" => "Поставщик/подразделение #{ item.code }: #{ item.name } удален." }
          ],
          "data" => {
            "id" => item.id,
            "name" => item.name,
            "code" => item.code,
            "active" => item.active?,
            "depth" => 0,
            "parent" => nil,
            "divisions" => []
          }
        }
      end

      it "удаляет запись" do
        get route
        response.should_not be_success
      end
    end

    context "если на запись есть ссылки в базе данных" do

      before { create(:item, parent: item) }
      before { delete route, params }

      it "возвращает корректный ответ сервера" do
        response.should_not be_success
        response.status.should eq 422
      end

      it "верстает корректный JSON" do
        json = JSON.parse(response.body)
        json.should == {
          "success"  => false,
          "messages" => [
            { "error" => "Перед удалением поставщика/подразделения #{ item.code }: #{ item.name } необходимо удалить все ссылки на запись в базе данных." }
          ],
          "data" => {}
        }
      end

      it "не удаляет запись" do
        get route
        response.should be_success
      end
    end

    context "если запись не найдена" do

      before { item.destroy! }
      before { delete route, params }

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
