# frozen_string_literal: true

require "pal/common/safe_hash_parse"

RSpec.describe Pal::SafeHashParse do
  describe "#extract_from_json" do
    it "should return correct value with correct json" do
      json_str = '{"abc": 123, "def": 456}'
      expect(Pal::SafeHashParse.extract_from_json(json_str, :abc).first).to eq(123)
    end

    it "should return correct value with period notation case key" do
      json_str = '{"abc": { "def" : 123}, "def": 456}'
      expect(Pal::SafeHashParse.extract_from_json(json_str, 'abc.def').first).to eq(123)
    end

    it "should return default value with correct json and incorrect/missing key" do
      json_str = '{"abc": 123, "def": 456}'
      default = 789
      expect(Pal::SafeHashParse.extract_from_json(json_str, :abc_def, true, default).first).to eq(default)
    end

    it "should return default value with incorrect json and optional flag" do
      json_str = 'X{"abc": 123, "def": 456}'
      default = 789
      expect(Pal::SafeHashParse.extract_from_json(json_str, :abc, true, default).first).to eq(default)
    end

    it "should raise exception with incorrect json and not optional flag" do
      json_str = 'X{"abc": 123, "def": 456}'
      expect { Pal::SafeHashParse.extract_from_json(json_str, :abc) }.to raise_error MultiJson::ParseError
    end
  end

  describe "#extract_from_hash" do
    it "should return correct value with correct json" do
      hash = {"abc" => 123, "def" => 456}
      expect(Pal::SafeHashParse.extract_from_hash(hash, :abc)).to eq(123)
    end

    it "should return correct value with period notation case key" do
      hash = {"abc" => {"def" => 456}}
      expect(Pal::SafeHashParse.extract_from_hash(hash, "abc.def")).to eq(456)
    end

    it "should return default value with correct json and incorrect/missing key" do
      hash = {"abc" => 123, "def" => 456}
      default = 789
      expect(Pal::SafeHashParse.extract_from_hash(hash, :abc_def, true, default)).to eq(default)
    end

  end

  describe "#all_values_from_json" do
    it "should return all values from json into array" do
      json_str = '{"abc": 123, "def": 456}'
      expect(Pal::SafeHashParse.all_values_from_json(json_str)).to eq([123, 456])
    end
  end

  describe "#format_key" do
    it "should return correct value with correct json" do
      expect(Pal::SafeHashParse.format_key(:abc)).to eq([:abc])
      expect(Pal::SafeHashParse.format_key("abc")).to eq([:abc])
      expect(Pal::SafeHashParse.format_key("abc.def")).to eq(%i[abc def])

      expect { Pal::SafeHashParse.format_key(Date.new) }.to raise_error ArgumentError
    end
  end
end
