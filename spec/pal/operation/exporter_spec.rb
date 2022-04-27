# frozen_string_literal: true

require "json"
require "pal/common/local_file_utils"

RSpec.describe Pal::Operation::Exporter do
  before :all do
    json = '{
      "types" : [{
      "name" : "csv",
      "settings" : []
    }],
      "properties" : []
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
      expect(@exporter.export_types[0].class).to eq(Pal::Operation::CsvExporterImpl)
      expect(@exporter.properties.size).to eq(0)
    end
  end
end


