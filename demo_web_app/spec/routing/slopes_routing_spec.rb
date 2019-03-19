require "rails_helper"

RSpec.describe SlopesController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/slopes").to route_to("slopes#index")
    end

    it "routes to #show" do
      expect(:get => "/slopes/1").to route_to("slopes#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/slopes/1/edit").to route_to("slopes#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/slopes").to route_to("slopes#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/slopes/1").to route_to("slopes#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/slopes/1").to route_to("slopes#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/slopes/1").to route_to("slopes#destroy", :id => "1")
    end

    it "routes to #list" do
      expect(:get => "/machines/1/slope").to route_to("slopes#list", :machine_id => "1")
    end

    it "routes to #group" do
      expect(:get => "/machines/1/slopes").to route_to("slopes#group", :machine_id => "1")
    end

  end
end
