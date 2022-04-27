# frozen_string_literal: true

require "pal"

module Pal
  module Operation
    class Actions
      include ObjectHelpers
      include Log

      # @return [Array<String>]
      attr_accessor :group_by

      # @return [Array<String>]
      attr_accessor :order_by

      # @return [ProjectionImpl]
      attr_reader :projection

      def projection=(opts)
        clazz_name = "Pal::Operation::#{opts["type"]&.to_s&.capitalize || "Default"}ProjectionImpl"
        @projection = Kernel.const_get(clazz_name).new(opts["property"])
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

        return [rows, column_headers] unless @projection&.processable?

        log_info("Performing projection by [#{@projection.type}].")
        rows, column_headers = perform_projection(grouped, column_headers)
        [rows, column_headers]
      end

      private

      # @param [Hash] groups
      # @param [Hash] column_headers
      # @return [Array] rows, column_headers
      def perform_projection(groups, column_headers)
        rows, column_headers = @projection.process(@group_by, groups, column_headers)
        [rows, column_headers]
      end

      # @param [Array] rows
      # @param [Hash] column_headers
      # @return [Hash] rows, column_headers
      def perform_group_by(rows, column_headers)
        log_info("Performing grouping by #{@group_by} across a total of #{rows.size} has been provided.")

        group_by_map = {}
        rows.each do |row|
          key = generate_map_key(row, column_headers)
          group_by_map[key] = [] unless group_by_map.key?(key)

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

    class ProjectionImpl
      include Log

      attr_accessor :type, :property

      def initialize(type, property)
        @type = type
        @property = property
      end

      # @param [Array<String>] group_by_rules
      # @param [Hash] groups
      # @param [Hash] column_headers
      # @return [Array] rows, column_headers
      def process(group_by_rules, groups, column_headers)
        log_info("Calling down to projection impl [#{type}]")
        _process_impl(group_by_rules, groups, column_headers)
      end

      def processable?
        !(@type.nil? || @property.nil?)
      end

      private

      # @param [Array<String>] _group_by_rules
      # @param [Hash] _groups
      # @param [Hash] _column_headers
      # @return [Array] rows, column_headers
      def _process_impl(_group_by_rules, _groups, _column_headers)
        raise "Not implemented in base class"
      end
    end

    class SumProjectionImpl < ProjectionImpl

      def initialize(property)
        super("sum", property)
      end

      private

      # @param [Array<String>] group_by_rules
      # @param [Hash] groups
      # @param [Hash] column_headers
      # @return [Array] rows, column_headers
      # rubocop:disable Metrics/AbcSize
      def _process_impl(group_by_rules, groups, column_headers)
        rows = []
        sum_column_idx = column_headers[@property]

        groups.each_key do |key|
          sum = 0.0

          row = groups[key]

          row.each do |entry|
            sum += entry[sum_column_idx].to_f
          end

          arr = []
          group_by_rules.each do |gb|
            idx = column_headers[gb]
            arr << row[0][idx]
          end

          arr << sum
          rows << arr
        end

        column_headers = {}
        group_by_rules.each_with_index { |gb, idx| column_headers[gb] = idx }
        column_headers["sum_#{@property}"] = group_by_rules.size + 1

        [rows, column_headers]
      end
      # rubocop:enable Metrics/AbcSize
    end

    class DistinctProjectionImpl < ProjectionImpl

      def initialize(property)
        super("distinct", property)
      end

      private

      # @param [Array<String>] _group_by_rules
      # @param [Hash] groups
      # @param [Hash] column_headers
      # @return [Array] rows, column_headers
      def _process_impl(_group_by_rules, groups, column_headers)
        rows = []
        distinct_column_idx = column_headers[@property]

        groups.each_key do |key|
          row = groups[key]

          row.each do |entry|
            prop = entry[distinct_column_idx]
            rows << prop unless rows.include?(prop)
          end
        end

        column_headers = {}
        column_headers["distinct_#{@property}"] = 0

        [rows.map { |x| [x] }, column_headers]
      end
    end

    class MaxProjectionImpl < ProjectionImpl

      def initialize(property)
        super("max", property)
      end

      private

      # @param [Array<String>] group_by_rules
      # @param [Hash] groups
      # @param [Hash] column_headers
      # @return [Array] rows, column_headers
      # rubocop:disable Metrics/AbcSize
      def _process_impl(group_by_rules, groups, column_headers)
        rows = []
        max_vals = {}
        max_column_idx = column_headers[@property]

        groups.each_key do |key|
          row = groups[key]

          row.each do |entry|
            prop_val = entry[max_column_idx].to_f

            max_vals[key] = 0.0 unless max_vals.key?(key)
            max_vals[key] = prop_val if prop_val > max_vals[key] # put in a proc to reduce code use
          end

          arr = []
          group_by_rules.each do |gb|
            idx = column_headers[gb]
            arr << row[0][idx]
          end
          # arr << sum
          # rows << arr
        end

        # column_headers = {}
        # group_by_rules.each_with_index { |gb, idx| column_headers[gb] = idx }
        # column_headers["max_#{@property}"] = group_by_rules.size + 1

        [[], column_headers]
      end
      # rubocop:enable Metrics/AbcSize
    end


  end
end

