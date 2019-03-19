require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the WbgtsHelper. For example:
#
# describe WbgtsHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe WbgtsHelper, type: :helper do
  describe '#get_wbgt_guide' do
    subject { get_wbgt_guide(param) }

    context 'level safe' do
      let(:result) { { value: 'success', msg: 'ほぼ安全' } }
      let(:param) { 20 }

      it 'agree value' do
        is_expected.to include(result)
      end
    end

    context 'level attention' do
      let(:result) { { value: 'info', msg: '注意' } }

      context 'lower' do
        let(:param) { 21 }

        it 'agree value' do
          is_expected.to include(result)
        end
      end

      context 'upper' do
        let(:param) { 24 }

        it 'agree value' do
          is_expected.to include(result)
        end
      end
    end

    context 'level caution' do
      let(:result) { { value: 'active', msg: '警戒' } }

      context 'lower' do
        let(:param) { 25 }

        it 'agree value' do
          is_expected.to include(result)
        end
      end

      context 'upper' do
        let(:param) { 27 }

        it 'agree value' do
          is_expected.to include(result)
        end
      end
    end

    context 'level heavily' do
      let(:result) { { value: 'warning', msg: '厳重警戒' } }

      context 'lower' do
        let(:param) { 28 }

        it 'agree value' do
          is_expected.to include(result)
        end
      end

      context 'upper' do
        let(:param) { 30 }

        it 'agree value' do
          is_expected.to include(result)
        end
      end
    end

    context 'level discontinuance' do
      let(:result) { { value: 'danger', msg: '運動は原則中止' } }
      let(:param) { 31 }

      it 'agree value' do
        is_expected.to include(result)
      end
    end
  end
end
