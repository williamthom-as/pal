# frozen_string_literal: true

require "json"

RSpec.describe Pal::Operation::Actions do
  before :all do
    json = '{
      "group_by" : ["lineItem/UsageAccountId", "lineItem/ResourceId"],
      "projection" : {
        "type" : "sum",
        "property" : "lineItem/BlendedCost"
      }
    }'

    @configuration = JSON.parse(json)
  end

  describe "#new" do
    it "should construct from hash" do
      actions = Pal::Operation::Actions.new.from_hash(@configuration)
      expect(actions.group_by.class).to eq(Array)
      expect(actions.group_by.size).to eq(2)

      expect(actions.projection.class).to eq(Pal::Operation::SumProjectionImpl)
      expect(actions.projection.property).to eq("lineItem/BlendedCost")
    end
  end
end


