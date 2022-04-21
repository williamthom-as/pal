RSpec.describe Pal::Handler::AwsCurHandlerImpl do
  include Pal::Configuration

  before :all do

    @conf = Pal::Configuration::Config.new
    @conf.source_file_loc = "/home/william/Downloads/full_billing_file.csv"
    @conf.template_file_loc = "spec/pal/test_files/test_template.json"
    @conf.output_dir = "/tmp/pal"

    register_config(@conf)

    @main = Pal::Main.new(@conf)
    @main.setup

    @impl = Pal::Handler::AwsCurHandlerImpl.new(@main.runbook)
  end

  describe "#setup" do
    it "should init and store runbook policy" do
      results = @impl.execute
      expect(results.size).to eq(2)
    end
  end



end
