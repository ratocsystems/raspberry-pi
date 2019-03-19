require 'rails_helper'

RSpec.describe "Surveys", type: :request do
  describe 'REQUEST Survey' do
    let(:now) { Time.current }
    let(:machine1) { create(:machine) }
    let(:machine2) { create(:machine) }

    describe 'GET /surveys' do
      # 昨日、今日、明日のデータ
      let(:data1) { d = now.yesterday;  create(:survey, {:machine_id => machine1.id, :date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }
      let(:data2) { d = now;            create(:survey, {:machine_id => machine1.id, :date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }
      let(:data3) { d = now.tomorrow;   create(:survey, {:machine_id => machine1.id, :date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }

      # 2秒前から2秒後まで1秒ごとのデータ
      let(:data4) { d = now - 2.second; create(:survey, {:machine_id => machine1.id, :date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }
      let(:data5) { d = now - 1.second; create(:survey, {:machine_id => machine1.id, :date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }
      let(:data6) { d = now;            create(:survey, {:machine_id => machine1.id, :date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }
      let(:data7) { d = now + 1.second; create(:survey, {:machine_id => machine1.id, :date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }
      let(:data8) { d = now + 2.second; create(:survey, {:machine_id => machine1.id, :date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }

      describe 'by HTTP' do
        it_behaves_like 'get api test', 'by http', :index, :surveys do
          subject(:page) { get surveys_path, params: param }
        end
      end

      describe 'by JSON' do
        it_behaves_like 'get api test', 'by json', :index, :surveys do
          subject(:page) { get surveys_path, params: param, as: :json }
        end
      end
    end

    describe 'GET /machines/:machine_id/survey' do
      # 昨日、今日、明日のデータ
      let(:data1) { d = now.yesterday;  create(:survey, {:machine_id => machine1.id, :date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }
      let(:data2) { d = now;            create(:survey, {:machine_id => machine1.id, :date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }
      let(:data3) { d = now.tomorrow;   create(:survey, {:machine_id => machine1.id, :date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }

      # 2秒前から2秒後まで1秒ごとのデータ
      let(:data4) { d = now - 2.second; create(:survey, {:machine_id => machine1.id, :date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }
      let(:data5) { d = now - 1.second; create(:survey, {:machine_id => machine1.id, :date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }
      let(:data6) { d = now;            create(:survey, {:machine_id => machine1.id, :date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }
      let(:data7) { d = now + 1.second; create(:survey, {:machine_id => machine1.id, :date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }
      let(:data8) { d = now + 2.second; create(:survey, {:machine_id => machine1.id, :date => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }

      describe 'by HTTP' do
        it_behaves_like 'get api test', 'by http', :list, :surveys do
          subject(:page) { get machine_survey_path(machine1), params: param }
        end
      end

      describe 'by JSON' do
        it_behaves_like 'get api test', 'by json', :list, :surveys do
          subject(:page) { get machine_survey_path(machine1), params: param, as: :json }
        end
      end
    end

    describe 'GET /machines/:machine_id/surveys' do
      # machine混在データ
      let(:dataA) { d = now;            create(:survey, {:machine_id => machine1.id, :beginning => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }
      let(:dataB) { d = now + 1.second; create(:survey, {:machine_id => machine1.id, :beginning => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }
      let(:dataC) { d = now + 2.second; create(:survey, {:machine_id => machine2.id, :beginning => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec)}) }

      describe 'by HTTP' do
        it_behaves_like 'get group page test', 'by http', :group, :surveys do
          subject(:page) { get machine_surveys_path(machine1), params: { survey_id: param } }
        end
      end

      describe 'by JSON' do
        it_behaves_like 'get group page test', 'by json', :group, :surveys do
          subject(:page) { get machine_surveys_path(machine1), params: { survey_id: param }, as: :json }
        end
      end
    end
  end

  # memo request headerは as: キーワードで指定したらつけるようになっていると思われる
  describe 'POST /surveys' do
    context 'データ数1' do
      let(:data) {
        {
          type: "survey",
          item: {
            machine: {mac: Faker::Internet.mac_address},
            data: [
              attributes_for(:survey)
            ]
          }
        }
      }

      it_behaves_like 'post api test', Survey, 1 do
        subject(:page) { post surveys_path, params: data, as: :json }
      end
    end

    context 'データ数3' do
      let(:data) {
        {
          type: "survey",
          item: {
            machine: {mac: Faker::Internet.mac_address},
            data: [
              attributes_for(:survey),
              attributes_for(:survey),
              attributes_for(:survey)
            ]
          }
        }
      }

      it_behaves_like 'post api test', Survey, 3 do
        subject(:page) { post surveys_path, params: data, as: :json }
      end
    end
  end

  describe 'DELETE /surveys/:id' do
    let(:data) { create(:survey) }

	subject(:page) { delete survey_url data }

    it_behaves_like 'delete action test', Survey do
      let(:redirect_url) { surveys_url }
    end
  end

  describe 'PUT /surveys/:id' do
    let(:data1) { create(:survey) }
    let(:data2) { attributes_for(:survey) }

    subject(:page) { put survey_url data1, params: { survey: data2 } }

    it_behaves_like 'update action test' do
      let(:redirect_url) { survey_url data1 }
    end

    it 'データが変更される' do
      data1
      data2
      expect { subject }.to change { Survey.find(data1.id).distance }.from(data1.distance).to(data2[:distance].to_d)
    end
  end
end
