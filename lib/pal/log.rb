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
    # @param [Exception/Nil] ex
    def log_error(message, ex = nil)
      Pal.logger.error(message)
      Pal.logger.error(ex.backtrace.join("\n")) unless ex.nil?
    end
  end
end
