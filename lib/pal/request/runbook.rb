# frozen_string_literal: true

require "pal/operation/filter_evaluator"
require "pal/common/object_helpers"
require "json"

module Pal
  module Request
    class Runbook
      include Pal::ObjectHelpers

      # @return [Pal::Operation::FilterEvaluator]
      attr_reader :filters

      # @param [Array<Hash>] filter_hash
      def filters=(filter_hash)
        @filters = Pal::Operation::FilterEvaluator.new(filter_hash)
      end

    end
  end
end
