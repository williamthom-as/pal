# frozen_string_literal: true

require "pal/operation/filter_evaluator"
require "pal/operation/exporter"
require "pal/operation/actions"
require "pal/request/metadata"
require "pal/common/object_helpers"
require "json"

module Pal
  module Request
    class Runbook
      include ObjectHelpers

      # @return [Pal::Request::Metadata]
      attr_reader :metadata

      # @return [Pal::Operation::FilterEvaluator]
      attr_reader :filters

      # @return [Pal::Operation::Exporter]
      attr_reader :exporter

      # @return [Pal::Operation::Actions]
      attr_reader :actions

      # @param [Array<Hash>] filter_hash
      def filters=(filter_hash)
        @filters = Pal::Operation::FilterEvaluator.new(filter_hash)
      end

      # @param [Hash] opts
      def metadata=(opts)
        @metadata = Pal::Request::Metadata.new(opts)
      end

      # @param [Hash] opts
      def exporter=(opts)
        @exporter = Pal::Operation::Exporter.new.from_hash(opts)
      end

      # @param [Hash] opts
      def actions=(opts)
        @actions = Pal::Operation::Actions.new
        @actions.group_by = opts["group_by"]
        @actions.action = opts["action"]
      end
    end
  end
end
