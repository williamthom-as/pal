# frozen_string_literal: true

require "pal"
require "json"

module Pal
  # The most lazy way to find things in hashes and JSON.
  # Provides default and optional params
  # Provides safe navigation with hash key dot notation ('this.is.a.key')
  class SafeParse
    class << self
      # @param [String] json_str
      # @param [Object] key
      # @param [Boolean] optional
      # @param [Object] default
      # @return [Object, nil]
      def extract_from_json(json_str, key, optional=false, default=nil)
        json = lazy_parse_json(json_str)
        extract_from_hash(json, key, optional, default)
      rescue JSON::ParserError, ArgumentError => e
        raise e unless optional

        default
      end

      # @param [Hash] hash
      # @param [Object] search_key
      # @param [Boolean] optional
      # @param [Object, nil] default
      # @return [Object, nil]
      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/CyclomaticComplexity
      # rubocop:disable Metrics/PerceivedComplexity
      def extract_from_hash(hash, search_key, optional=false, default=nil)
        keys = format_key(search_key)
        last_level = hash
        searched = nil

        keys.each_with_index do |key, index|
          break unless last_level.is_a?(Hash) && (last_level.key?(key.to_s) || last_level.key?(key.to_sym))

          if index + 1 == keys.length
            searched = last_level[key.to_s] || last_level[key.to_sym]
          else
            last_level = last_level[key.to_s] || last_level[key.to_sym]
          end
        end

        return searched if searched
        return nil unless optional

        default
      end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/CyclomaticComplexity
      # rubocop:enable Metrics/PerceivedComplexity

      # @param [String] json_str
      # @param [Boolean] suppress_error
      # @return [Hash]
      def lazy_parse_json(json_str, suppress_error=false)
        hash = JSON.parse(json_str)
        hash.each_key do |key|
          sym = key.downcase.to_sym
          hash[sym] = hash[key] if key.is_a?(String) && !hash.key?(sym)
        end

        hash
      rescue JSON::ParserError => e
        !suppress_error ? (raise e) : nil
      end

      # @param [Object] key
      # @return [Array]
      def format_key(key)
        return [key.downcase] if key.is_a?(Symbol)

        if key.is_a?(String)
          return [key.downcase.to_sym] unless key.include?(".")

          return key.to_s.split(".").map {|s| s.downcase.to_sym }
        end

        raise ArgumentError, "Key [#{key}] must be either a String or Symbol"
      end
    end

  end
end
