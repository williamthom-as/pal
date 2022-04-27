# frozen_string_literal: true

require "pal/handler/base_handler_impl"

module Pal
  module Handler
    class AwsCurHandlerImpl < BaseHandlerImpl
      include Pal::Operation
      include Pal::Log

      # @param [ProcessorContext] ctx
      # @param [CSVProcessor] csv_processor
      # @param [Proc] block
      # @return [Hash]
      # ---
      # Each impl needs to return a hash of candidate columns and values
      # eg. { col_name: col_value, col_name_2: col_value_2 }
      def _parse_file(ctx, csv_processor, &block)
        log_info("Starting to process file, using #{csv_processor.class} processor for AWS CUR file.")
        csv_processor.parse(ctx, header: :none) do |row|
          if ctx.row_count == 1
            ctx.extract_column_headers(row)
            next
          end

          yield row
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
