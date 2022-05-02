# frozen_string_literal: true

require "singleton"
require "json"
require "pal/log"

module Pal
  # Configuration management module for Pal
  module Configuration
    include Pal::Log

    # @return [Config]
    def config
      conf = ConfigurationSource.instance.config
      raise "Set config first" unless conf

      conf
    end

    # @param [Config] request_config
    def register_config(request_config)
      log_info "Setting config"
      ConfigurationSource.instance.load_config(request_config)
    end

    # Config data class - holds configuration settings.
    class Config
      attr_accessor :source_file_loc, :template_file_loc, :output_dir

      # @return [Boolean]
      def validate
        errors = decorate_errors

        if errors.size.positive?
          errors.each { |x| Pal.logger.info x }
          raise Pal::ValidationError.new(errors, "Invalid request.")
        end

        true
      end

      def read_template_file
        JSON.parse(File.read(@template_file_loc))
      end

      private

      def decorate_errors
        # Add directory validation
        # Check billing file is a valid billing file
        errors = []
        errors << "Missing property: template file [-t]." unless @template_file_loc
        errors << "Missing property: input file [-s]." unless @source_file_loc
        errors << "File not found: billing file must exist" unless File.exist?(@source_file_loc || "")
        errors
      end
    end

    # Config storage source for access, stored as singleton.
    class ConfigurationSource
      include Singleton

      attr_reader :config

      # @param [Config] config
      # @return [Config]
      def load_config(config)
        @config = config
      end
    end
  end
end
