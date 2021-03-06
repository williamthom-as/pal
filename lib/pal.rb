# frozen_string_literal: true

require "pal/version"
require "pal/main"
require "pal/configuration"
require "pal/log"

require "pal/operation/filter_evaluator"
require "pal/handler/processor"
require "pal/operation/exporter"
require "pal/operation/actions"

require "pal/request/runbook"
require "pal/handler/manager"

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

    def message
      "Validation error: [#{@errors.join(", ")}]"
    end
  end
end
