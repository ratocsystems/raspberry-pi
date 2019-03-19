module ModelHelpers
  # find_measure_groupメソッドのテスト
  shared_examples_for 'response method of find_measure_group' do |model|
    context 'without id' do
      let(:result) { [ data1_2 ] }

      subject(:value) { model.find_measure_group(nil, machine1.id) }

      it 'return data existed' do
        data1_1
        data1_2
        data2_1
        data2_2
        subject
        expect(value).to eq result
      end

      it 'return data not existed' do
        data2_1
        data2_2
        subject
        expect(value).to be nil
      end
    end

    context 'with id' do
      let(:result) { [ data1_1 ] }

      subject(:value) { model.find_measure_group(data1_1.id, machine1.id) }

      it 'return data' do
        data1_1
        data1_2
        data2_1
        data2_2
        subject
        expect(value).to eq result
      end
    end

    context 'with invalid id' do
      let(:result) { [ data1_2 ] }

      subject(:value) { model.find_measure_group(data2_2.id, machine1.id) }

      it 'return newer data' do
        data1_1
        data1_2
        data2_1
        data2_2
        subject
        expect(value).to eq result
      end
    end
  end

  # prev_groupメソッドのテスト
  shared_examples_for 'response method of prev_group' do
    subject(:value) { data_middle.prev_group }

    it 'existed' do
      data_prev
      data_next
      subject
      expect(value).to eq data_prev.id
    end

    it 'not existed' do
      data_next
      subject
      expect(value).to be nil
    end
  end

  # next_groupメソッドのテスト
  shared_examples_for 'response method of next_group' do
    subject(:value) { data_middle.next_group }

    it 'existed' do
      data_prev
      data_next
      subject
      expect(value).to eq data_next.id
    end

    it 'not existed' do
      data_prev
      subject
      expect(value).to be nil
    end
  end

  # prev_dayメソッドのテスト
  shared_examples_for 'response method of prev_day' do
    subject(:value) { data_day_middle.prev_day }

    it 'existed' do
      data_day_prev
      data_day_next
      subject
      expect(value.to_i).to eq data_day_prev.date.to_i
    end

    it 'not existed' do
      data_day_next
      subject
      expect(value).to be nil
    end
  end

  # next_dayメソッドのテスト
  shared_examples_for 'response method of next_day' do
    subject(:value) { data_day_middle.next_day }

    it 'existed' do
      data_day_prev
      data_day_next
      subject
      expect(value.to_i).to eq data_day_next.date.to_i
    end

    it 'not existed' do
      data_day_prev
      subject
      expect(value).to be nil
    end
  end

end
