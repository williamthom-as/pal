# frozen_string_literal: true

require "json"

RSpec.describe Pal::Operation::Actions do
  before :all do
    json = '{
      "group_by" : ["lineItem/UsageAccountId", "lineItem/ResourceId"],
      "sort_by"  : "lineItem/UsageAccountId",
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

  describe "#processable?" do
    it "should return true if valid" do
      actions = Pal::Operation::Actions.new.from_hash(@configuration)
      expect(actions.processable?).to eq(true)
    end

    it "should return false if no group by" do
      actions = Pal::Operation::Actions.new.from_hash(@configuration)
      actions.group_by = nil
      expect(actions.processable?).to eq(false)
    end
  end

  describe "#perform_group_by" do
    it "group by the fields selected" do
      actions = Pal::Operation::Actions.new.from_hash(@configuration)
      rows = [%w[a b], %w[a b], %w[d e]]
      column_headers = {
        "lineItem/UsageAccountId" => 0,
        "lineItem/ResourceId" => 1
      }

      grouped_by = actions.send(:perform_group_by, rows, column_headers)
      expect(grouped_by.keys).to eq(%w[a.b d.e])
      expect(grouped_by["a.b"].size).to eq(2)
    end
  end

  describe "#perform_sort_by" do
    it "sort by the fields selected" do
      actions = Pal::Operation::Actions.new.from_hash(@configuration)
      rows = [%w[a b], %w[a b], %w[d e]]
      column_headers = {
        "lineItem/UsageAccountId" => 0,
        "lineItem/ResourceId" => 1
      }

      tx_rows, _tx_col = actions.send(:perform_sort_by, rows, column_headers)
      expect(tx_rows.size).to eq(3)
      expect(tx_rows.first).to eq(%w[d e])
    end

    it "sort by should fail if no match" do
      actions = Pal::Operation::Actions.new.from_hash(@configuration)
      rows = [%w[a b], %w[a b], %w[d e]]
      column_headers = {
        "lineItem/UsageAccountIdChanged" => 0,
        "lineItem/ResourceId" => 1
      }

      expect { actions.send(:perform_sort_by, rows, column_headers) }.to raise_error(RuntimeError)
    end
  end

  describe "#process" do
    it "run the process" do
      actions = Pal::Operation::Actions.new.from_hash(@configuration)
      rows = [%w[a b 1], %w[a b 1], %w[d e 1]]
      column_headers = {
        "lineItem/UsageAccountId" => 0,
        "lineItem/ResourceId" => 1,
        "lineItem/BlendedCost" => 2
      }

      tx_rows, column_headers = actions.process(rows, column_headers)
      expect(tx_rows[1][2]).to eq(2)
      expect(column_headers["sum_lineItem/BlendedCost"]).to eq(2)
    end
  end
end


