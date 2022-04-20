# frozen_string_literal: true

RSpec.describe Pal::Configuration do
  describe "#new" do
    it "should raise an error is config is not loaded" do
      expect { Pal::Configuration.config }.to raise_error(StandardError)
    end
  end
end
