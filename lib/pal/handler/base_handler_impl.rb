# frozen_string_literal: true

module Pal
  module Handler
    class BaseHandlerImpl
      include Configuration
      include Log

      # @param [Pal::Request::Runbook] runbook
      def initialize(runbook)
        @runbook = runbook
      end

      # @return [Operation::ProcessorContext]
      def process_runbook
        log_debug("Processing runbook started, setting up context.")
        ctx = Operation::ProcessorContext.new

        # Get CSV parser
        # Each impl needs to return a hash of candidate columns and values
        # Extract headers
        # Extract values

        log_debug("Calling off to parse impl for CSV processing.")

        # Different impls may choose to stream file, so we hand in a location and let it decide.
        _parse_file(ctx, _csv_processor(config.source_file_loc)) do |row|
          ctx.add_candidate(row) if should_include?(@runbook.filters, row, ctx.column_headers)
        end

        log_info "Process completed with #{ctx.candidates.size} candidate records found."

        ctx
      end

      # @return [Boolean]
      # @param [Pal::Operation::FilterEvaluator] filters
      # @param [Array] row
      # @param [Hash] column_headers
      def should_include?(filters, row, column_headers)
        # _include?(filters, row, column_headers)
        filters.test_property(row, column_headers)
      end

      protected

      # @abstract
      # @param [ProcessorContext] _ctx
      # @param [CSVProcessor] _processor
      # @param [Proc] _block
      # @return [Hash]
      def _parse_file(_ctx, _processor, &_block)
        raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
      end

      # @abstract
      # @param [String] _source_file_loc
      # @return [CSVProcessor]
      def _csv_processor(_source_file_loc)
        raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
      end

      def _extract_headers; end
    end

    class AwsCurHandlerImpl < BaseHandlerImpl
      include Pal::Operation
      include Pal::Log

      # @param [ProcessorContext] ctx
      # @param [CSVProcessor] csv_processor
      # @param [Proc] _block
      # @return [Hash]
      # ---
      # Each impl needs to return a hash of candidate columns and values
      # eg. { col_name: col_value, col_name_2: col_value_2 }
      def _parse_file(ctx, csv_processor, &_block)
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
