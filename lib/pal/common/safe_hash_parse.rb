# frozen_string_literal: true

require "pal"
require "json"
require "jsonpath"

module Pal
  # The most lazy way to find things in hashes and JSON.
  # Provides default and optional params
  # Provides safe navigation with hash key dot notation ('this.is.a.key')
  class SafeHashParse
    class << self
      # @param [String] json_str
      # @param [Object] key
      # @param [Boolean] optional
      # @param [Object] default
      # @return [Array]
      def extract_from_json(json_str, key, optional=false, default=nil)
        val = JsonPath.new(key.to_s).on(json_str)
        return val if val && !val.empty?
        return [] unless optional

        [default]
      rescue JSON::ParserError, MultiJson::ParseError, ArgumentError => e
        raise e unless optional

        [default]
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
          break unless last_level.is_a?(Hash) && last_level.key?(key.to_s)

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

      # @param [Object] key
      # @return [Array]
      def format_key(key)
        return [key.downcase] if key.is_a?(Symbol)

        if key.is_a?(String)
          return [key.downcase.to_sym] unless key.include?(".")

          return key.to_s.split(".").map { |s| s.downcase.to_sym }
        end

        raise ArgumentError, "Key [#{key}] must be either a String or Symbol"
      end

      # @param [String] json
      def all_values_from_json(json)
        all_values(JSON.parse(json))
      end

      # @param [Hash] hash
      def all_values(hash)
        hash.flat_map { |_k, v| (v.is_a?(Hash) ? all_values(v) : [v]) }
      end
    end

  end
end
