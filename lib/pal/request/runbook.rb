# frozen_string_literal: true

require "pal/operation/filter_evaluator"
require "pal/request/metadata"
require "pal/common/object_helpers"
require "json"

module Pal
  module Request
    class Runbook
      include Pal::ObjectHelpers

      # @return [Pal::Request::Metadata]
      attr_reader :metadata

      # @return [Pal::Operation::FilterEvaluator]
      attr_reader :filters

      # @return [Pal::Request::Extraction]
      attr_reader :extraction

      # @param [Array<Hash>] filter_hash
      def filters=(filter_hash)
        @filters = Pal::Operation::FilterEvaluator.new(filter_hash)
      end

      # @param [Hash] opts
      def metadata=(opts)
        @metadata = Pal::Request::Metadata.new(opts)
      end

      # @param [Hash] opts
      def extraction=(opts)
        @extraction = Pal::Request::Extraction.new(opts)
      end
    end
  end
end
