# frozen_string_literal: true

require "pal"
require "pal/operation/projection"

module Pal
  module Operation
    class Actions
      include ObjectHelpers
      include Log

      # @return [Array<String>]
      attr_accessor :group_by

      # @return [String]
      attr_accessor :sort_by

      # @return [Projection]
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

        if sort_idx.nil? || sort_idx.negative?
          raise "Missing [#{@sort_by}]. Valid candidates are: [#{column_headers.keys.join(", ")}]"
        end

        rows.sort_by! { |a| a[sort_idx] }

        [rows.reverse, column_headers]
      end

      # Take a row, extract the props, return a key
      def generate_map_key(row, column_headers)
        keys = []
        @group_by.each do |gbp|
          idx = column_headers[gbp]

          raise "Missing column index. Please include [#{gbp}] in columns #{column_headers.keys}." unless idx

          keys << row[idx]
        end

        keys.join(".")
      end
    end
  end
end
