# frozen_string_literal: true

require "pal"
require "pal/configuration"
require "pal/handler/base_handler_impl"

module Pal

  class Main
    include Configuration
    include Log

    # @return [Pal::Request::Runbook]
    attr_accessor :runbook

    # @return [Pal::Handler::Manager]
    attr_accessor :manager

    # @param [Pal::Config] config
    def initialize(config)
      register_config(config)
    end

    # set config for process
    def setup
      @runbook = create_runbook(config.template_file_loc)
      @manager = create_service_manager
    end

    def reset
      # Will be needed when combining operations ... later
      @runbook, @manager = nil
      setup
    end

    def process
      @manager.process_runbook(@runbook)
    end

    # @param [String] file_location
    # @return [Pal::Request::Runbook]
    def create_runbook(file_location)
      file_relative = file_location.start_with?("/") ? file_location : File.join(File.dirname(__FILE__), file_location)

      log_debug "Attempting to read file from [#{file_relative}]"
      log_debug "Script executed from [#{__dir__}]"

      request_content = File.read(file_relative)
      Pal::Request::Runbook.new.from_json(request_content)
    rescue JSON::ParserError => e
      log_error("Malformed JSON request for file [#{file_location}]")
      raise e, "Malformed JSON request for file [#{file_location}]"
    rescue StandardError => e
      log_error("Error creating request manager")
      raise e
    end

    # @return [Pal::Handler::Manager]
    def create_service_manager
      clazz_name = "Pal::Handler::#{@runbook.metadata.handler}HandlerImpl"
      impl = Kernel.const_get(clazz_name).new(@runbook)
      Pal::Handler::Manager.new(impl)
    rescue NameError => e
      log_error("Cannot find a valid handler impl for #{@runbook.metadata.handler}")
      raise e
    rescue StandardError => e
      log_error("Error creating service manager")
      raise e
    end

  end
end
