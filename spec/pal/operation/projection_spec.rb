# frozen_string_literal: true

require "json"

RSpec.describe Pal::Operation::Projection do

  describe "#new" do
    it "should persist type and property" do
      proj = Pal::Operation::Projection.new("sum", "column_a")
      expect(proj.type).to eq("sum")
      expect(proj.property).to eq("column_a")
    end
  end

  describe "#processable?" do
    it "should be true is both are set" do
      proj = Pal::Operation::Projection.new("sum", "column_a")
      expect(proj.processable?).to be_truthy

      proj = Pal::Operation::Projection.new("sum", nil)
      expect(proj.processable?).to be_falsey

      proj = Pal::Operation::Projection.new(nil, "column_a")
      expect(proj.processable?).to be_falsey
    end
  end

  describe "#process" do
    it "should be raise not implemented if called on base" do
      proj = Pal::Operation::Projection.new("sum", "column_a")
      expect {
        proj.process([], {}, {})
      }.to raise_error("Pal::Operation::Projection has not implemented method '_process_impl'")
    end
  end

end

RSpec.describe Pal::Operation::SumProjectionImpl do

  describe "#process?" do
    it "should be raise not implemented if called on base" do

      proj = Pal::Operation::SumProjectionImpl.new("col_b")
      group_by_rules = %w[col_a col_b]
      groups = {
        "abc" => [
          ["abc", 1],
          ["abc", 2]
        ],
        "def" => [
          ["def", 5],
          ["def", 5]
        ]
      }
      column_headers = {
        "col_a" => 0,
        "col_b" => 1
      }

      rows, column_headers = proj.process(group_by_rules, groups, column_headers)

      expect(rows.size).to eq(2)
      expect(rows[0][2]).to eq(3) # 1 + 2
      expect(rows[1][2]).to eq(10) # 5 + 5

      expect(column_headers.keys.join(",")).to eq("col_a,col_b,sum_col_b")
    end
  end

end

RSpec.describe Pal::Operation::DistinctProjectionImpl do

  describe "#process?" do
    it "should be raise not implemented if called on base" do

      proj = Pal::Operation::DistinctProjectionImpl.new("col_b")
      group_by_rules = %w[col_a col_b]
      groups = {
        "abc" => [
          ["abc", 1],
          ["abc", 2]
        ],
        "def" => [
          ["def", 5],
          ["def", 5]
        ]
      }
      column_headers = {
        "col_a" => 0,
        "col_b" => 1
      }

      rows, column_headers = proj.process(group_by_rules, groups, column_headers)

      expect(rows.flatten.join(",")).to eq("1,2,5")
      expect(column_headers.keys.join(",")).to eq("distinct_col_b")
    end
  end

end

RSpec.describe Pal::Operation::MaxMinProjectionImpl do

  describe "#_comparator_proc" do
    it "should be raise not implemented if called on base" do
      proj = Pal::Operation::MaxMinProjectionImpl.new("min", "column_a")
      expect {
        proj.send(:_comparator_proc)
      }.to raise_error(NotImplementedError)
    end
  end
end

RSpec.describe Pal::Operation::MinProjectionImpl do

  describe "#process?" do
    it "should be raise not implemented if called on base" do

      proj = Pal::Operation::MinProjectionImpl.new("col_b")
      group_by_rules = %w[col_a col_b]
      groups = {
        "abc" => [
          ["abc", 1],
          ["abc", 2]
        ],
        "def" => [
          ["def", 5],
          ["def", 7]
        ]
      }
      column_headers = {
        "col_a" => 0,
        "col_b" => 1
      }

      rows, column_headers = proj.process(group_by_rules, groups, column_headers)

      expect(rows.size).to eq(2)
      expect(rows[0][1]).to eq(1)
      expect(rows[1][1]).to eq(5)
      expect(column_headers.keys.join(",")).to eq("col_a,col_b")
    end
  end

end

RSpec.describe Pal::Operation::MaxProjectionImpl do

  describe "#process?" do
    it "should be raise not implemented if called on base" do

      proj = Pal::Operation::MaxProjectionImpl.new("col_b")
      group_by_rules = %w[col_a col_b]
      groups = {
        "abc" => [
          ["abc", 1],
          ["abc", 2]
        ],
        "def" => [
          ["def", 5],
          ["def", 7]
        ]
      }
      column_headers = {
        "col_a" => 0,
        "col_b" => 1
      }

      rows, column_headers = proj.process(group_by_rules, groups, column_headers)

      expect(rows.size).to eq(2)
      expect(rows[0][1]).to eq(2)
      expect(rows[1][1]).to eq(7)
      expect(column_headers.keys.join(",")).to eq("col_a,col_b")
    end
  end

end

RSpec.describe Pal::Operation::DefaultProjectionImpl do

  describe "#process?" do
    it "should be raise not implemented if called on base" do

      proj = Pal::Operation::DefaultProjectionImpl.new("col_b")
      group_by_rules = %w[col_a col_b]
      groups = {
        "abc" => [
          ["abc", 1],
          ["abc", 2]
        ],
        "def" => [
          ["def", 5],
          ["def", 7]
        ]
      }
      column_headers = {
        "col_a" => 0,
        "col_b" => 1
      }

      rows, column_headers = proj.process(group_by_rules, groups, column_headers)

      expect(rows.size).to eq(2)
      expect(rows[0][0]).to eq(["abc", 1])
      expect(rows[0][1]).to eq(["abc", 2])
      expect(rows[1][0]).to eq(["def", 5])
      expect(rows[1][1]).to eq(["def", 7])
      expect(column_headers.keys.join(",")).to eq("col_a,col_b")
    end
  end

end

RSpec.describe Pal::Operation::AverageProjectionImpl do

  describe "#process?" do
    it "should be raise not implemented if called on base" do

      proj = Pal::Operation::AverageProjectionImpl.new("col_b")
      group_by_rules = %w[col_a col_b]
      groups = {
        "abc" => [
          ["abc", 1],
          ["abc", 2]
        ],
        "def" => [
          ["def", 5],
          ["def", 7]
        ]
      }
      column_headers = {
        "col_a" => 0,
        "col_b" => 1
      }

      rows, column_headers = proj.process(group_by_rules, groups, column_headers)

      expect(rows.size).to eq(2)
      expect(rows[0][1]).to eq(1.5)
      expect(rows[1][1]).to eq(6)
      expect(column_headers.keys.join(",")).to eq("col_a,average_col_b")
    end
  end

end

RSpec.describe Pal::Operation::CountProjectionImpl do

  describe "#process?" do
    it "should be raise not implemented if called on base" do

      proj = Pal::Operation::CountProjectionImpl.new("col_b")
      group_by_rules = %w[col_a col_b]
      groups = {
        "abc" => [
          ["abc", 1],
          ["abc", 2]
        ],
        "def" => [
          ["def", 5],
          ["def", 5]
        ]
      }
      column_headers = {
        "col_a" => 0,
        "col_b" => 1
      }

      rows, column_headers = proj.process(group_by_rules, groups, column_headers)

      expect(rows.size).to eq(3)
      expect(rows[0][0]).to eq(1)
      expect(rows[0][1]).to eq(1)

      expect(rows[1][0]).to eq(2)
      expect(rows[1][1]).to eq(1)

      expect(rows[2][0]).to eq(5)
      expect(rows[2][1]).to eq(2)
      expect(column_headers.keys.join(",")).to eq("col_b,count_col_b")
    end
  end

end

