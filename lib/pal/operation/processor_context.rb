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
      def cast(column_header, value)
        return value unless @column_type_definitions&.key?(column_header)

        case @column_type_definitions[column_header]["data_type"]
        when "string"
          value.to_s
        when "decimal"
          value.to_f
        when "integer"
          value.to_i
        when "date_time"
          DateTime.parse(value)
        when "date"
          Date.parse(value)
        when nil
          value
        else
          value
        end
      end
      # rubocop:enable Metrics/CyclomaticComplexity
    end
  end
end
