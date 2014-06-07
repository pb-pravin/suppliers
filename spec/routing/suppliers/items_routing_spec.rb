# encoding: utf-8
require 'spec_helper'

module Suppliers
  describe "items routing" do
    routes { Suppliers::Engine.routes }

    let!(:root) { "api/v1/items"}

    describe "#index" do

      let!(:action) {{ controller: "suppliers/#{root}", action: "index" }}

      it "доступен в json" do
        action[:format] = "json"
        expect(get: "/#{root}").to route_to action
      end
    end

    describe "#create" do

      let!(:action) {{ controller: "suppliers/#{root}", action: "create" }}

      it "доступен в json" do
        action[:format] = "json"
        expect(post: "/#{root}").to route_to action
      end
    end

    describe "#merge" do

      let!(:action) {{ controller: "suppliers/#{root}", action: "merge" }}

      it "доступен в json" do
        action[:format] = "json"
        expect(put: "/#{root}").to route_to action
      end
    end

    describe "#show" do

      let!(:action) {{ controller: "suppliers/#{root}", action: "show", id: "1" }}

      it "доступен в json" do
        action[:format] = "json"
        expect(get: "/#{root}/1").to route_to action
      end
    end

    describe "#update" do

      let!(:action) {{ controller: "suppliers/#{root}", action: "update", id: "1" }}

      it "доступен в json" do
        action[:format] = "json"
        expect(patch: "/#{root}/1").to route_to action
      end
    end

    describe "#create (подразделение)" do

      let!(:action) {{ controller: "suppliers/#{root}", action: "create", parent_id: "1" }}

      it "доступен в json" do
        action[:format] = "json"
        expect(post: "/#{root}/1").to route_to action
      end
    end

    describe "#move" do

      let!(:action) {{ controller: "suppliers/#{root}", action: "move", parent_id: "1" }}

      it "доступен в json" do
        action[:format] = "json"
        expect(put: "/#{root}/1").to route_to action
      end
    end

    describe "#destroy" do

      let!(:action) {{ controller: "suppliers/#{root}", action: "destroy", id: "1" }}

      it "доступен в json" do
        action[:format] = "json"
        expect(delete: "/#{root}/1").to route_to action
      end
    end
  end
end
