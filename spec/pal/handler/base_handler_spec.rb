require "pal/operation/exporter"
require "pal/handler/base_handler"

RSpec.describe Pal::Handler::BaseHandler do
  include Pal::Configuration

  describe "#_type" do
    it "should throw on abstracts" do
      handler = Pal::Handler::BaseHandler.new(nil)
      expect { handler.send(:_type) }.to raise_error(NotImplementedError)
    end
  end

  describe "#_csv_processor" do
    it "should throw on abstracts" do
      handler = Pal::Handler::BaseHandler.new(nil)
      expect { handler.send(:_csv_processor, nil) {} }.to raise_error(NotImplementedError)
    end
  end

  describe "#_parse_file" do
    it "should throw on abstracts" do
      handler = Pal::Handler::BaseHandler.new(nil)
      expect { handler.send(:_parse_file, nil, nil) {} }.to raise_error(NotImplementedError)
    end
  end
end

RSpec.describe Pal::Handler::AwsCurHandlerImpl do
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

  describe "#_type" do
    it "should init and store runbook policy" do
      expect(@impl._type).to eq("aws_cur")
    end
  end
end

RSpec.describe Pal::Handler::GenericCSVHandlerImpl do
  include Pal::Configuration

  before :all do
    @conf = Pal::Configuration::Config.new
    @conf.source_file_loc = "../../../spec/pal/test_files/test_cur_file.csv"
    @conf.template_file_loc = "../../spec/pal/test_files/test_template.json"
    @conf.output_dir = "/tmp/pal"

    @main = Pal::Main.new(@conf)
    @main.setup

    @impl = Pal::Handler::GenericCSVHandlerImpl.new(@main.runbook)
  end

  describe "#_type" do
    it "should init and store runbook policy" do
      expect(@impl._type).to eq("generic")
    end
  end
end
