# frozen_string_literal: true

module Pal
  module Handler
    class BaseHandlerImpl
      include Pal::Configuration

      # @param [Pal::Request::Runbook] runbook
      def initialize(runbook)
        @runbook = runbook
      end

      # @return [Array]
      def execute
        candidates = []

        # Get CSV parser
        # Each impl needs to return a hash of candidate columns and values
        # Extract headers
        # Extract values

        # Different impls may choose to stream file, so we hand in a location and let it decide.
        _parse_file(_csv_processor(config.source_file_loc)) do |row, ctx|
          candidates << row if should_include?(@runbook.filters, row, ctx.column_headers)
        end

        Pal.logger.info "Process completed with #{candidates.size} candidate records found."
        candidates
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

      # @param [CSVProcessor] _processor
      # @param [Proc] block
      # @return [Hash]
      def _parse_file(_processor, &block)
        raise "Not implemented here!"
      end

      # @param [String] _source_file_loc
      # @return [CSVProcessor]
      def _csv_processor(_source_file_loc)
        raise "Not implemented here!"
      end

      # # @param [Pal::Operation::FilterEvaluator] filters
      # # @param [Hash] result
      # # @return [Boolean]
      # def _include?(filters, result)
      #   filters.test_property(result)
      # end

      def _extract_headers; end

    end
  end
end
