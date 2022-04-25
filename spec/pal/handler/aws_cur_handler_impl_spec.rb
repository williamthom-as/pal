require "pal/operation/exporter"

RSpec.describe Pal::Handler::AwsCurHandlerImpl do
  include Pal::Configuration

  before :all do
    @conf = Pal::Configuration::Config.new
    @conf.source_file_loc = "/home/william/Downloads/full_billing_file.csv"
    # @conf.template_file_loc = "spec/pal/test_files/test_template.json"
    @conf.template_file_loc = "templates/resource_type_breakdown.json"
    @conf.output_dir = "/tmp/pal"

    @main = Pal::Main.new(@conf)
    @main.setup

    @impl = Pal::Handler::AwsCurHandlerImpl.new(@main.runbook)
  end

  describe "#setup" do
    it "should init and store runbook policy" do
      results = @impl.process_runbook
      # expect(results.candidates.size).to eq(589)

      @main.runbook.exporter.perform_export(results.candidates, results.column_headers)

      # dont test main, just test export abilities
      # Pal::Operation::TableExporterImpl.new({}).run_export(results.candidates, results.column_headers)
    end
  end



end
