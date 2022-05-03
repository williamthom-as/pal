# frozen_string_literal: true

RSpec.describe Pal::Main do
  before :all do
    @conf = Pal::Configuration::Config.new
    @conf.source_file_loc = "/home/william/Downloads/full_billing_file.csv"
    @conf.template_file_loc = "../../spec/pal/test_files/test_template.json"
    @conf.output_dir = "/tmp/pal"

    @main = Pal::Main.new(@conf)
    @main.setup
  end

  describe "#setup" do
    it "should init and store runbook policy" do
      expect(@main.runbook.class).to eq(Pal::Request::Runbook)
    end

    it "should init and store manager" do
      expect(@main.manager.class).to eq(Pal::Handler::Manager)
    end

  end
end
