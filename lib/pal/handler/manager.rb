# frozen_string_literal: true

module Pal
  module Handler
    class Manager

      attr_accessor :handler

      # @param [BaseHandlerImpl] handler
      def initialize(handler)
        raise TypeError.new("Service must be type of BaseServiceImpl") unless handler.is_a? BaseHandlerImpl

        @handler = handler
      end

      # @return [Array]
      # @param [Pal::Request::Runbook] runbook
      def execute(runbook)
        Pal.logger.info("Beginning execution of playbook ...")
        @handler.execute(runbook)
      end
    end
  end
end
