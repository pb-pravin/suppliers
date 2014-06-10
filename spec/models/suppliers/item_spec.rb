require 'spec_helper'

module Suppliers
  describe Item do

    describe "#name=" do

      let!(:item) { build(:item) }

      it "изменяет название поставщика" do
        expect{ item.name = "Новое имя" }.to change{ item.name }.to "Новое имя"
      end

      it "удаляет концевые и повторные пробелы" do
        expect{ item.name = " Новое   имя " }.to change{ item.name }.to "Новое имя"
      end

      it "присваивает nil вместо пустой строки" do
        expect{ item.name = "" }.to change{ item.name }.to nil
      end
    end

    describe "#code=" do

      let!(:item) { build(:item) }

      it "изменяет код поставщика" do
        expect{ item.name = "Новый код" }.to change{ item.name }.to "Новый код"
      end

      it "удаляет концевые и повторные пробелы" do
        expect{ item.name = "  Новый  код " }.to change{ item.name }.to "Новый код"
      end

      it "присваивает nil вместо пустой строки" do
        expect{ item.name = "" }.to change{ item.name }.to nil
      end
    end

    describe "#active" do

      let!(:item) { build(:item) }

      it "присваивает признак, разрешающий выбирать подразделение в документах" do
        item.active = true
        item.should be_active
        item.active = false
        item.should_not be_active
      end
    end

    describe "#parent=" do

      let!(:item) { build(:item) }

      it "присваивает ссылку на вышестоящее подразделение" do
        parent = create(:item)
        expect{ item.parent = parent }.to change{ item.parent }.to parent
      end
    end

    describe "#divisions" do

      let!(:parent)   { create(:item) }
      let!(:item)     { create(:item, parent: parent) }
      let!(:division) { create(:item, parent: item) }

      it "возвращает список подразделений поставщика" do
        parent.reload.divisions.to_a.should eq [item]
        item.reload.divisions.to_a.should eq [division]
      end
    end

    describe "#branch" do

      let!(:parent)   { create(:item) }
      let!(:item)     { create(:item, parent: parent) }
      let!(:division) { create(:item, parent: item) }
      before { create(:item) }

      it "возвращает список всех подразделений ветки (включая поставщика)" do
        parent.reload.branch.to_a.should   eq [parent, item, division]
        item.reload.branch.to_a.should     eq [item, division]
        division.reload.branch.to_a.should eq [division]
      end
    end

    describe "#links" do

      let!(:parent) { create(:item) }
      let!(:item)   { create(:item, parent: parent) }
      let!(:link)   { create(:link, item: parent) }

      it "возвращает список ссылок на поставщика в базе данных" do
        links = parent.reload.links.map(&:record)
        links.include?(link).should be_truthy
        links.include?(item).should be_truthy
      end
    end

    describe "#valid?" do

      let!(:item) { build(:item) }
      before { item.should be_valid }

      it "возвращает false если название не указано" do
        item.name = nil
        item.should_not be_valid
        item.should have_errors
      end

      it "возвращает false если код не указан" do
        item.code = nil
        item.should_not be_valid
        item.should have_errors
      end

      it "возвращает false если код не уникален" do
        create(:item, code: item.code)
        item.should_not be_valid
        item.should have_errors
      end

      it "возвращает false если вышестоящее подразделение является собственным подразделением" do
        item.save!
        division = create(:item, parent: item)
        item.reload
        item.parent = division
        item.should_not be_valid
        item.should have_errors
      end

      it "возвращает false если вышестоящее подразделение является ссылкой на сам объект" do
        item.save!
        item.parent = item
        item.should_not be_valid
        item.should have_errors
      end
    end

    describe "#destroy!" do

      let!(:item) { create(:item) }

      it "вызывает исключение, если на запись есть ссылки" do
        create(:link, item: item)
        expect{ item.destroy! }.to raise_error
      end

      it "добавляет ошибки в массив" do
        create(:link, item: item)
        begin; item.destroy!; rescue; end
        item.should have_errors
      end
    end

    describe "::by_string" do

      before { create(:item) }

      it "отбирает поставщиков по подстроке кода" do
        item = create(:item, code: "Microsoft")
        Item.by_string("CROS").to_a.should eq [item]
      end

      it "отбирает поставщиков по подстроке названия" do
        item = create(:item, name: "Apple")
        Item.by_string("app").to_a.should eq [item]
      end
    end
  end
end
