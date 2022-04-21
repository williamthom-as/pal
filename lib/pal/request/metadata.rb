# frozen_string_literal: true

module Pal
  module Request
    class Metadata
      include Pal::ObjectHelpers

      # @return [String]
      attr_accessor :version, :name, :description, :handler

      def initialize(opts={})
        @description = opts["description"]
        @version = opts["version"]
        @handler = opts["handler"]
        @name = opts["name"]
      end
    end
  end
end
