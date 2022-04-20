# frozen_string_literal: true

# Processor for CSV extraction
module Pal
  module Operation
    # Base class for CSV impls, we can define strategy on memory usage needs based on
    # potential issues from file size.
    class BaseCSVProcessorImpl

      # Strategy to return correct type - memory or performance focused.
      # @return [BaseCSVProcessor]
      def self.retrieve_default_processor(csv_file_location)
        RCSVProcessorImpl.new(csv_file_location)
      end

      attr_accessor :csv_file_location

      def initialize(csv_file_location)
        @csv_file_location = csv_file_location
      end

      # @param [Proc] block
      # @param [Hash] opts
      def parse(opts={}, &block)
        parse_context = ProcessorContext.new
        parse_impl(parse_context, opts, &block)
      end

      private

      # @param [ProcessorContext] _ctx
      # @param [Hash] _opts
      # @param [Proc] block
      def parse_impl(_ctx, _opts, &block)
        raise "Not implemented here"
      end

      # @param [String] file_location
      # @return [String]
      def read_file(file_location)
        File.read(File.expand_path(file_location))
      end

      def stream_file(file_location)
        # TODO: Streaming file support?
      end
    end

    require "rcsv"

    # rCSV impl
    class RCSVProcessorImpl < BaseCSVProcessorImpl

      private

      # @param [ProcessorContext] ctx
      # @param [Proc] block
      # @param [Hash] opts
      # @yield [Array] row
      # @return [ProcessorContext]
      def parse_impl(ctx, opts={}, &block)
        return nil unless block_given?

        Rcsv.parse(read_file(@csv_file_location), opts) do |row|
          ctx.row_count += 1
          yield row
        end

        ctx
      end
    end

    class ProcessorContext
      attr_accessor :row_count

      def initialize
        @row_count = 0
      end
    end
  end
end
