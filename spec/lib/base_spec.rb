require 'spec_helper'

describe TestBitfield do
  let(:storage) { { bitfield: 0 } }

  context '#initialize' do
    it 'raises if too many values given' do
      expect {
        class WrongBitfield < BitfieldAttribute::Base
          bits *([:a] * 48)
        end
      }.to raise_error(ArgumentError, 'Too many bit names for 32-bit integer')
    end

    it 'gets initial bits from value' do
      storage[:bitfield] = 6
      bitfield = described_class.new(storage, :bitfield)

      expect(bitfield.first).to eq(false)
      expect(bitfield.first?).to eq(false)

      expect(bitfield.second).to eq(true)
      expect(bitfield.second?).to eq(true)

      expect(bitfield.last).to eq(true)
      expect(bitfield.last?).to eq(true)

      expect(bitfield.to_a).to eq([:second, :last])
    end
  end

  context 'setters' do
    it 'sets value on storage' do
      expect(storage[:bitfield]).to eq(0)

      bitfield = described_class.new(storage, :bitfield)
      bitfield.first = true
      bitfield.last = true

      expect(bitfield.value).to eq(5)
      expect(storage[:bitfield]).to eq(5)
    end

    it 'sets values from hash' do
      bitfield = described_class.new(storage, :bitfield)
      bitfield.attributes = { 'first' => '1', 'second' => '0', 'last' => '1' }

      expect(bitfield.value).to eq(5)

      bitfield.attributes = { first: 1 }

      expect(bitfield.value).to eq(1)

      expect(bitfield.attributes).to eq({ first: true, second: false, last: false })
    end
  end

  context '#update' do
    it 'updates attributes with provided hash' do
      bitfield = described_class.new(storage, :bitfield)
      bitfield.attributes = { 'first' => '1', 'second' => '0', 'last' => '1' }

      bitfield.update( first: 0, second: 1 )

      expect(bitfield.value).to eq 6
    end
  end

  context 'internalization' do

  end
end

