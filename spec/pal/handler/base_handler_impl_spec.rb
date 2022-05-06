require "pal/operation/exporter"
require "pal/handler/base_handler_impl"

RSpec.describe Pal::Handler::BaseHandlerImpl do
  include Pal::Configuration

  before :all do
    @conf = Pal::Configuration::Config.new
    @conf.source_file_loc = "../../../spec/pal/test_files/test_cur_file.csv"
    @conf.template_file_loc = "../../spec/pal/test_files/test_template.json"
    @conf.output_dir = "/tmp/pal"

    @main = Pal::Main.new(@conf)
    @main.setup

    @impl = Pal::Handler::AwsCurHandlerImpl.new(@main.runbook)
  end

  describe "#setup" do
    it "should init and store runbook policy" do
      ctx = @impl.process_runbook
      @main.runbook.exporter.perform_export(ctx)

      expect(ctx.candidates.size).to eq(7)
      expect(ctx.column_headers.keys.size).to eq(142)
    end
  end



end
