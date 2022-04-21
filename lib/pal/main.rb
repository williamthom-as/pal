# frozen_string_literal: true

require "pal"
require "pal/configuration"

module Pal

  class Main
    include Configuration

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
      @manager.execute(@runbook)
    end

    # @param [String] file_location
    # @return [Pal::Request::Runbook]
    def create_runbook(file_location)
      request_content = File.read(File.expand_path(file_location))
      Pal::Request::Runbook.new.from_json(request_content)
    rescue StandardError => e
      Pal.logger.error("Error creating request manager")
      raise e
    end

    # @return [Pal::Handler::Manager]
    def create_service_manager
      clazz_name = "Pal::Handler::#{@runbook.metadata.handler}HandlerImpl"
      impl = Kernel.const_get(clazz_name).new(@runbook)
      Pal::Handler::Manager.new(impl)
    rescue StandardError => e
      Pal.logger.error("Error creating service manager")
      raise e
    end

  end
end
