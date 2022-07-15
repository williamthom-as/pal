# frozen_string_literal: true

RSpec.describe Pal do
  it "has a version number" do
    expect(Pal::VERSION).not_to be nil
  end

  describe Pal::ValidationError do

    it "should take an array list of string errors" do
      expect { raise Pal::ValidationError.new(["my error"]) }.to raise_error("Validation error: [my error]")
    end
  end
end
