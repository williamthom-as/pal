# frozen_string_literal: true

require "pal"

module Pal
  # Object helper module
  module ObjectHelpers
    def attributes=(hash)
      hash.each do |key, value|
        send("#{key}=", value)
      rescue NoMethodError
        Pal.logger.warn("Error deserializing object: No property for #{key}")
      end
    end

    def from_json(json)
      return from_hash(json) if json.is_a?(Hash) # Just a guard incase serialisation is done

      from_hash(JSON.parse(json))
    end

    def from_hash(hash)
      self.attributes = hash
      self
    end
  end
end
