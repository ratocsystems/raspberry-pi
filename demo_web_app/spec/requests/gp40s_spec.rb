require 'rails_helper'

RSpec.describe "Gp40s", type: :request do
  def create_data
    data = {
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
    }
  end

  describe 'REQUEST Gp40s' do
    let(:now) { Time.current }
    let(:machine1) { create(:machine) }
    let(:machine2) { create(:machine) }

    describe 'GET /gp40s' do
      # 昨日、今日、明日のデータ
      let(:data1) { d = now.yesterday;  gp40 = create(:gp40, {:date => d}); create(:ad, {:gp40_id => gp40.id}); gp40 }
      let(:data2) { d = now;            gp40 = create(:gp40, {:date => d}); create(:ad, {:gp40_id => gp40.id}); gp40 }
      let(:data3) { d = now.tomorrow;   gp40 = create(:gp40, {:date => d}); create(:ad, {:gp40_id => gp40.id}); gp40 }

      # 2秒前から2秒後まで1秒ごとのデータ
      let(:data4) { d = now - 2.second; gp40 = create(:gp40, {:date => d}); create(:ad, {:gp40_id => gp40.id}); gp40 }
      let(:data5) { d = now - 1.second; gp40 = create(:gp40, {:date => d}); create(:ad, {:gp40_id => gp40.id}); gp40 }
      let(:data6) { d = now;            gp40 = create(:gp40, {:date => d}); create(:ad, {:gp40_id => gp40.id}); gp40 }
      let(:data7) { d = now + 1.second; gp40 = create(:gp40, {:date => d}); create(:ad, {:gp40_id => gp40.id}); gp40 }
      let(:data8) { d = now + 2.second; gp40 = create(:gp40, {:date => d}); create(:ad, {:gp40_id => gp40.id}); gp40 }

      describe 'by HTTP' do
        it_behaves_like 'get api test', 'by http', :index, :gp40s do
          subject(:page) { get gp40s_path, params: param }
        end
      end

      describe 'by JSON' do
        it_behaves_like 'get api test', 'by json', :index, :gp40s do
          subject(:page) { get gp40s_path, params: param, as: :json }
        end
      end
    end

    describe 'GET /machines/:machine_id/gp40' do
      # 昨日、今日、明日のデータ
      let(:data1) { d = now.yesterday;  gp40 = create(:gp40, {:machine_id => machine1.id, :date => d}); create(:ad, {:gp40_id => gp40.id}); gp40 }
      let(:data2) { d = now;            gp40 = create(:gp40, {:machine_id => machine1.id, :date => d}); create(:ad, {:gp40_id => gp40.id}); gp40 }
      let(:data3) { d = now.tomorrow;   gp40 = create(:gp40, {:machine_id => machine1.id, :date => d}); create(:ad, {:gp40_id => gp40.id}); gp40 }

      # 2秒前から2秒後まで1秒ごとのデータ
      let(:data4) { d = now - 2.second; gp40 = create(:gp40, {:machine_id => machine1.id, :date => d}); create(:ad, {:gp40_id => gp40.id}); gp40 }
      let(:data5) { d = now - 1.second; gp40 = create(:gp40, {:machine_id => machine1.id, :date => d}); create(:ad, {:gp40_id => gp40.id}); gp40 }
      let(:data6) { d = now;            gp40 = create(:gp40, {:machine_id => machine1.id, :date => d}); create(:ad, {:gp40_id => gp40.id}); gp40 }
      let(:data7) { d = now + 1.second; gp40 = create(:gp40, {:machine_id => machine1.id, :date => d}); create(:ad, {:gp40_id => gp40.id}); gp40 }
      let(:data8) { d = now + 2.second; gp40 = create(:gp40, {:machine_id => machine1.id, :date => d}); create(:ad, {:gp40_id => gp40.id}); gp40 }

      describe 'by HTTP' do
        it_behaves_like 'get api test', 'by http', :list, :gp40s do
          subject(:page) { get machine_gp40_path(machine1), params: param }
        end
      end

      describe 'by JSON' do
        it_behaves_like 'get api test', 'by json', :list, :gp40s do
          subject(:page) { get machine_gp40_path(machine1), params: param, as: :json }
        end
      end
    end

    describe 'GET /machines/:machine_id/gp40s' do
      # machine混在データ
      let(:dataA) { d = now;            gp40 = create(:gp40, {:machine_id => machine1.id, :beginning => d}); create(:ad, {:gp40_id => gp40.id}); gp40 }
      let(:dataB) { d = now + 1.second; gp40 = create(:gp40, {:machine_id => machine1.id, :beginning => d}); create(:ad, {:gp40_id => gp40.id}); gp40 }
      let(:dataC) { d = now + 2.second; gp40 = create(:gp40, {:machine_id => machine2.id, :beginning => d}); create(:ad, {:gp40_id => gp40.id}); gp40 }

      describe 'by HTTP' do
        it_behaves_like 'get group page test', 'by http', :group, :gp40s do
          subject(:page) { get machine_gp40s_path(machine1), params: { gp40_id: param } }
        end
      end

      describe 'by JSON' do
        it_behaves_like 'get group page test', 'by json', :group, :gp40s do
          subject(:page) { get machine_gp40s_path(machine1), params: { gp40_id: param }, as: :json }
        end
      end
    end
  end

  # memo request headerは as: キーワードで指定したらつけるようになっていると思われる
  describe 'POST /gp40s' do
    context 'データ数1' do
      let(:data) {
        {
          type: "gp40",
          item: {
            machine: {mac: Faker::Internet.mac_address},
            data: [
              create_data()
            ]
          }
        }
      }

      it_behaves_like 'post api test', Gp40, 1 do
        subject(:page) { post gp40s_path, params: data, as: :json }
      end
    end

    context 'データ数3' do
      let(:data) {
        {
          type: "gp40",
          item: {
            machine: {mac: Faker::Internet.mac_address},
            data: [
              create_data(),
              create_data(),
              create_data()
            ]
          }
        }
      }

      it_behaves_like 'post api test', Gp40, 3 do
        subject(:page) { post gp40s_path, params: data, as: :json }
      end
    end
  end

  describe 'DELETE /gp40s/:id' do
    let(:data) { create(:gp40) }

	subject(:page) { delete gp40_url data }

    it_behaves_like 'delete action test', Gp40 do
      let(:redirect_url) { gp40s_url }
    end
  end

  describe 'PUT /gp40s/:id' do
    let(:data1) { create(:gp40) }
    let(:data2) { create_data() }

    subject(:page) { put gp40_url data1, params: { gp40: data2 } }

    it_behaves_like 'update action test'  do
      let(:redirect_url) { gp40_url data1 }
    end

#    it 'データが変更される' do
#      data1
#      data2
#      expect { subject }.to change { Gp40.find(data1.id).di }.from(data1.di).to(data2[:di].to_i)
#    end
  end
end
