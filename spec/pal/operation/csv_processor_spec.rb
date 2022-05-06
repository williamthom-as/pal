# frozen_string_literal: true

require "json"
require "pal/operation/processor_context"

RSpec.describe Pal::Operation::RCSVProcessorImpl do
  describe "#new" do
    it "should load the CSV file" do
      fl = "spec/pal/test_files/test_cur_file.csv"
      pal = Pal::Operation::RCSVProcessorImpl.new(fl)

      expect(pal.csv_file_location).to_not be_nil
    end
  end

  describe "#retrieve_default_processor" do
    it "should load the CSV file" do
      fl = "spec/pal/test_files/test_cur_file.csv"
      pal = Pal::Operation::RCSVProcessorImpl.retrieve_default_processor(fl)

      expect(pal.class).to be(Pal::Operation::RCSVProcessorImpl)
    end
  end


end


