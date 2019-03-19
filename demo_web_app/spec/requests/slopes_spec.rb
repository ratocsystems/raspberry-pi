require 'rails_helper'

RSpec.describe "Slopes", type: :request do
  describe 'REQUEST Slope' do
    let(:now) { Time.current }
    let(:machine1) { create(:machine) }
    let(:machine2) { create(:machine) }

    describe 'GET /slopes' do
      # 昨日、今日、明日のデータ
      let(:data1) { d = now.yesterday;  create(:slope, {:date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }
      let(:data2) { d = now;            create(:slope, {:date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }
      let(:data3) { d = now.tomorrow;   create(:slope, {:date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }

      # 2秒前から2秒後まで1秒ごとのデータ
      let(:data4) { d = now - 2.second; create(:slope, {:date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }
      let(:data5) { d = now - 1.second; create(:slope, {:date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }
      let(:data6) { d = now;            create(:slope, {:date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }
      let(:data7) { d = now + 1.second; create(:slope, {:date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }
      let(:data8) { d = now + 2.second; create(:slope, {:date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }

      describe 'by HTTP' do
        it_behaves_like 'get api test', 'by http', :index, :slopes do
          subject(:page) { get slopes_path, params: param }
        end
      end

      describe 'by JSON' do
        it_behaves_like 'get api test', 'by json', :index, :slopes do
          subject(:page) { get slopes_path, params: param, as: :json }
        end
      end
    end

    describe 'GET /machines/:machine_id/slope' do
      # 昨日、今日、明日のデータ
      let(:data1) { d = now.yesterday;  create(:slope, {:machine_id => machine1.id, :date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }
      let(:data2) { d = now;            create(:slope, {:machine_id => machine1.id, :date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }
      let(:data3) { d = now.tomorrow;   create(:slope, {:machine_id => machine1.id, :date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }

      # 2秒前から2秒後まで1秒ごとのデータ
      let(:data4) { d = now - 2.second; create(:slope, {:machine_id => machine1.id, :date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }
      let(:data5) { d = now - 1.second; create(:slope, {:machine_id => machine1.id, :date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }
      let(:data6) { d = now;            create(:slope, {:machine_id => machine1.id, :date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }
      let(:data7) { d = now + 1.second; create(:slope, {:machine_id => machine1.id, :date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }
      let(:data8) { d = now + 2.second; create(:slope, {:machine_id => machine1.id, :date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }

      describe 'by HTTP' do
        it_behaves_like 'get api test', 'by http', :list, :slopes do
          subject(:page) { get machine_slope_path(machine1), params: param }
        end
      end

      describe 'by JSON' do
        it_behaves_like 'get api test', 'by json', :list, :slopes do
          subject(:page) { get machine_slope_path(machine1), params: param, as: :json }
        end
      end
    end

    describe 'GET /machines/:machine_id/slopes' do
      # machine混在データ
      let(:dataA) { d = now;            create(:slope, {:machine_id => machine1.id, :beginning => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }
      let(:dataB) { d = now + 1.second; create(:slope, {:machine_id => machine1.id, :beginning => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }
      let(:dataC) { d = now + 2.second; create(:slope, {:machine_id => machine2.id, :beginning => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }

      describe 'by HTTP' do
        it_behaves_like 'get group page test', 'by http', :group, :slopes do
          subject(:page) { get machine_slopes_path(machine1), params: { slope_id: param } }
        end
      end

      describe 'by JSON' do
        it_behaves_like 'get group page test', 'by json', :group, :slopes do
          subject(:page) { get machine_slopes_path(machine1), params: { slope_id: param }, as: :json }
        end
      end
    end
  end

  # memo request headerは as: キーワードで指定したらつけるようになっていると思われる
  describe 'POST /slopes' do
    context 'データ数1' do
      let(:data) {
        {
          type: "slope",
          item: {
            machine: {mac: Faker::Internet.mac_address},
            data: [
              attributes_for(:slope)
            ]
          }
        }
      }

      it_behaves_like 'post api test', Slope, 1 do
        subject(:page) { post slopes_path, params: data, as: :json }
      end
    end

    context 'データ数3' do
      let(:data) {
        {
          type: "slope",
          item: {
            machine: {mac: Faker::Internet.mac_address},
            data: [
              attributes_for(:slope),
              attributes_for(:slope),
              attributes_for(:slope)
            ]
          }
        }
      }

      it_behaves_like 'post api test', Slope, 3 do
        subject(:page) { post slopes_path, params: data, as: :json }
      end
    end
  end

  describe 'DELETE /slopes/:id' do
    let(:data) { create(:slope) }

	subject(:page) { delete slope_url data }

    it_behaves_like 'delete action test', Slope do
      let(:redirect_url) { slopes_url }
    end
  end

  describe 'PUT /slopes/:id' do
    let(:data1) { create(:slope) }
    let(:data2) { attributes_for(:slope) }

    subject(:page) { put slope_url data1, params: { slope: data2 } }

    it_behaves_like 'update action test' do
      let(:redirect_url) { slope_url data1 }
    end

    it 'データが変更される' do
      data1
      data2
      expect { subject }.to change { Slope.find(data1.id).x }.from(data1.x).to(data2[:x].to_i)
    end
  end
end
