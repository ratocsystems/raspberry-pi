require 'rails_helper'

RSpec.describe "Rotations", type: :request do
  describe 'REQUEST Rotation' do
    let(:now) { Time.current }
    let(:machine1) { create(:machine) }
    let(:machine2) { create(:machine) }

    describe 'GET /rotations' do
      # 昨日、今日、明日のデータ
      let(:data1) { d = now.yesterday;  create(:rotation, {:date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }
      let(:data2) { d = now;            create(:rotation, {:date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }
      let(:data3) { d = now.tomorrow;   create(:rotation, {:date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }

      # 2秒前から2秒後まで1秒ごとのデータ
      let(:data4) { d = now - 2.second; create(:rotation, {:date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }
      let(:data5) { d = now - 1.second; create(:rotation, {:date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }
      let(:data6) { d = now;            create(:rotation, {:date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }
      let(:data7) { d = now + 1.second; create(:rotation, {:date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }
      let(:data8) { d = now + 2.second; create(:rotation, {:date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }

      describe 'by HTTP' do
        it_behaves_like 'get api test', 'by http', :index, :rotations do
          subject(:page) { get rotations_path, params: param }
        end
      end

      describe 'by JSON' do
        it_behaves_like 'get api test', 'by json', :index, :rotations do
          subject(:page) { get rotations_path, params: param, as: :json }
        end
      end
    end

    describe 'GET /machines/:machine_id/rotation' do
      # 昨日、今日、明日のデータ
      let(:data1) { d = now.yesterday;  create(:rotation, {:machine_id => machine1.id, :date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }
      let(:data2) { d = now;            create(:rotation, {:machine_id => machine1.id, :date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }
      let(:data3) { d = now.tomorrow;   create(:rotation, {:machine_id => machine1.id, :date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }

      # 2秒前から2秒後まで1秒ごとのデータ
      let(:data4) { d = now - 2.second; create(:rotation, {:machine_id => machine1.id, :date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }
      let(:data5) { d = now - 1.second; create(:rotation, {:machine_id => machine1.id, :date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }
      let(:data6) { d = now;            create(:rotation, {:machine_id => machine1.id, :date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }
      let(:data7) { d = now + 1.second; create(:rotation, {:machine_id => machine1.id, :date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }
      let(:data8) { d = now + 2.second; create(:rotation, {:machine_id => machine1.id, :date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }

      describe 'by HTTP' do
        it_behaves_like 'get api test', 'by http', :list, :rotations do
          subject(:page) { get machine_rotation_path(machine1), params: param }
        end
      end

      describe 'by JSON' do
        it_behaves_like 'get api test', 'by json', :list, :rotations do
          subject(:page) { get machine_rotation_path(machine1), params: param, as: :json }
        end
      end
    end

    describe 'GET /machines/:machine_id/rotations' do
      # machine混在データ
      let(:dataA) { d = now;            create(:rotation, {:machine_id => machine1.id, :beginning => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }
      let(:dataB) { d = now + 1.second; create(:rotation, {:machine_id => machine1.id, :beginning => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }
      let(:dataC) { d = now + 2.second; create(:rotation, {:machine_id => machine2.id, :beginning => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }

      describe 'by HTTP' do
        it_behaves_like 'get group page test', 'by http', :group, :rotations do
          subject(:page) { get machine_rotations_path(machine1), params: { rotation_id: param } }
        end
      end

      describe 'by JSON' do
        it_behaves_like 'get group page test', 'by json', :group, :rotations do
          subject(:page) { get machine_rotations_path(machine1), params: { rotation_id: param }, as: :json }
        end
      end
    end
  end

  # memo request headerは as: キーワードで指定したらつけるようになっていると思われる
  describe 'POST /rotations' do
    context 'データ数1' do
      let(:data) {
        {
          type: "rotation",
          item: {
            machine: {mac: Faker::Internet.mac_address},
            data: [
              attributes_for(:rotation)
            ]
          }
        }
      }

      it_behaves_like 'post api test', Rotation, 1 do
        subject(:page) { post rotations_path, params: data, as: :json }
      end
    end

    context 'データ数3' do
      let(:data) {
        {
          type: "rotation",
          item: {
            machine: {mac: Faker::Internet.mac_address},
            data: [
              attributes_for(:rotation),
              attributes_for(:rotation),
              attributes_for(:rotation)
            ]
          }
        }
      }

      it_behaves_like 'post api test', Rotation, 3 do
        subject(:page) { post rotations_path, params: data, as: :json }
      end
    end
  end

  describe 'DELETE /rotations/:id' do
    let(:data) { create(:rotation) }

	subject(:page) { delete rotation_url data }

    it_behaves_like 'delete action test', Rotation do
      let(:redirect_url) { rotations_url }
    end
  end

  describe 'PUT /rotations/:id' do
    let(:data1) { create(:rotation) }
    let(:data2) { attributes_for(:rotation) }

    subject(:page) { put rotation_url data1, params: { rotation: data2 } }

    it_behaves_like 'update action test' do
      let(:redirect_url) { rotation_url data1 }
    end

    it 'データが変更される' do
      data1
      data2
      expect { subject }.to change { Rotation.find(data1.id).rpm }.from(data1.rpm).to(data2[:rpm].to_d)
    end
  end
end
