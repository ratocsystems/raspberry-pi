require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the Gp40sHelper. For example:
#
# describe Gp40sHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe Gp40sHelper, type: :helper do
  describe "#print_range" do
    let(:msg) { ["±10V" , "±5V", "±2.5V", "±1V", "±0.5V", "0 - 10V", "0 - 5V", "0 - 2.5V", "0 - 1V"] }

    it 'correct message' do
      8.times do |n|
        expect(helper.print_range(n)).to eq msg[n]
      end
    end
  end
end
