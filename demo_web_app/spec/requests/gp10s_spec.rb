require 'rails_helper'

RSpec.describe "Gp10s", type: :request do
  describe 'REQUEST Gp10s' do
    let(:now) { Time.current }
    let(:machine1) { create(:machine) }
    let(:machine2) { create(:machine) }

    describe 'GET /gp10s' do
      # 昨日、今日、明日のデータ
      let(:data1) { d = now.yesterday;  create(:gp10, {:date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }
      let(:data2) { d = now;            create(:gp10, {:date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }
      let(:data3) { d = now.tomorrow;   create(:gp10, {:date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }

      # 2秒前から2秒後まで1秒ごとのデータ
      let(:data4) { d = now - 2.second; create(:gp10, {:date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }
      let(:data5) { d = now - 1.second; create(:gp10, {:date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }
      let(:data6) { d = now;            create(:gp10, {:date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }
      let(:data7) { d = now + 1.second; create(:gp10, {:date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }
      let(:data8) { d = now + 2.second; create(:gp10, {:date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }

      describe 'by HTTP' do
        it_behaves_like 'get api test', 'by http', :index, :gp10s do
          subject(:page) { get gp10s_path, params: param }
        end
      end

      describe 'by JSON' do
        it_behaves_like 'get api test', 'by json', :index, :gp10s do
          subject(:page) { get gp10s_path, params: param, as: :json }
        end
      end
    end

    describe 'GET /machines/:machine_id/gp10' do
      # 昨日、今日、明日のデータ
      let(:data1) { d = now.yesterday;  create(:gp10, {:machine_id => machine1.id, :date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }
      let(:data2) { d = now;            create(:gp10, {:machine_id => machine1.id, :date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }
      let(:data3) { d = now.tomorrow;   create(:gp10, {:machine_id => machine1.id, :date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }

      # 2秒前から2秒後まで1秒ごとのデータ
      let(:data4) { d = now - 2.second; create(:gp10, {:machine_id => machine1.id, :date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }
      let(:data5) { d = now - 1.second; create(:gp10, {:machine_id => machine1.id, :date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }
      let(:data6) { d = now;            create(:gp10, {:machine_id => machine1.id, :date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }
      let(:data7) { d = now + 1.second; create(:gp10, {:machine_id => machine1.id, :date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }
      let(:data8) { d = now + 2.second; create(:gp10, {:machine_id => machine1.id, :date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }

      describe 'by HTTP' do
        it_behaves_like 'get api test', 'by http', :list, :gp10s do
          subject(:page) { get machine_gp10_path(machine1), params: param }
        end
      end

      describe 'by JSON' do
        it_behaves_like 'get api test', 'by json', :list, :gp10s do
          subject(:page) { get machine_gp10_path(machine1), params: param, as: :json }
        end
      end
    end

    describe 'GET /machines/:machine_id/gp10s' do
      # machine混在データ
      let(:dataA) { d = now;            create(:gp10, {:machine_id => machine1.id, :beginning => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }
      let(:dataB) { d = now + 1.second; create(:gp10, {:machine_id => machine1.id, :beginning => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }
      let(:dataC) { d = now + 2.second; create(:gp10, {:machine_id => machine2.id, :beginning => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }

      describe 'by HTTP' do
        it_behaves_like 'get group page test', 'by http', :group, :gp10s do
          subject(:page) { get machine_gp10s_path(machine1), params: { gp10_id: param } }
        end
      end

      describe 'by JSON' do
        it_behaves_like 'get group page test', 'by json', :group, :gp10s do
          subject(:page) { get machine_gp10s_path(machine1), params: { gp10_id: param }, as: :json }
        end
      end
    end
  end

  # memo request headerは as: キーワードで指定したらつけるようになっていると思われる
  describe 'POST /gp10s' do
    context 'データ数1' do
      let(:data) {
        {
          type: "gp10",
          item: {
            machine: {mac: Faker::Internet.mac_address},
            data: [
              attributes_for(:gp10)
            ]
          }
        }
      }

      it_behaves_like 'post api test', Gp10, 1 do
        subject(:page) { post gp10s_path, params: data, as: :json }
      end
    end

    context 'データ数3' do
      let(:data) {
        {
          type: "gp10",
          item: {
            machine: {mac: Faker::Internet.mac_address},
            data: [
              attributes_for(:gp10),
              attributes_for(:gp10),
              attributes_for(:gp10)
            ]
          }
        }
      }

      it_behaves_like 'post api test', Gp10, 3 do
        subject(:page) { post gp10s_path, params: data, as: :json }
      end
    end
  end

  describe 'DELETE /gp10s/:id' do
    let(:data) { create(:gp10) }

	subject(:page) { delete gp10_url data }

    it_behaves_like 'delete action test', Gp10 do
      let(:redirect_url) { gp10s_url }
    end
  end

  describe 'PUT /gp10s/:id' do
    let(:data1) { create(:gp10) }
    let(:data2) { attributes_for(:gp10) }

    subject(:page) { put gp10_url data1, params: { gp10: data2 } }

    it_behaves_like 'update action test'  do
      let(:redirect_url) { gp10_url data1 }
    end

    it 'データが変更される' do
      data1
      data2
      expect { subject }.to change { Gp10.find(data1.id).di }.from(data1.di).to(data2[:di].to_i)
    end
  end
end
