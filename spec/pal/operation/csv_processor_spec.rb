# frozen_string_literal: true

require "json"
require "pal/operation/processor_context"

RSpec.describe Pal::Operation::CSVProcessor do
  describe "#retrieve_default_processor" do
    it "should load the CSV file" do
      fl = "../../../spec/pal/test_files/test_cur_file.csv"
      pal = Pal::Operation::CSVProcessor.retrieve_default_processor(fl)

      expect(pal.class).to be(Pal::Operation::RCSVProcessorImpl)
    end
  end

  describe "#new" do
    it "should load the CSV file" do
      fl = "../../../spec/pal/test_files/test_cur_file.csv"
      pal = Pal::Operation::CSVProcessor.new(fl)

      expect(pal.csv_file_location).to_not be_nil
    end
  end

  describe "#parse" do
    it "should raise if called on base class" do
      fl = "../../../spec/pal/test_files/test_cur_file.csv"
      pal = Pal::Operation::CSVProcessor.new(fl)

      expect { pal.send(:parse, nil, nil) {} }.to raise_error(NotImplementedError)
    end
  end

  describe "#_parse_impl" do
    it "should raise if called on base class" do
      fl = "../../../spec/pal/test_files/test_cur_file.csv"
      pal = Pal::Operation::CSVProcessor.new(fl)

      expect { pal.send(:_parse_impl, nil, nil) {} }.to raise_error(NotImplementedError)
    end
  end

  describe "#stream_file" do
    it "should raise error until someone writes a streaming svc" do
      fl = "../../../spec/pal/test_files/test_cur_file.csv"
      pal = Pal::Operation::CSVProcessor.new(fl)

      expect { pal.send(:stream_file, nil) }.to raise_error(NotImplementedError)
    end
  end

  describe "#read_file" do
    it "should raise error until someone writes a streaming svc" do
      fl = "../../../spec/pal/test_files/test_cur_file.csv"
      pal = Pal::Operation::CSVProcessor.new(fl)
      response = pal.send(:read_file, fl)

      expect(response.start_with?("identity/LineItemId")).to be_truthy
    end
  end

end

RSpec.describe Pal::Operation::RCSVProcessorImpl do
  describe "#new" do
    it "should load the CSV file" do
      fl = "../../../spec/pal/test_files/test_cur_file.csv"
      pal = Pal::Operation::RCSVProcessorImpl.new(fl)

      expect(pal.csv_file_location).to_not be_nil
    end
  end

  describe "#parse" do
    it "should raise if called on base class" do
      fl = "../../../spec/pal/test_files/test_cur_file.csv"
      pal = Pal::Operation::CSVProcessor.retrieve_default_processor(fl)

      ctx = Pal::Operation::ProcessorContext.new
      pal.parse(ctx, {}) {}

      expect(ctx.row_count).to eq(70)
    end
  end
end
