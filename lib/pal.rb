# frozen_string_literal: true

require "pal/version"
require "pal/main"
require "pal/configuration"
require "pal/operation/filter_evaluator"
require "pal/operation/csv_processor"
require "pal/operation/exporter"
require "pal/handler/manager"
require "pal/handler/aws_cur_handler_impl"
require "pal/request/runbook"

require "logger"

# Entry point for Pal services
module Pal
  class << self
    attr_writer :logger

    def logger
      @logger ||= Logger.new($stdout).tap do |log|
        log.progname = name
      end
    end
  end

  # Exception classes
  class ValidationError < StandardError
    attr_reader :errors

    def initialize(errors, msg="Invalid Request")
      super(msg)
      @errors = errors
    end
  end

end
