# frozen_string_literal: true

require "json"

RSpec.describe Pal::Operation::FilterEvaluator do
  valid_filter = '{
    "condition": "OR",
    "rules": [
      {
        "field": "a",
        "type": "string",
        "operator": "equal",
        "value": "b"
      }
    ]
  }'

  describe "#new" do
    it "should load from hash" do
      filter_eval = Pal::Operation::FilterEvaluator.new(JSON.parse(valid_filter))
      expect(filter_eval.rule.class).to eq(Pal::Operation::OrGroupRule)
      expect(filter_eval.rule.rule_group.size).to eq(1)
    end
  end

  describe "#test_property" do
    it "should return appropriate result for invalid prop" do
      filter_eval = Pal::Operation::FilterEvaluator.new(JSON.parse(valid_filter))
      result = filter_eval.test_property([], {}) # fix me
      # expect(result).to eq(true)
    end
  end
end


