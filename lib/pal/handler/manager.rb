# frozen_string_literal: true

module Pal
  module Handler
    class Manager
      include Log

      attr_accessor :handler

      # @param [BaseHandlerImpl] handler
      def initialize(handler)
        raise TypeError.new("Service must be type of BaseServiceImpl") unless handler.is_a? BaseHandlerImpl

        @handler = handler
      end

      # @param [Pal::Request::Runbook] runbook
      def process_runbook(runbook)
        Pal.logger.info("Beginning execution of playbook ...")
        ctx = @handler.process_runbook

        log_info "No exporter defined." unless runbook.exporter
        log_info "No candidates found." unless ctx.candidates.size.positive?

        runbook.exporter.perform_export(ctx.candidates, ctx.column_headers)
      end
    end
  end
end
