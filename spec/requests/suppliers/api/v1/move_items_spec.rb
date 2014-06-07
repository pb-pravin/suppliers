require "spec_helper"

module Suppliers
  describe "PUT suppliers/api/v1/items/{id}" do

    # Начальные условия
    let!(:parent) { create(:parent) }
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

      it "верстает корректный JSON" do
        json = JSON.parse(response.body)
        json.should == {
          "success"  => true,
          "messages" => [
            { "success" => "TODO" }
          ],
          "data" => {
            # TODO
          }
        }
      end

      it "добавляет подразделения" do
        get check_route
        json = JSON.parse(response.body)
        json["data"]["divisions"].should == [item.id]
      end
    end

    context "при попытке перенести поставщика в его собственное подразделение" do

      before { parent.update_attributes! parent: item }
      before { put route, params }

      it "возвращает корректный ответ сервера" do
        response.should_not be_success
        response.status.should eq 422
      end

      it "верстает корректный JSON" do
        json = JSON.parse(response.body)
        json.should == {
          "success"  => false,
          "messages" => [
            { "error" => "Нельзя перенести поставщика/подразделение #{ item.id }: #{ item.name } в состав его собственного подразделения." }
          ],
          "data" => {}
        }
      end

      it "не добавляет подразделения" do
        get check_route
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

      it "верстает корректный JSON" do
        json = JSON.parse(response.body)
        json.should == {
          "success"  => false,
          "messages" => [
            { "error" => "Поставщик/подразделени с ID: #{ parent.id } не найден." }
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

      it "верстает корректный JSON" do
        json = JSON.parse(response.body)
        json.should == {
          "success"  => false,
          "messages" => [
            { "error" => "Поставщик/подразделени с ID: #{ item.id } не найден." }
          ],
          "data" => {}
        }
      end
    end
  end
end
