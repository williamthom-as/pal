# frozen_string_literal: true

require "pal"

module Pal
  module Operation
    class Actions
      include ObjectHelpers
      include Log

      # @return [Array<String>]
      attr_accessor :group_by

      # @return [String]
      attr_accessor :sort_by

      # @return [ProjectionImpl]
      attr_reader :projection

      def projection=(opts)
        clazz_name = "Pal::Operation::#{opts["type"]&.to_s&.capitalize || "Default"}ProjectionImpl"
        @projection = Kernel.const_get(clazz_name).new(opts["property"] || nil)
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
        rows, column_headers = perform_sort_by(rows, column_headers)

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
      # @return [Hash] group_by_map
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

      # @param [Array] rows
      # @param [Hash] column_headers
      # @return [Array] rows, column_headers
      def perform_sort_by(rows, column_headers)
        log_info("Performing sort by #{@sort_by} across a total of #{rows.size} has been provided.")
        return [rows, column_headers] if @sort_by.nil?

        sort_idx = column_headers[@sort_by]

        raise "Missing [#{@sort_by}] in group_by properties." if sort_idx.nil? || sort_idx.negative?

        rows.sort_by! do |a|
          a[sort_idx]
        end

        [rows.reverse, column_headers]
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

      # @abstract
      # @param [Array<String>] _group_by_rules
      # @param [Hash] _groups
      # @param [Hash] _column_headers
      # @return [Array] rows, column_headers
      def _process_impl(_group_by_rules, _groups, _column_headers)
        raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
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
        column_headers["sum_#{@property}"] = group_by_rules.size

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

    class MaxMinProjectionImpl < ProjectionImpl

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

    class DefaultProjectionImpl < ProjectionImpl

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
  end
end
