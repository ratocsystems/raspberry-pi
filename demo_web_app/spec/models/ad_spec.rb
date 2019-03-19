require 'rails_helper'

RSpec.describe Ad, type: :model do
  describe 'validate of uniqueness for gp40_id and channel' do
    after(:each) do
      Faker::Number.unique.clear
    end

    let(:id1) { create(:gp40).id }
    let(:id2) { create(:gp40).id }
    let(:channel1) { Faker::Number.unique.between(0, 7) }
    let(:channel2) { Faker::Number.unique.between(0, 7) }
    let(:data1) { create(:ad, {:gp40_id => id1, :channel => channel1}) }
    let(:data2) { build(:ad, {:gp40_id => target_id, :channel => target_ch}) }

    subject (:result) { data2.valid? }

    context 'with same gp40_id and channel' do
      let(:target_id) { id1 }
      let(:target_ch) { channel1 }

      it 'is valid' do
        data1
        is_expected.to be false
      end
    end

    context 'with different gp40_id' do
      let(:target_id) { id2 }
      let(:target_ch) { channel1 }

      it 'is valid' do
        data1
        is_expected.to be true
      end
    end

    context 'with different channel' do
      let(:target_id) { id1 }
      let(:target_ch) { channel2 }

      it 'is valid' do
        data1
        is_expected.to be true
      end
    end
  end

  describe 'validate of inclusion for' do
    subject (:result) { data.valid? }

    context 'channel' do
      let(:data) { build(:ad, {:channel => channel}) }

      context 'with out of range' do
        let(:channel) { 8 }

        it 'is valid' do
          is_expected.to be false
        end
      end

      context 'with limit' do
        let(:channel) { 7 }

        it 'is valid' do
          is_expected.to be true
        end
      end
    end

    context 'range' do
      let(:data) { build(:ad, {:range => range}) }

      context 'with out of range' do
        let(:range) { 9 }

        it 'is valid' do
          is_expected.to be false
        end
      end

      context 'with limit' do
        let(:range) { 8 }

        it 'is valid' do
          is_expected.to be true
        end
      end
    end

    context 'value' do
      let(:data) { build(:ad, {:value => value}) }

      context 'with out of range' do
        let(:value) { 0x1000 }

        it 'is valid' do
          is_expected.to be false
        end
      end

      context 'with limit' do
        let(:value) { 0xFFF }

        it 'is valid' do
          is_expected.to be true
        end
      end
    end
  end
end
