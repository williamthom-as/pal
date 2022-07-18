# frozen_string_literal: true

module Pal
  module Handler
    class Manager
      include Log

      attr_accessor :handler

      # @param [Base] handler
      def initialize(handler)
        raise TypeError.new("Service must be type of BaseServiceImpl") unless handler.is_a? Base

        @handler = handler
      end

      # @param [Pal::Request::Runbook] runbook
      # @return [Array, Hash]
      def process_runbook(runbook)
        Pal.logger.info("Beginning execution of playbook ...")
        ctx = @handler.process_runbook

        log_info "No exporter defined." unless runbook.exporter
        log_info "No candidates found." unless ctx.candidates.size.positive?

        runbook.exporter.perform_export(ctx)
      end
    end
  end
end
