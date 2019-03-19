require 'rails_helper'

RSpec.describe Survey, type: :model do
  let(:now) { Time.current }
  let(:machine1) { create(:machine) }
  let(:machine2) { create(:machine) }

  # machine1, machine2のデータを2つずつ作成
  let(:data1_1) { d = now;            create(:survey, { :machine_id => machine1.id, :beginning => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec) }) }
  let(:data1_2) { d = now + 1.second; create(:survey, { :machine_id => machine1.id, :beginning => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec) }) }
  let(:data2_1) { d = now + 2.second; create(:survey, { :machine_id => machine2.id, :beginning => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec) }) }
  let(:data2_2) { d = now + 3.second; create(:survey, { :machine_id => machine2.id, :beginning => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec) }) }

  # 中央データと前後1秒のデータ
  let(:data_middle) { d = now;            create(:survey, { :machine_id => machine1.id, :beginning => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec) }) }
  let(:data_prev)   { d = now - 1.second; create(:survey, { :machine_id => machine1.id, :beginning => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec) }) }
  let(:data_next)   { d = now + 1.second; create(:survey, { :machine_id => machine1.id, :beginning => Time.mktime(d.year, d.month, d.day, d.hour, d.min, d.sec) }) }

  # 中央データと前日と翌日のデータ
  let(:data_day_middle) { d = now;                           create(:survey, { :machine_id => machine1.id, :date => d }) }
  let(:data_day_prev)   { d = now.yesterday.end_of_day;      create(:survey, { :machine_id => machine1.id, :date => d }) }
  let(:data_day_next)   { d = now.next_day.beginning_of_day; create(:survey, { :machine_id => machine1.id, :date => d }) }

  describe '#find_measure_group' do
    it_behaves_like 'response method of find_measure_group', Survey
  end

  describe '.prev_group' do
    it_behaves_like 'response method of prev_group'
  end

  describe '.next_group' do
    it_behaves_like 'response method of next_group'
  end

  describe '.prev_day' do
    it_behaves_like 'response method of prev_day'
  end

  describe '.next_day' do
    it_behaves_like 'response method of next_day'
  end

end
