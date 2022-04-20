# frozen_string_literal: true

require "json"

RSpec.describe Pal::Request::Runbook do
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

  describe "#filters" do
    it "should load from hash" do
      rb = Pal::Request::Runbook.new
      rb.filters = JSON.parse(valid_filter)
      expect(rb.filters.class).to eq(Pal::Operation::FilterEvaluator)
    end
  end

end


