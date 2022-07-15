# frozen_string_literal: true

RSpec.describe Pal::Main do
  before :all do
    @conf = Pal::Configuration::Config.new
    @conf.source_file_loc = "../../../spec/pal/test_files/test_cur_file.csv"
    @conf.template_file_loc = "../../spec/pal/test_files/test_template.json"
    @conf.output_dir = "/tmp"

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

  describe "#process" do
    it "should init and store runbook policy" do
      res = @main.process
      expect(res[0].class).to eq(Array)
      expect(res[1].class).to eq(Hash)
    end

    it "should throw if malformed" do
      conf = Pal::Configuration::Config.new
      conf.source_file_loc = "../../../spec/pal/test_files/test_cur_file.csv"
      conf.template_file_loc = "../../spec/pal/test_files/malformed_template.json"
      conf.output_dir = "/tmp"

      main = Pal::Main.new(conf)
      expect { main.setup }.to raise_error("Malformed JSON request for file [../../spec/pal/test_files/malformed_template.json]")
    end

    it "should throw if malformed" do
      conf = Pal::Configuration::Config.new
      conf.source_file_loc = "../../../spec/pal/test_files/test_cur_file.csv"
      conf.template_file_loc = "../../spec/pal/test_files/invalid_handler_template.json"
      conf.output_dir = "/tmp"

      main = Pal::Main.new(conf)
      expect { main.setup }.to raise_error("uninitialized constant Pal::Handler::InvalidHandlerImpl")
    end
  end

end
