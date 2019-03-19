require "rails_helper"

RSpec.describe WbgtsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/wbgts").to route_to("wbgts#index")
    end

    it "routes to #show" do
      expect(:get => "/wbgts/1").to route_to("wbgts#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/wbgts/1/edit").to route_to("wbgts#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/wbgts").to route_to("wbgts#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/wbgts/1").to route_to("wbgts#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/wbgts/1").to route_to("wbgts#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/wbgts/1").to route_to("wbgts#destroy", :id => "1")
    end

    it "routes to #list" do
      expect(:get => "/machines/1/wbgt").to route_to("wbgts#list", :machine_id => "1")
    end

    it "routes to #group" do
      expect(:get => "/machines/1/wbgts").to route_to("wbgts#group", :machine_id => "1")
    end

  end
end
