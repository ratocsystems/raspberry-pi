require 'rails_helper'

RSpec.describe "Falls", type: :request do
  describe 'REQUEST Falls' do
    let(:now) { Time.current }
    let(:machine1) { create(:machine) }
    let(:machine2) { create(:machine) }

    describe 'GET /falls' do
      # 昨日、今日、明日のデータ
      let(:data1) { d = now.yesterday;  create(:fall, {:date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }
      let(:data2) { d = now;            create(:fall, {:date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }
      let(:data3) { d = now.tomorrow;   create(:fall, {:date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }

      # 2秒前から2秒後まで1秒ごとのデータ
      let(:data4) { d = now - 2.second; create(:fall, {:date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }
      let(:data5) { d = now - 1.second; create(:fall, {:date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }
      let(:data6) { d = now;            create(:fall, {:date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }
      let(:data7) { d = now + 1.second; create(:fall, {:date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }
      let(:data8) { d = now + 2.second; create(:fall, {:date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }

      describe 'by HTTP' do
        it_behaves_like 'get api test', 'by http', :index, :falls do
          subject(:page) { get falls_path, params: param }
        end
      end

      describe 'by JSON' do
        it_behaves_like 'get api test', 'by json', :index, :falls do
          subject(:page) { get falls_path, params: param, as: :json }
        end
      end
    end

    describe 'GET /machines/:machine_id/fall' do
      # 昨日、今日、明日のデータ
      let(:data1) { d = now.yesterday;  create(:fall, {:machine_id => machine1.id, :date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }
      let(:data2) { d = now;            create(:fall, {:machine_id => machine1.id, :date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }
      let(:data3) { d = now.tomorrow;   create(:fall, {:machine_id => machine1.id, :date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }

      # 2秒前から2秒後まで1秒ごとのデータ
      let(:data4) { d = now - 2.second; create(:fall, {:machine_id => machine1.id, :date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }
      let(:data5) { d = now - 1.second; create(:fall, {:machine_id => machine1.id, :date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }
      let(:data6) { d = now;            create(:fall, {:machine_id => machine1.id, :date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }
      let(:data7) { d = now + 1.second; create(:fall, {:machine_id => machine1.id, :date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }
      let(:data8) { d = now + 2.second; create(:fall, {:machine_id => machine1.id, :date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }

      describe 'by HTTP' do
        it_behaves_like 'get api test', 'by http', :list, :falls do
          subject(:page) { get machine_fall_path(machine1), params: param }
        end
      end

      describe 'by JSON' do
        it_behaves_like 'get api test', 'by json', :list, :falls do
          subject(:page) { get machine_fall_path(machine1), params: param, as: :json }
        end
      end
    end

    describe 'GET /machines/:machine_id/falls' do
      # machine混在データ
      let(:dataA) { d = now;            create(:fall, {:machine_id => machine1.id, :beginning => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }
      let(:dataB) { d = now + 1.second; create(:fall, {:machine_id => machine1.id, :beginning => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }
      let(:dataC) { d = now + 2.second; create(:fall, {:machine_id => machine2.id, :beginning => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }

      describe 'by HTTP' do
        it_behaves_like 'get group page test', 'by http', :group, :falls do
          subject(:page) { get machine_falls_path(machine1), params: { fall_id: param } }
        end
      end

      describe 'by JSON' do
        it_behaves_like 'get group page test', 'by json', :group, :falls do
          subject(:page) { get machine_falls_path(machine1), params: { fall_id: param }, as: :json }
        end
      end
    end
  end

  # memo request headerは as: キーワードで指定したらつけるようになっていると思われる
  describe 'POST /falls' do
    context 'データ数1' do
      let(:data) {
        {
          type: "fall",
          item: {
            machine: {mac: Faker::Internet.mac_address},
            data: [
              attributes_for(:fall)
            ]
          }
        }
      }

      it_behaves_like 'post api test', Fall, 1 do
        subject(:page) { post falls_path, params: data, as: :json }
      end
    end

    context 'データ数3' do
      let(:data) {
        {
          type: "fall",
          item: {
            machine: {mac: Faker::Internet.mac_address},
            data: [
              attributes_for(:fall),
              attributes_for(:fall),
              attributes_for(:fall)
            ]
          }
        }
      }

      it_behaves_like 'post api test', Fall, 3 do
        subject(:page) { post falls_path, params: data, as: :json }
      end
    end
  end

  describe 'DELETE /falls/:id' do
    let(:data) { create(:fall) }

	subject(:page) { delete fall_url data }

    it_behaves_like 'delete action test', Fall do
      let(:redirect_url) { falls_url }
    end
  end

  describe 'PUT /falls/:id' do
    let(:data1) { create(:fall) }
    let(:data2) { attributes_for(:fall) }

    subject(:page) { put fall_url data1, params: { fall: data2 } }

    it_behaves_like 'update action test'  do
      let(:redirect_url) { fall_url data1 }
    end

    it 'データが変更される' do
      data1
      data2
      expect { subject }.to change { Fall.find(data1.id).count }.from(data1.count).to(data2[:count].to_i)
    end
  end
end
