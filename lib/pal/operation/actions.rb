# frozen_string_literal: true

require "pal"
require "pal/configuration"
require "pal/common/local_file_utils"
require "pal/common/safe_hash_parser"

module Pal
  module Operation
    class Actions

      # @return [Array<String>]
      attr_accessor :group_by

      # @return [Array<String>]
      attr_reader :action

      def action=(opts)
        @exporter = Pal::Operation::Action.new(opts["types"], opts["properties"])
      end
    end

    class Action

      attr_accessor :type, :property

      def initialize(type, property)
        @type = type
        @property = property
      end
    end
  end
end

