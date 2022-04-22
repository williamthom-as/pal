require "pal/operation/exporter"

RSpec.describe Pal::Handler::AwsCurHandlerImpl do
  include Pal::Configuration

  before :all do
    @conf = Pal::Configuration::Config.new
    @conf.source_file_loc = "/home/william/Downloads/full_billing_file.csv"
    @conf.template_file_loc = "spec/pal/test_files/test_template.json"
    @conf.output_dir = "/tmp/pal"

    @main = Pal::Main.new(@conf)
    @main.setup

    @impl = Pal::Handler::AwsCurHandlerImpl.new(@main.runbook)
  end

  describe "#setup" do
    it "should init and store runbook policy" do
      results = @impl.execute
      expect(results.candidates.size).to eq(3)

      Pal::Operation::TableExporterImpl.new({})._export(results.candidates, results.column_headers.keys)

    end
  end



end
