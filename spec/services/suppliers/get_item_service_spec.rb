# encoding: utf-8
require "spec_helper"

module Suppliers
  describe GetItemService do

    let!(:listener) { double "listener" }
    let!(:item)     { create(:item) }
    let!(:params)   {{ id: item.id }}

    describe "#run!" do

      context "с корректными параметрами" do

        let!(:service) { GetItemService.new params }
        before { service.subscribe listener }

        it "публикует сообщение :found" do
          listener.should_receive(:found) do |result|
            result.should eq item
          end
          service.run!
        end
      end

      context "если поставщик не найден" do

        before { item.destroy! }

        let!(:service) { GetItemService.new params }
        before { service.subscribe listener }

        it "публикует сообщение, что поставщик не найден" do
          listener.should_receive(:not_found) do |id|
            id.should eq params[:id]
          end
          service.run!
        end
      end
    end
  end
end
