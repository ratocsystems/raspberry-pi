require "rails_helper"

RSpec.describe Gp10sController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/gp10s").to route_to("gp10s#index")
    end

    it "routes to #show" do
      expect(:get => "/gp10s/1").to route_to("gp10s#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/gp10s/1/edit").to route_to("gp10s#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/gp10s").to route_to("gp10s#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/gp10s/1").to route_to("gp10s#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/gp10s/1").to route_to("gp10s#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/gp10s/1").to route_to("gp10s#destroy", :id => "1")
    end

    it "routes to #list" do
      expect(:get => "/machines/1/gp10").to route_to("gp10s#list", :machine_id => "1")
    end

    it "routes to #group" do
      expect(:get => "/machines/1/gp10s").to route_to("gp10s#group", :machine_id => "1")
    end

  end
end
