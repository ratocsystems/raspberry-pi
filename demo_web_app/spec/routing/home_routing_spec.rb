require "rails_helper"

RSpec.describe HomeController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/").to route_to("home#index")
    end

    it "routes to #autoupdate" do
      expect(:post => "/").to route_to("home#autoupdate")
    end

  end
end
