require 'active_model'
require 'active_support/hash_with_indifferent_access'
require 'active_support/core_ext/object/inclusion'
require 'active_record/connection_adapters/column'

module BitfieldAttribute
  class Base
    extend ActiveModel::Naming
    extend ActiveModel::Translation

    class << self
      def bits(*keys)
        if keys.size > INTEGER_SIZE
          raise ArgumentError, "Too many bit names for #{INTEGER_SIZE}-bit integer"
        end

        @bit_keys = keys.map(&:to_sym)

        define_bit_methods
      end

      def bit_keys
        @bit_keys
      end

      def i18n_scope
        container = name.deconstantize
        return super if container.blank?

        container = container.constantize
        if container.respond_to?(:i18n_scope)
          return container.i18n_scope
        end

        super
      end

      private
      def define_bit_methods
        bit_keys.each do |key|
          define_setter(key)
          define_getter(key)
        end
      end

      def define_setter(key)
        define_method :"#{key}=" do |value|
          @values[key] = value
          write_bits
        end
      end

      def define_getter(key)
        define_method :"#{key}?" do
          @values[key] || false
        end

        alias_method key, :"#{key}?"
      end
    end

    def initialize(instance, attribute)
      @instance = instance
      @attribute = attribute

      keys = self.class.bit_keys

      @values = keys.zip([false] * keys.size)
      @values = Hash[@values]

      read_bits
    end

    def to_a
      @values.map { |key, value| key if value }.compact
    end

    def value
      @instance[@attribute].to_i
    end

    def attributes
      @values.freeze
    end

    def attributes=(hash)
      @values.each { |key, _| @values[key] = false }
      update(hash)
    end

    def update(hash)
      hash.symbolize_keys.each do |key, value|
        if @values.keys.include?(key)
          @values[key] = value.in?(ActiveRecord::ConnectionAdapters::Column::TRUE_VALUES)
        end
      end

      write_bits
    end

    private
    def read_bits
      bit_value = @instance[@attribute].to_i

      @values.keys.each.with_index do |name, index|
        bit = 2 ** index
        @values[name] = true if bit_value & bit == bit
      end
    end

    def write_bits
      0.tap do |bits|
        @values.keys.each.with_index do |name, index|
          bits = bits | (2 ** index) if @values[name]
        end

        @instance[@attribute] = bits
      end
    end

#    TRUE_VALUES = [true, 1, '1', 't', 'T', 'true', 'TRUE'].to_set
    INTEGER_SIZE = 32
  end
end
