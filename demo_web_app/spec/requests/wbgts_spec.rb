require 'rails_helper'

RSpec.describe "Wbgts", type: :request do
  describe 'REQUEST Wbgt' do
    let(:now) { Time.current }
    let(:machine1) { create(:machine) }
    let(:machine2) { create(:machine) }

    describe 'GET /wbgts' do
      # 昨日、今日、明日のデータ
      let(:data1) { d = now.yesterday;  create(:wbgt, {:date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }
      let(:data2) { d = now;            create(:wbgt, {:date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }
      let(:data3) { d = now.tomorrow;   create(:wbgt, {:date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }

      # 2秒前から2秒後まで1秒ごとのデータ
      let(:data4) { d = now - 2.second; create(:wbgt, {:date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }
      let(:data5) { d = now - 1.second; create(:wbgt, {:date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }
      let(:data6) { d = now;            create(:wbgt, {:date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }
      let(:data7) { d = now + 1.second; create(:wbgt, {:date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }
      let(:data8) { d = now + 2.second; create(:wbgt, {:date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }

      describe 'by HTTP' do
        it_behaves_like 'get api test', 'by http', :index, :wbgts do
          subject(:page) { get wbgts_path, params: param }
        end
      end

      describe 'by JSON' do
        it_behaves_like 'get api test', 'by json', :index, :wbgts do
          subject(:page) { get wbgts_path, params: param, as: :json }
        end
      end
    end

    describe 'GET /machines/:machine_id/wbgt' do
      # 昨日、今日、明日のデータ
      let(:data1) { d = now.yesterday;  create(:wbgt, {:machine_id => machine1.id, :date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }
      let(:data2) { d = now;            create(:wbgt, {:machine_id => machine1.id, :date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }
      let(:data3) { d = now.tomorrow;   create(:wbgt, {:machine_id => machine1.id, :date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }

      # 2秒前から2秒後まで1秒ごとのデータ
      let(:data4) { d = now - 2.second; create(:wbgt, {:machine_id => machine1.id, :date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }
      let(:data5) { d = now - 1.second; create(:wbgt, {:machine_id => machine1.id, :date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }
      let(:data6) { d = now;            create(:wbgt, {:machine_id => machine1.id, :date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }
      let(:data7) { d = now + 1.second; create(:wbgt, {:machine_id => machine1.id, :date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }
      let(:data8) { d = now + 2.second; create(:wbgt, {:machine_id => machine1.id, :date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }

      describe 'by HTTP' do
        it_behaves_like 'get api test', 'by http', :list, :wbgts do
          subject(:page) { get machine_wbgt_path(machine1), params: param }
        end
      end

      describe 'by JSON' do
        it_behaves_like 'get api test', 'by json', :list, :wbgts do
          subject(:page) { get machine_wbgt_path(machine1), params: param, as: :json }
        end
      end
    end

    describe 'GET /machines/:machine_id/wbgts' do
      # machine混在データ
      let(:dataA) { d = now;            create(:wbgt, {:machine_id => machine1.id, :beginning => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }
      let(:dataB) { d = now + 1.second; create(:wbgt, {:machine_id => machine1.id, :beginning => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }
      let(:dataC) { d = now + 2.second; create(:wbgt, {:machine_id => machine2.id, :beginning => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }

      describe 'by HTTP' do
        it_behaves_like 'get group page test', 'by http', :group, :wbgts do
          subject(:page) { get machine_wbgts_path(machine1), params: { wbgt_id: param } }
        end
      end

      describe 'by JSON' do
        it_behaves_like 'get group page test', 'by json', :group, :wbgts do
          subject(:page) { get machine_wbgts_path(machine1), params: { wbgt_id: param }, as: :json  }
        end
      end
    end
  end

  # memo request headerは as: キーワードで指定したらつけるようになっていると思われる
  describe 'POST /wbgts' do
    context 'データ数1' do
      let(:data) {
        {
          type: "wbgt",
          item: {
            machine: {mac: Faker::Internet.mac_address},
            data: [
              attributes_for(:wbgt)
            ]
          }
        }
      }

      it_behaves_like 'post api test', Wbgt, 1 do
        subject(:page) { post wbgts_path, params: data, as: :json }
      end
    end

    context 'データ数3' do
      let(:data) {
        {
          type: "wbgt",
          item: {
            machine: {mac: Faker::Internet.mac_address},
            data: [
              attributes_for(:wbgt),
              attributes_for(:wbgt),
              attributes_for(:wbgt)
            ]
          }
        }
      }

      it_behaves_like 'post api test', Wbgt, 3 do
        subject(:page) { post wbgts_path, params: data, as: :json }
      end
    end
  end

  describe 'DELETE /wbgts/:id' do
    let(:data) { create(:wbgt) }

	subject(:page) { delete wbgt_url data }

    it_behaves_like 'delete action test', Wbgt do
      let(:redirect_url) { wbgts_url }
    end
  end

  describe 'PUT /wbgts/:id' do
    let(:data1) { create(:wbgt) }
    let(:data2) { attributes_for(:wbgt) }

    subject(:page) { put wbgt_url data1, params: { wbgt: data2 } }

    it_behaves_like 'update action test'  do
      let(:redirect_url) { wbgt_url data1 }
    end

    it 'データが変更される' do
      data1
      data2
      expect { subject }.to change { Wbgt.find(data1.id).wbgt_data }.from(data1.wbgt_data).to(data2[:wbgt_data].to_d)
    end
  end
end
