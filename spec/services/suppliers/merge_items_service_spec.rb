# encoding: utf-8
require "spec_helper"

module Suppliers
  describe MergeItemsService do

    let!(:listener) { double "listener" }
    let!(:params)   {{ TODO: TODO }}

    pending "#run" do

      context "с корректными параметрами" do

        let!(:service) { MergeItemsService.new params }
        before { service.subscribe listener }

        it "TODO" do
          expect{ service.run }.to TODO
        end

        it "публикует сообщение об успешном завершении операции" do
          listener.should_receive(:TODO) do |result|
            result.should TODO
          end
          service.run
        end
      end

      context "с TODO" do

        before { params[:TODO] = TODO }

        let!(:service) { MergeItemsService.new params }
        before { service.subscribe listener }

        it "TODO" do
          expect{ service.run }.to TODO
        end

        it "публикует сообщение об ошибке" do
          listener.should_receive(:error) do |messages|
            messages.should_not be_blank
          end
          service.run
        end
      end

      context "если TODO не найден" do

        before { TODO.destroy! }

        let!(:service) { MergeItemsService.new params }
        before { service.subscribe listener }

        it "публикует сообщение, что TODO не найден" do
          listener.should_receive(:not_found) do |id|
            id.should eq params[:TODO]
          end
          service.run
        end
      end
    end
  end
end
