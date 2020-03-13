require 'active_model'
require 'active_support/hash_with_indifferent_access'
require 'active_support/core_ext/object/inclusion'
require 'active_support/concern'
require 'active_record/connection_adapters/column'

module BitfieldAttribute
  module Base
    extend ActiveSupport::Concern

    module ClassMethods
      def define_bits(*keys)
        if @keys.present?
          raise ArgumentError, 'Define all your bits with a single #define_bits statement'
        end

        @keys = keys.map(&:to_sym)

        if @keys.uniq.size != @keys.size
          raise ArgumentError, "Bit names are not uniq"
        end

        if @keys.size > INTEGER_SIZE
          raise ArgumentError, "Too many bit names for #{INTEGER_SIZE}-bit integer"
        end

        define_bit_methods
      end

      def keys
        @keys
      end

      private
      def define_bit_methods
        keys.each do |key|
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

      keys = self.class.keys

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

    def attributes=(value)
      @values.each { |key, _| @values[key] = false }
      update(value)
    end

    def update(value)
      if value.is_a?(Integer)
        write_bits(value)
      else
        value.symbolize_keys.each do |key, value|
          if @values.keys.include?(key)
            @values[key] = true_value?(value)
          end
        end
        write_bits
      end
    end

    def as_json(options = nil)
      attributes
    end

    private
    def read_bits
      bit_value = @instance[@attribute].to_i

      @values.keys.each.with_index do |name, index|
        bit = 2 ** index
        @values[name] = true if bit_value & bit == bit
      end
    end

    def write_bits(predefined_bits = nil)
      if predefined_bits.present?
        bits = predefined_bits
      else
        bits = 0
        @values.keys.each.with_index do |name, index|
          bits = bits | (2 ** index) if @values[name]
        end
      end

      @instance[@attribute] = bits

      if predefined_bits
        read_bits
      end
    end

    def true_value?(value)
      if ActiveRecord::VERSION::MAJOR.in?([5, 6])
        ActiveRecord::Type::Boolean.new.cast(value)
      elsif ActiveRecord::VERSION::MINOR < 2
        ActiveRecord::ConnectionAdapters::Column.value_to_boolean(value)
      else
        ActiveRecord::Type::Boolean.new.type_cast_from_user(value)
      end
    end

    INTEGER_SIZE = 32
  end
end
