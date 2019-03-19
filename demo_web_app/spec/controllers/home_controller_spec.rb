require 'rails_helper'

RSpec.describe HomeController, type: :controller do

  describe "GET #index" do
    subject(:page) { get :index, params: {} }

    it "returns a success response" do
      is_expected.to be_successful
    end
  end

end
