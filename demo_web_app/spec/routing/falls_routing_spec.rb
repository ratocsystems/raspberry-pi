require "rails_helper"

RSpec.describe FallsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/falls").to route_to("falls#index")
    end

    it "routes to #show" do
      expect(:get => "/falls/1").to route_to("falls#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/falls/1/edit").to route_to("falls#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/falls").to route_to("falls#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/falls/1").to route_to("falls#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/falls/1").to route_to("falls#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/falls/1").to route_to("falls#destroy", :id => "1")
    end

    it "routes to #list" do
      expect(:get => "/machines/1/fall").to route_to("falls#list", :machine_id => "1")
    end

    it "routes to #group" do
      expect(:get => "/machines/1/falls").to route_to("falls#group", :machine_id => "1")
    end

  end
end
