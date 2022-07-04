# frozen_string_literal: true

require "pal"

module Pal
  module Operation

    # Creates new columns
    class Transforms
      include ObjectHelpers
      include Log

      # @return [Array<BaseTransformation>]
      attr_accessor :operations

      def initialize(operations_arr)
        @operations = operations_arr.map
      end

      # @return [TrueClass, FalseClass]
      def transformable?(column_name)
        find_operation(column_name) != nil
      end

      def find_operation(column_name)
        @operations.find { |o| o.column == column_name }
      end

      def transform(ctx, row)

      end

    end

    class BaseTransform

      # @return [String]
      attr_accessor :column

      # @return [String]
      attr_accessor :strategy

      # @return [Hash]
      attr_accessor :options

      def initialize(hash)
        @column = hash["column"]
        @strategy = hash["strategy"]
        @options = hash["options"]
      end

      private

      def run_transform(record)

      end

    end

  end
end

