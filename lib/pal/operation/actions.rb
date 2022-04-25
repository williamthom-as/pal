# frozen_string_literal: true

require "pal"
require "pal/configuration"
require "pal/common/local_file_utils"
require "pal/common/safe_hash_parser"

module Pal
  module Operation
    class Actions
      include ObjectHelpers

      # @return [Array<String>]
      attr_accessor :group_by

      # @return [Array<String>]
      attr_accessor :order_by

      # @return [Projection]
      attr_reader :projection

      def projection=(opts)
        return unless opts && (opts.key?("type") && opts.key?("property"))

        @projection = Pal::Operation::Projection.new(opts["type"], opts["property"])
      end

      def processable?
        # Do better in the future
        !@group_by.nil?
      end

      # @param [Array] rows
      # @param [Hash] column_headers
      # @return [Array] rows, column_headers
      def process(rows, column_headers)
        grouped = perform_group_by(rows, column_headers)

        rows, column_headers = perform_projection(grouped, column_headers)
        [rows, column_headers]
      end

      private

      def perform_projection(groups, column_headers)
        rows = []
        sum_column_idx = column_headers[@projection.property]

        groups.each_key do |key|
          sum = 0.0

          row = groups[key]

          row.each do |entry|
            sum += entry[sum_column_idx].to_f
          end

          arr = []
          @group_by.each do |gb|
            idx = column_headers[gb]
            arr << row[0][idx]
          end

          arr << sum
          rows << arr
        end

        column_headers = {}
        @group_by.each_with_index { |gb, idx| column_headers[gb] = idx }
        column_headers[@projection.property] = @group_by.size + 1

        [rows, column_headers]
      end

      # @param [Array] rows
      # @param [Hash] column_headers
      # @return [Hash] rows, column_headers
      def perform_group_by(rows, column_headers)
        group_by_map = {}
        rows.each do |row|
          key = generate_map_key(row, column_headers)
          unless group_by_map.key?(key)
            group_by_map[key] = []
          end

          group_by_map[key] << row
        end

        group_by_map
      end

      # Take a row, extract the props, return a key
      def generate_map_key(row, column_headers)
        keys = []
        @group_by.each do |gbp|
          idx = column_headers[gbp]
          keys << row[idx]
        end

        keys.join(".")
      end
    end

    class Projection

      attr_accessor :type, :property

      def initialize(type, property)
        @type = type
        @property = property
      end

    end
  end
end

