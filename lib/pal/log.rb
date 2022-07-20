# frozen_string_literal: true

require "pal"

module Pal
  module Log
    # @param [String] message
    def log_debug(message)
      Pal.logger.debug(message)
    end

    # @param [String] message
    def log_info(message)
      Pal.logger.info(message)
    end

    # @param [String] message
    def log_warn(message)
      Pal.logger.warn(message)
    end

    # @param [String] message
    # @param [Exception/Nil] exception
    def log_error(message, exception=nil)
      Pal.logger.error(message)
      Pal.logger.error(exception.backtrace.join("\n")) unless exception.nil?
    end
  end
end
