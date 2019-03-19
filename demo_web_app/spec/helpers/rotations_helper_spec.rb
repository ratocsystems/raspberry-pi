require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the RotationsHelper. For example:
#
# describe RotationsHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe RotationsHelper, type: :helper do
  describe '#get_roulette_no' do
    subject { get_roulette_no(param) }

    context '0' do
      let(:result) { 0 }
      let(:param) { 0 }

      it 'agree value' do
        is_expected.to eq result
      end
    end

    context '1' do
      let(:result) { 26 }
      let(:param) { 10 }

      it 'agree value' do
        is_expected.to eq result
      end
    end

    context '37' do
      let(:result) { 32 }
      let(:param) { 359 }

      it 'agree value' do
        is_expected.to eq result
      end
    end
  end

  describe '#get_roulette_position' do
    subject { get_roulette_position(param) }

    context '0' do
      let(:result) { 'zero' }
      let(:param) { 0 }

      it 'agree value' do
        is_expected.to eq result
      end
    end

    context '1' do
      let(:result) { 'odd' }
      let(:param) { 10 }

      it 'agree value' do
        is_expected.to eq result
      end
    end

    context '37' do
      let(:result) { 'even' }
      let(:param) { 359 }

      it 'agree value' do
        is_expected.to eq result
      end
    end
  end
end
