# frozen_string_literal: true

require "json"

RSpec.describe Pal::Operation::ProcessorContext do

  describe "#new" do
    it "should construct from hash" do
      ctx = Pal::Operation::ProcessorContext.new
      expect(ctx.column_headers).to eq({})
      expect(ctx.total_row_count).to eq(0)
      expect(ctx.candidates).to eq([])
    end
  end

  describe "#extract_column_headers" do
    it "should extract column headers w index" do
      ctx = Pal::Operation::ProcessorContext.new
      ctx.extract_column_headers(%w[a b c])
      expect(ctx.column_headers["a"]).to eq(0)
      expect(ctx.column_headers["b"]).to eq(1)
      expect(ctx.column_headers["c"]).to eq(2)
    end
  end

  describe "#add_candidate" do
    it "should add candidate to rows" do
      ctx = Pal::Operation::ProcessorContext.new
      ctx.add_candidate(%w[a b c])
      expect(ctx.candidates).to eq([%w[a b c]])
    end
  end

  describe "#cast" do
    it "should cast to string data type" do
      ctx = Pal::Operation::ProcessorContext.new
      ctx.column_type_definitions = {
        "a" => {
          "data_type" => "string"
        }
      }
      expect(ctx.cast("a", 1)).to eq("1")
    end

    it "should cast to decimal data type" do
      ctx = Pal::Operation::ProcessorContext.new
      ctx.column_type_definitions = {
        "a" => {
          "data_type" => "decimal"
        }
      }
      expect(ctx.cast("a", "1.2")).to eq(1.2)
    end

    it "should cast to integer data type" do
      ctx = Pal::Operation::ProcessorContext.new
      ctx.column_type_definitions = {
        "a" => {
          "data_type" => "integer"
        }
      }
      expect(ctx.cast("a", "1")).to eq(1)
    end

    it "should cast to date_time data type" do
      ctx = Pal::Operation::ProcessorContext.new
      ctx.column_type_definitions = {
        "a" => {
          "data_type" => "date_time"
        }
      }
      expect(ctx.cast("a", "2010-01-01 00:00").class).to eq(DateTime)
    end

    it "should cast to date data type" do
      ctx = Pal::Operation::ProcessorContext.new
      ctx.column_type_definitions = {
        "a" => {
          "data_type" => "date"
        }
      }
      expect(ctx.cast("a", "2010-01-01").class).to eq(Date)
    end

    it "should not change cast if not defined" do
      ctx = Pal::Operation::ProcessorContext.new
      ctx.column_type_definitions = {
        "a" => {
          "data_type" => "date"
        }
      }
      expect(ctx.cast("b", 1)).to eq(1)
    end

    it "should not change cast if not defined" do
      ctx = Pal::Operation::ProcessorContext.new
      ctx.column_type_definitions = {
        "a" => {
          "data_type" => nil
        }
      }
      expect(ctx.cast("a", 1)).to eq(1)
    end
  end

end


