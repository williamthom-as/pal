# frozen_string_literal: true

require "json"
require "pal/common/local_file_utils"
require "pal/operation/processor_context"

RSpec.describe Pal::Operation::Exporter do
  before :all do
    json = '{
      "types" : [{
        "name" : "table",
        "settings" : {}
      }],
      "properties" : ["lineItem/UsageAccountId", "lineItem/ResourceId", "lineItem/BlendedCost"]
    }'

    vals = JSON.parse(json)
    @exporter = Pal::Operation::Exporter.new.from_hash(vals)
  end

  after :all do
    Pal::Common::LocalFileUtils.clean_dir("/tmp/pal")
  end

  describe "#new" do
    it "should load from map" do
      expect(@exporter.export_types.size).to eq(1)
      expect(@exporter.export_types[0].class).to eq(Pal::Operation::TableExporterImpl)
      expect(@exporter.properties.size).to eq(3)
    end
  end

  describe "#perform_export" do
    it "should perform export" do
      rows = [%w[a b 1], %w[a b 1], %w[d e 1]]
      column_headers = {
        "lineItem/UsageAccountId" => 0,
        "lineItem/ResourceId" => 1,
        "lineItem/BlendedCost" => 2
      }

      ctx = Pal::Operation::ProcessorContext.new
      ctx.column_headers = column_headers
      ctx.candidates = rows

      tx_rows, tx_headers = @exporter.perform_export(ctx)
      expect(tx_rows.size).to eq(3)
      expect(tx_headers.keys).to eq(%w[lineItem/UsageAccountId lineItem/ResourceId lineItem/BlendedCost])
    end
  end

  describe "#extract" do
    it "should perform export and log property not found in header" do
      rows = [%w[a b 1], %w[a b 1], %w[d e 1]]
      column_headers = {
        "lineItem/UsageAccountId" => 0,
        "lineItem/ResourceId" => 1
      }

      ctx = Pal::Operation::ProcessorContext.new
      ctx.column_headers = column_headers
      ctx.candidates = rows

      tx_rows, tx_headers = @exporter.send(:extract, ctx, %w[lineItem/UsageAccountId lineItem/ResourceId lineItem/BlendedCost])
      expect(tx_rows.size).to eq(3)
      expect(tx_headers.keys).to eq(%w[lineItem/UsageAccountId lineItem/ResourceId])
    end
  end

end

RSpec.describe Pal::Operation::BaseExportHandler do
  describe "#_export" do
    it "raise if calling on base" do
      pal = Pal::Operation::BaseExportHandler.new({})
      expect { pal.send(:_export, [], {}) }.to raise_error(NotImplementedError)
    end
  end

  describe "#run_export" do
    it "should alert if empty rows, and not fail/raise" do
      pal = Pal::Operation::BaseExportHandler.new({})
      expect(pal.send(:run_export, [], {})).to eq(nil)
    end
  end

end

RSpec.describe Pal::Operation::CsvExporterImpl do
  before :all do
    Pal::Common::LocalFileUtils.remove_file("/tmp/test.csv")
  end

  after :all do
    Pal::Common::LocalFileUtils.remove_file("/tmp/test.csv")
  end

  describe "#_export" do
    it "raise if calling on base" do
      pal = Pal::Operation::CsvExporterImpl.new({"file_name" => "test", "output_dir" => "/tmp"})
      rows = [%w[a b 1], %w[a b 1], %w[d e 1]]
      column_headers = {
        "lineItem/UsageAccountId" => 0,
        "lineItem/ResourceId" => 1,
        "lineItem/BlendedCost" => 2
      }

      pal.send(:_export, rows, column_headers)

      expect(File.exist?("/tmp/test.csv")).to be_truthy
    end
  end
end


