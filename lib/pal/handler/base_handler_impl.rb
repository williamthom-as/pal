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
        filters&.test_property(row, column_headers) || true
      end

      protected

      # @param [ProcessorContext] _ctx
      # @param [CSVProcessor] _processor
      # @param [Proc] _block
      # @return [Hash]
      def _parse_file(_ctx, _processor, &_block)
        raise "Not implemented here!"
      end

      # @param [String] _source_file_loc
      # @return [CSVProcessor]
      def _csv_processor(_source_file_loc)
        raise "Not implemented here!"
      end

      def _extract_headers; end
    end
  end
end
