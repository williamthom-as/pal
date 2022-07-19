# frozen_string_literal: true

require "pal"

module Pal
  module Handler
    class Base
      include Configuration
      include Log

      # @param [Pal::Request::Runbook] runbook
      def initialize(runbook)
        @runbook = runbook
      end

      # @return [Operation::ProcessorContext]
      # rubocop:disable Metrics/AbcSize
      def process_runbook
        log_debug("Processing runbook started, setting up context.")
        ctx = Operation::ProcessorContext.new
        ctx.column_type_definitions = retrieve_column_definitions

        # Get CSV parser
        # Each impl needs to return a hash of candidate columns and values
        # Extract headers
        # Extract values

        log_debug("Calling off to parse impl for CSV processing.")

        # Different impls may choose to stream file, so we hand in a location and let it decide.

        config.all_source_files.each_with_index do |file, idx|
          log_info "Opening file [#{file}][#{idx}]"

          _parse_file(ctx, _csv_processor(file)) do |row|
            ctx.add_candidate(row) if should_include?(@runbook.filters, row, ctx.column_headers)
          end
        end

        log_info "Process completed with #{ctx.candidates.size} candidate records found."

        ctx
      end
      # rubocop:enable Metrics/AbcSize

      # @return [Boolean]
      # @param [Pal::Operation::FilterEvaluator] filters
      # @param [Array] row
      # @param [Hash] column_headers
      def should_include?(filters, row, column_headers)
        # _include?(filters, row, column_headers)
        filters.test_property(row, column_headers)
      end

      # @return [Hash, nil]
      def retrieve_column_definitions
        overrides = @runbook.column_overrides || {}
        path = File.join(File.dirname(__FILE__), "definitions/#{_type}.json")

        return overrides unless File.exist?(path)

        default_defs = JSON.parse(File.read(path))
        default_defs.merge(overrides)
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

      # @abstract
      # @return [String]
      def _type
        raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
      end

      def _extract_headers; end

    end

    # Generic has first row column headers, then data rows.
    class GenericCSVHandlerImpl < Base
      include Log

      # @param [ProcessorContext] ctx
      # @param [Pal::Operation::CSVProcessor] csv_processor
      # @param [Proc] _block
      # @return [Hash]
      # ---
      # Each impl needs to return a hash of candidate columns and values
      # eg. { col_name: col_value, col_name_2: col_value_2 }
      def _parse_file(ctx, csv_processor, &_block)
        log_info("Starting to process file, using #{csv_processor.class} processor for #{_type} CUR file.")

        csv_processor.parse(ctx, header: :none) do |row|
          if ctx.row_count == 1
            ctx.extract_column_headers(row)
            next
          end

          yield row
        end
      end

      # @param [String] source_file_loc
      # @return [Pal::Operation::CSVProcessor]
      def _csv_processor(source_file_loc)
        Operation::CSVProcessor.retrieve_default_processor(source_file_loc)
      end

      # @return [String]
      def _type
        "generic"
      end
    end

    class AwsCurHandlerImpl < GenericCSVHandlerImpl

      # @return [String]
      def _type
        "aws_cur"
      end
    end
  end
end
