# frozen_string_literal: true

module Pal
  module Handler
    class BaseHandlerImpl
      include Pal::Configuration

      # @return [Array]
      # @param [Pal::Request::Runbook] runbook
      def execute(runbook)
        candidates = []

        # Open billing file - config.source_file_loc
        # Get CSV parser
        # Each impl needs to return a hash of candidate columns and values
        # Extract headers
        # Extract values

        # Different impls may choose to stream file, so we hand in a location and let it decide.
        _parse_file(config.source_file_loc) do |row|
          candidates << row if should_include?(runbook.filters, row)
        end

        Pal.logger.info "Process completed with #{candidates.size} candidate records found."
        candidates
      end

      # @return [Boolean]
      # @param [Pal::Operation::FilterEvaluator] filters
      # @param [Hash] result
      def should_include?(filters, result)
        _include?(filters, result)
      end

      protected

      # @param [String] _source_file_loc
      # @param [Proc] block
      # @return [Hash]
      def _parse_file(_source_file_loc, &block)
        raise "Not implemented here!"
      end

      # @param [Pal::Operation::FilterEvaluator] filters
      # @param [Hash] result
      # @return [Boolean]
      def _include?(filters, result)
        filters.test_property(result)
      end

      def _extract_headers; end

    end
  end
end
