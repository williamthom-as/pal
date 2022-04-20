# frozen_string_literal: true

module Pal
  module Handler
    class Manager

      attr_accessor :handler

      # @param [BaseHandlerImpl] handler
      def initialize(handler)
        raise TypeError.new("Service must be type of BaseServiceImpl") unless service.is_a? BaseHandlerImpl

        @handler = handler
      end

      # @return [Array]
      # @param [Pal::Request::Runbook] runbook
      def execute(runbook)
        @handler.execute(runbook)
      end
    end
  end
end
