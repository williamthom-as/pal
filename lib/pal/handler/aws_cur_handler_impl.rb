# frozen_string_literal: true

require "pal/handler/base_handler_impl"

module Pal
  module Handler
    class AwsCurHandlerImpl < BaseHandlerImpl
      include Pal::Operation

      # @param [CSVProcessor] csv_processor
      # @param [Proc] block
      # @return [Hash]
      # ---
      # Each impl needs to return a hash of candidate columns and values
      # eg. { col_name: col_value, col_name_2: col_value_2 }
      def _parse_file(csv_processor, &block)
        csv_processor.parse(header: :none) do |row, ctx|
          if ctx.row_count == 1
            ctx.extract_column_headers(row)
            next
          end

          yield row, ctx
        end
      end

      # @param [String] source_file_loc
      # @return [CSVProcessor]
      def _csv_processor(source_file_loc)
        CSVProcessor.retrieve_default_processor(source_file_loc)
      end

    end
  end
end
