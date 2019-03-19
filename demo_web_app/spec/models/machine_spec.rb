require 'rails_helper'

RSpec.describe Machine, type: :model do
  shared_examples_for '#check new' do |model|
    context '新規データ追加で' do
      it 'データ数が増える' do
        expect{ data }.to change{ model.count }.by(1)
      end

      it '取得データが一致する' do
        column.each do |name|
          expect(data[name]).to eq value[name]
        end
      end
    end
  end

  shared_examples_for '#check existing' do |model|
    context '既存データ追加で' do
      it 'データ数は変わらない' do
        expect{ data }.to change{ model.count }.by(0)
      end

      it '取得データが一致する' do
        is_expected.to eq value
      end
    end
  end

  describe '#check' do
    subject(:data) { Machine.check({:mac => value.mac}) }

    it_behaves_like '#check new', Machine do
      let!(:value) { build(:machine) }
      let(:column) { [:mac] }
    end

    it_behaves_like '#check existing', Machine do
      let!(:value) { create(:machine) }
    end
  end
end
