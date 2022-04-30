# frozen_string_literal: true

require "date"

module Pal
  module Operation
    class ProcessorContext
      attr_accessor :row_count, :candidates, :column_headers, :column_type_definitions

      def initialize
        @row_count = 0
        @candidates = []
        @column_headers = {}
      end

      # @param [Array<String>] row
      def extract_column_headers(row)
        row.each_with_index { |column, idx| @column_headers[column] = idx }
      end

      def add_candidate(row)
        @candidates << row
      end

      # rubocop:disable Metrics/CyclomaticComplexity
      def cast(column_header, row_property)
        return row_property unless @column_type_definitions&.key?(column_header)

        case @column_type_definitions[column_header]["data_type"]
        when "string"
          row_property.to_s
        when "decimal"
          row_property.to_f
        when "integer"
          row_property.to_i
        when "date_time"
          DateTime.parse(row_property)
        when "date"
          Date.parse(row_property)
        when nil
          row_property
        else
          row_property
        end
      end
      # rubocop:enable Metrics/CyclomaticComplexity
    end
  end
end
