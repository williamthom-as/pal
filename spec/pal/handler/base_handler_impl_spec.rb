require "pal/operation/exporter"
require "pal/handler/base_handler_impl"

RSpec.describe Pal::Handler::BaseHandlerImpl do
  include Pal::Configuration

  before :all do
    @conf = Pal::Configuration::Config.new
    @conf.source_file_loc = "/home/william/Downloads/full_billing_file.csv"
    # @conf.template_file_loc = "spec/pal/test_files/test_template.json"
    # @conf.template_file_loc = "../../templates/global_resource_and_usage_type_costs.json"
    # @conf.template_file_loc = "../../templates/summary_daily_breakdown_costs.json"
    # @conf.template_file_loc = "../../templates/list_of_kms_keys.json"
    # @conf.template_file_loc = "../../templates/summary_cost_between_date_range.json"
    @conf.output_dir = "/tmp/pal"

    @main = Pal::Main.new(@conf)
    @main.setup

    @impl = Pal::Handler::AwsCurHandlerImpl.new(@main.runbook)
  end

  describe "#setup" do
    it "should init and store runbook policy" do
      ctx = @impl.process_runbook
      res = @main.runbook.exporter.perform_export(ctx)
    end
  end



end
