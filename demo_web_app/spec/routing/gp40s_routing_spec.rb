require "rails_helper"

RSpec.describe Gp40sController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/gp40s").to route_to("gp40s#index")
    end

    it "routes to #show" do
      expect(:get => "/gp40s/1").to route_to("gp40s#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/gp40s/1/edit").to route_to("gp40s#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/gp40s").to route_to("gp40s#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/gp40s/1").to route_to("gp40s#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/gp40s/1").to route_to("gp40s#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/gp40s/1").to route_to("gp40s#destroy", :id => "1")
    end

    it "routes to #list" do
      expect(:get => "/machines/1/gp40").to route_to("gp40s#list", :machine_id => "1")
    end

    it "routes to #group" do
      expect(:get => "/machines/1/gp40s").to route_to("gp40s#group", :machine_id => "1")
    end

  end
end
