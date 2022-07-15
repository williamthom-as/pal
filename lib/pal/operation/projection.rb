# frozen_string_literal: true

require "pal"

module Pal
  module Operation
    class Projection
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

      # @abstract
      # @param [Array<String>] _group_by_rules
      # @param [Hash] _groups
      # @param [Hash] _column_headers
      # @return [Array] rows, column_headers
      def _process_impl(_group_by_rules, _groups, _column_headers)
        raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
      end
    end

    class SumProjectionImpl < Projection

      def initialize(property)
        super("sum", property)
      end

      private

      # @param [Array<String>] group_by_rules
      # @param [Hash] groups
      # @param [Hash] column_headers
      # @return [Array] rows, column_headers
      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/MethodLength
      def _process_impl(group_by_rules, groups, column_headers)
        rows = []
        sum_column_idx = column_headers[@property]

        raise "Missing column. Please include [#{@property}] in columns #{column_headers.keys}." unless sum_column_idx

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

          arr << sum.round(8)
          rows << arr
        end

        column_headers = {}
        group_by_rules.each_with_index { |gb, idx| column_headers[gb] = idx }
        column_headers["sum_#{@property}"] = group_by_rules.size

        [rows, column_headers]
      end
      # rubocop:enable Metrics/AbcSize
    end

    class DistinctProjectionImpl < Projection

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

        raise "Missing column index. Please include [#{@property}] in column extraction." unless distinct_column_idx

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

    class MaxMinProjectionImpl < Projection

      private

      # @param [Array<String>] _group_by_rules
      # @param [Hash] groups
      # @param [Hash] column_headers
      # @return [Array] rows, column_headers
      # rubocop:disable Metrics/AbcSize
      def _process_impl(_group_by_rules, groups, column_headers)
        max_vals = {}
        max_column_idx = column_headers[@property]

        groups.each_key do |key|
          row = groups[key]

          row.each do |entry|
            prop_val = entry[max_column_idx].to_f

            max_vals[key] = entry unless max_vals.key?(key)
            max_vals[key] = entry if comparator_proc.call(max_vals[key][0][max_column_idx].to_f, prop_val)
          end
        end

        rows = max_vals.values

        new_column_headers = {}
        column_headers.keys.each_with_index { |ch, idx| new_column_headers[ch] = idx }

        [rows, new_column_headers]
      end
      # rubocop:enable Metrics/AbcSize
      #

      def comparator_proc
        raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
      end
    end

    class MaxProjectionImpl < MaxMinProjectionImpl

      def initialize(property)
        super("max", property)
      end

      private

      def comparator_proc
        proc { |x, y| x > y }
      end

    end

    class MinProjectionImpl < MaxMinProjectionImpl

      def initialize(property)
        super("min", property)
      end

      private

      def comparator_proc
        proc { |x, y| x < y }
      end

    end

    class DefaultProjectionImpl < Projection

      def initialize(property)
        super("default", property)
      end

      # @param [Array<String>] _group_by_rules
      # @param [Hash] groups
      # @param [Hash] column_headers
      # @return [Array] rows, column_headers
      def _process_impl(_group_by_rules, groups, column_headers)
        [groups.values, column_headers]
      end

    end

    class AverageProjectionImpl < Projection

      def initialize(property)
        super("average", property)
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

          records = groups[key]
          records.each do |entry|
            sum += entry[sum_column_idx].to_f
          end

          arr = []
          group_by_rules.each do |gb|
            idx = column_headers[gb]
            arr << records[0][idx]
          end

          arr << sum.round(8) / records.size
          rows << arr
        end

        column_headers = {}
        group_by_rules.each_with_index { |gb, idx| column_headers[gb] = idx }
        column_headers["average_#{@property}"] = group_by_rules.size

        [rows, column_headers]
      end
      # rubocop:enable Metrics/AbcSize
    end

    class CountProjectionImpl < Projection

      def initialize(property)
        super("count", property)
      end

      private

      # @param [Array<String>] _group_by_rules
      # @param [Hash] groups
      # @param [Hash] column_headers
      # @return [Array] rows, column_headers
      # rubocop:disable Metrics/AbcSize
      def _process_impl(_group_by_rules, groups, column_headers)
        distinct_column_idx = column_headers[@property]
        raise "Missing column index. Please include [#{@property}] in column extraction." unless distinct_column_idx

        count_map = {}

        groups.each_key do |key|
          groups[key].each do |entry|
            prop = entry[distinct_column_idx]

            count_map[prop] = 0 unless count_map[prop]
            count_map[prop] += 1
          end
        end

        column_headers = {}
        column_headers[@property] = 0
        column_headers["count_#{@property}"] = 0

        [count_map.map { |k, v| [k, v] }, column_headers]
      end
      # rubocop:enable Metrics/AbcSize
    end

  end
end

