# frozen_string_literal: true

module Pal
  module Operation
    class ProcessorContext
      attr_accessor :row_count, :column_headers

      def initialize
        @row_count = 0
        @column_headers = {}
      end

      # @param [Array<String>] row
      def extract_column_headers(row)
        row.each_with_index { |column, idx| @column_headers[column] = idx }
      end
    end
  end
end
