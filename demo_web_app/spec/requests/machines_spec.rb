require 'rails_helper'

RSpec.describe "Machines", type: :request do
  describe "GET /machines" do
    it "works! (now write some real specs)" do
      get machines_path
      expect(response).to have_http_status(200)
    end
  end

  describe "DELETE /machines/:id" do
    let(:data) { create(:machine) }

	subject(:page) { delete machine_url data }

    it_behaves_like 'delete action test', Machine do
      let(:redirect_url) { machines_url }
    end
  end

  describe "PUT /machines/:id" do
    let(:data1) { create(:machine) }
    let(:data2) { attributes_for(:machine) }

    subject(:page) { put machine_url data1, params: { machine: data2 } }

    it_behaves_like 'update action test'  do
      let(:redirect_url) { machine_url data1 }
    end

    it "データが変更される" do
      data1
      data2
      expect { subject }.to change { Machine.find(data1.id).mac }.from(data1.mac).to(data2[:mac])
    end
  end
end
