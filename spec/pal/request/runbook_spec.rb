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

  metadata = '{
    "version" : "2022-04-02",
    "name" : "RI Expiry Dates",
    "handler" : "AwsCur",
    "description" : "Reserved instance expiry dates"
  }'

  exporter = '{
    "types" : [{
      "name" : "table",
      "settings" : {
        "title" : "Reserved instance expiry dates"
      }
    }],
    "properties" : [
      "lineItem/UsageType",
      "lineItem/ProductCode",
      "product/productFamily",
      "lineItem/ResourceId",
      "lineItem/BlendedCost",
      "reservation/EndTime"
    ],
    "actions" : {
      "group_by" : ["lineItem/ResourceId","reservation/EndTime"],
      "sort_by" : "count_reservation/EndTime",
      "projection" : {
        "type" : "count",
        "property" : "reservation/EndTime"
      }
    }
  }'

  describe "#filters" do
    it "should load from hash" do
      rb = Pal::Request::Runbook.new
      rb.filters = JSON.parse(valid_filter)
      rb.exporter = JSON.parse(exporter)
      rb.metadata = JSON.parse(metadata)
      expect(rb.filters.class).to eq(Pal::Operation::FilterEvaluator)
      expect(rb.exporter.class).to eq(Pal::Operation::Exporter)
      expect(rb.metadata.class).to eq(Pal::Request::Metadata)
    end
  end

end


