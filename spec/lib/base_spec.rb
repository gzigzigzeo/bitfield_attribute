require 'spec_helper'

describe TestBitfield do
  let(:storage) { { bitfield: 0 } }
  subject { described_class.new(storage, :bitfield) }

  context '#initialize' do
    let(:storage) { { bitfield: 6 } }

    it 'raises if too many values given' do
      expect {
        class WrongBitfield1 < BitfieldAttribute::Base
          define_bits *(:A..:z).to_a
        end
      }.to raise_error(ArgumentError, 'Too many bit names for 32-bit integer')
    end

    it 'raises if non-uniq values given' do
      expect {
        class WrongBitfield2 < BitfieldAttribute::Base
          define_bits :a, :a, :a
        end
      }.to raise_error(ArgumentError, 'Bit names are not uniq')
    end

    it 'raises if bits are defining with multiple statements' do
      expect {
        class WrongBitfield3 < BitfieldAttribute::Base
          define_bits :a, :b, :c
          define_bits :d, :e, :f
        end
      }.to raise_error(ArgumentError, 'Define all your bits with a single #define_bits statement')
    end

    it 'gets initial bits from value' do
      expect(subject.first).to eq(false)
      expect(subject.first?).to eq(false)

      expect(subject.second).to eq(true)
      expect(subject.second?).to eq(true)

      expect(subject.last).to eq(true)
      expect(subject.last?).to eq(true)

      expect(subject.to_a).to eq([:second, :last])
    end
  end

  context 'setters' do
    it 'sets value on storage' do
      expect(storage[:bitfield]).to eq(0)

      subject.first = true
      subject.last = true

      expect(subject.value).to eq(5)
      expect(storage[:bitfield]).to eq(5)
    end

    it 'sets values from hash' do
      subject.attributes = { 'first' => '1', 'second' => '0', 'last' => '1' }

      expect(subject.value).to eq(5)

      subject.attributes = { first: 1 }

      expect(subject.value).to eq(1)

      expect(subject.attributes).to eq({ first: true, second: false, last: false })
    end
  end

  context '#update' do
    it 'updates attributes with provided hash' do
      subject.attributes = { 'first' => '1', 'second' => '0', 'last' => '1' }

      subject.update( first: 0, second: 1 )

      expect(subject.value).to eq 6
    end
  end

  context 'internalization' do
    before do
      I18n.enforce_available_locales = false
      I18n.backend.store_translations(I18n.default_locale,
        activemodel: {
          attributes: {
            test_bitfield: {
              first: 'First field'
            },
            'bit_field/user/notification_settings' => {
              second: 'Second field'
            }
          }
        }
      )
    end

    context 'non-namespaced model' do
      it 'returns correct field name' do
        expect(described_class.human_attribute_name(:first)).to eq('First field')
      end
    end

    context 'namespaced model' do
      subject { BitField::User::NotificationSettings.new(storage, :bitfield) }

      it 'returns correct field name' do
        expect(subject.class.human_attribute_name(:second)).to eq('Second field')
      end
    end
  end
end
