require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.
#
# Also compared to earlier versions of this generator, there are no longer any
# expectations of assigns and templates rendered. These features have been
# removed from Rails core in Rails 5, but can be added back in via the
# `rails-controller-testing` gem.

RSpec.describe Gp40sController, type: :controller do

  describe "GET #index" do
    let(:gp40) { create(:gp40) }

    subject(:page) { get :index, params: {} }

    it "returns a success response" do
      is_expected.to be_successful
    end
  end

  describe "GET #show" do
    let(:gp40) { create(:gp40) }

    subject(:page) { get :show, params: {id: gp40.id} }

    it "returns a success response" do
      is_expected.to be_successful
    end
  end

  describe "GET #edit" do
    let(:gp40) { create(:gp40) }

    subject(:page) { get :edit, params: {id: gp40.id} }

    it "returns a success response" do
      is_expected.to be_successful
    end
  end

  describe "PUT #update" do
    let(:gp40) { create(:gp40) }

    subject(:page) { put :update, params: {id: gp40.id, gp40: attributes_for(:gp40)} }

    it "returns a success response" do
      expect(response).to have_http_status(:ok)
    end
  end

  describe "DELETE #destroy" do
    let(:gp40) { create(:gp40) }

    subject(:page) { delete :destroy, params: {id: gp40.id} }

    it "returns a success response" do
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET #list" do
    let(:machine) { create(:machine) }
    let!(:gp40s) { [ gp40 ] }
    let(:gp40) { create(:gp40, {:machine_id => machine.id}) }

    subject(:page) { get :list, params: {machine_id: machine.id}}

    it "returns a success response" do
      is_expected.to be_successful
    end
  end

  describe "GET #group" do
    let(:machine) { create(:machine) }
    let!(:gp40s) { [ gp40 ] }
    let(:gp40) { create(:gp40, {:machine_id => machine.id}) }

    subject(:page) { get :group, params: {machine_id: machine.id}}

    it "returns a success response" do
      is_expected.to be_successful
    end
  end

  describe "POST #create" do
    let(:data) {
      {
        type: "gp40",
        item: {
          machine: {mac: Faker::Internet.mac_address},
          data: [
            date: Faker::Time.between(DateTime.now - 10, DateTime.now), beginning: Faker::Time.between(DateTime.now - 10, DateTime.now),
            ads: [
              { channel: 0, value: Faker::Number.between(0, 0xFFF), range: Faker::Number.between(0, 8) },
              { channel: 1, value: Faker::Number.between(0, 0xFFF), range: Faker::Number.between(0, 8) },
              { channel: 2, value: Faker::Number.between(0, 0xFFF), range: Faker::Number.between(0, 8) },
              { channel: 3, value: Faker::Number.between(0, 0xFFF), range: Faker::Number.between(0, 8) },
              { channel: 4, value: Faker::Number.between(0, 0xFFF), range: Faker::Number.between(0, 8) },
              { channel: 5, value: Faker::Number.between(0, 0xFFF), range: Faker::Number.between(0, 8) },
              { channel: 6, value: Faker::Number.between(0, 0xFFF), range: Faker::Number.between(0, 8) },
              { channel: 7, value: Faker::Number.between(0, 0xFFF), range: Faker::Number.between(0, 8) }
            ]
          ]
        }
      }
    }

    subject(:page) { post :create, body: data.to_json, as: :json }

    it "returns a success response" do
      is_expected.to be_successful
    end
  end
end