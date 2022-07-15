# frozen_string_literal: true

RSpec.describe Pal::Configuration do
  describe "#new" do
    it "should raise an error is config is not loaded" do
      expect { Pal::Configuration.config }.to raise_error(StandardError)
    end
  end

  describe "#new" do
    it "should validate proper request" do
      @conf = Pal::Configuration::Config.new
      @conf.source_file_loc = "spec/pal/test_files/test_cur_file.csv"
      @conf.template_file_loc = "spec/pal/test_files/test_template.json"

      @conf.output_dir = "/tmp/pal"

      expect(@conf.validate).to be_truthy
    end

    it "should fail to validate wrong request" do
      @conf = Pal::Configuration::Config.new
      @conf.source_file_loc = "spec/pal/test_files/i_dont_exist.csv"
      @conf.template_file_loc = "spec/pal/test_files/test_template.json"
      @conf.output_dir = "/tmp/pal"

      expect { @conf.validate }.to raise_error(Pal::ValidationError)
    end
  end

  describe "#read_template_file" do
    it "should read template file as json to hash" do
      @conf = Pal::Configuration::Config.new
      @conf.source_file_loc = "spec/pal/test_files/test_cur_file.csv"
      @conf.template_file_loc = "spec/pal/test_files/test_template.json"

      @conf.output_dir = "/tmp/pal"

      expect(@conf.read_template_file.class).to eq(Hash)
    end

  end
end
