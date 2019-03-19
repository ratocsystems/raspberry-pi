require 'rails_helper'

RSpec.describe "Home", type: :request do
  describe "GET /" do
    subject(:page) { get root_path }

    it "works! (now write some real specs)" do
      subject
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /" do
    let(:url) { "http://example.com/" }

    context 'autoupdate is on' do
      subject(:page) { post root_path(autoupdate: "on", redirect: url) }

      it "works! (now write some real specs)" do
        subject
        expect(response).to have_http_status(:found)
      end

      it "redirect_to" do
        subject
        expect(response).to redirect_to(url)
      end
    end

    context 'autoupdate is off' do
      subject(:page) { post root_path(autoupdate: "off", redirect: url) }

      it "works! (now write some real specs)" do
        subject
        expect(response).to have_http_status(:found)
      end

      it "redirect_to" do
        subject
        expect(response).to redirect_to(url)
      end
    end
  end
end
