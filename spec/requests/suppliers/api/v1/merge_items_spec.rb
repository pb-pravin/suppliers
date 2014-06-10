require "spec_helper"

module Suppliers
  describe "PUT suppliers/api/v1/items" do

    # Начальные условия
    let!(:item)   { create(:item) }
    let!(:parent) { create(:item) }
    let!(:div)    { create(:item, parent: item) }
    before { item.update_attributes parent: parent }

    # Маршрут и параметры запроса
    let!(:route)  { "suppliers/api/v1/items" }
    let!(:params) {{ ids: [item.id, parent.id] }}

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
            { "success" => "Выбранные записи объединены c #{ parent.code }: #{ parent.name }." }
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
                "id"     => div.id,
                "name"   => div.name,
                "code"   => div.code,
                "active" => div.active?
              }
            ]
          }
        }
      end

      it "объединяет записи" do
        get route
        json = JSON.parse(response.body)
        json["data"].count.should eq 2
      end
    end

    context "если выбрано меньше двух разных записей" do

      let!(:params) {{ ids: [item.id, item.id] }}
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
            { "error" => "Для объединения необходимо выбрать не менее двух поставщиков/подразделений." }
          ],
          "data" => {}
        }
      end
    end

    context "если одна из записей не найдена" do

      before { params[:ids] << 0 }
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
            { "error" => "Поставщик/подразделение с ID: 0 не найден." }
          ],
          "data" => {}
        }
      end
    end
  end
end
