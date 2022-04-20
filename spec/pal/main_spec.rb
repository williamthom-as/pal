# frozen_string_literal: true

RSpec.describe Pal::Main do
  before :all do
    @conf = Pal::Configuration::Config.new
    @conf.source_file_loc = "/home/william/Downloads/cur.csv"
    @conf.template_file_loc = "spec/pal/test_files/test_template.json"
    @conf.output_dir = "/tmp/pal"
  end

  describe "#setup" do
    it "should construct from policy" do
      main = Pal::Main.new(@conf)
      main.setup

      expect(main.runbook.class).to eq(Pal::Request::Runbook)
    end
  end
end
