# frozen_string_literal: true

require "pal"
require "pal/operation/processor_context"

# Processor for CSV extraction
module Pal
  module Operation
    # Base class for CSV impls, we can define strategy on memory usage needs based on
    # potential issues from file size.
    # TODO: We probably want to break away from this being a "CSV"-only file type later
    # Needs more thinking
    class CSVProcessor
      include Pal::Log

      # Strategy to return correct type - memory or performance focused.
      # @return [BaseCSVProcessor]
      def self.retrieve_default_processor(csv_file_location)
        Pal.logger.info("Default processor has been requested. No further action required.")
        RCSVProcessorImpl.new(csv_file_location)
      end

      attr_accessor :csv_file_location

      def initialize(csv_file_location)
        @csv_file_location = csv_file_location
      end

      # @param [ProcessorContext] ctx
      # @param [Proc] block
      # @param [Hash] opts
      def parse(ctx, opts={}, &block)
        _parse_impl(ctx, opts, &block)
      end

      private

      # @abstract
      # @param [ProcessorContext] _ctx
      # @param [Hash] _opts
      # @param [Proc] _block
      def _parse_impl(_ctx, _opts, &_block)
        raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
      end

      # @param [String] file_location
      # @return [String]
      def read_file(file_location)
        log_info("Reading file from disk located at #{file_location}")
        # File.read(File.expand_path(File.join(File.dirname(__FILE__), file_location)))
        Common::LocalFileUtils.read_file(file_location)
      end

      # @param [String] _file_location
      def stream_file(_file_location)
        raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
      end
    end

    require "rcsv"

    # rCSV impl
    class RCSVProcessorImpl < CSVProcessor
      private

      # @param [ProcessorContext] ctx
      # @param [Proc] _block
      # @param [Hash] opts
      # @yield [Array] row
      # @yield [ProcessorContext] ctx
      # @return [ProcessorContext]
      def _parse_impl(ctx, opts={}, &_block)
        return nil unless block_given?

        Rcsv.parse(read_file(@csv_file_location), opts) do |row|
          ctx.total_row_count += 1
          ctx.current_file_row_count += 1

          yield row
        end
      end
    end
  end
end
