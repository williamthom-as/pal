# frozen_string_literal: true

require "json"

RSpec.describe Pal::Operation::FilterEvaluator do
  valid_str_filter = '{
    "condition": "OR",
    "rules": [
      {
        "field": "name",
        "type": "string",
        "operator": "equal",
        "value": "banana"
      }
    ]
  }'

  # string

  describe "#new" do
    it "should load from hash" do
      filter_eval = Pal::Operation::FilterEvaluator.new(JSON.parse(valid_str_filter))
      expect(filter_eval.rule.class).to eq(Pal::Operation::OrGroupRule)
      expect(filter_eval.rule.rule_group.size).to eq(1)
    end
  end

  describe "#equal" do
    it "should return true result for [equal] if equal" do
      filter_eval = Pal::Operation::FilterEvaluator.new(JSON.parse(valid_str_filter))
      result = filter_eval.test_property(["banana"], {"name" => 0})
      expect(result).to eq(true)
    end

    it "should return false result for [equal] if not equal" do
      filter_eval = Pal::Operation::FilterEvaluator.new(JSON.parse(valid_str_filter))
      result = filter_eval.test_property(["not_found"], {"name" => 0})
      expect(result).to eq(false)
    end
  end

  describe "#not_equal" do
    it "should return true result for [not_equal] if not equal" do
      filter = JSON.parse(valid_str_filter)
      filter["rules"].first["operator"] = "not_equal"
      filter_eval = Pal::Operation::FilterEvaluator.new(filter)

      result = filter_eval.test_property(["not_found"], {"name" => 0})
      expect(result).to eq(true)
    end

    it "should return false result for [not_equal] if equal" do
      filter = JSON.parse(valid_str_filter)
      filter["rules"].first["operator"] = "not_equal"
      filter_eval = Pal::Operation::FilterEvaluator.new(filter)

      result = filter_eval.test_property(["banana"], {"name" => 0})
      expect(result).to eq(false)
    end
  end

  describe "#begins_with" do
    it "should return false result for [begins_with] if not begins_with" do
      filter = JSON.parse(valid_str_filter)
      filter["rules"].first["operator"] = "begins_with"
      filter_eval = Pal::Operation::FilterEvaluator.new(filter)

      result = filter_eval.test_property(["not_found"], {"name" => 0})
      expect(result).to eq(false)
    end

    it "should return true result for [begins_with] if begins_with" do
      filter = JSON.parse(valid_str_filter)
      filter["rules"].first["operator"] = "begins_with"
      filter["rules"].first["value"] = "ban"
      filter_eval = Pal::Operation::FilterEvaluator.new(filter)

      result = filter_eval.test_property(["banana"], {"name" => 0})
      expect(result).to eq(true)
    end
  end

  describe "#not_begins_with" do
    it "should return true result for [not_begins_with] if not begins_with" do
      filter = JSON.parse(valid_str_filter)
      filter["rules"].first["operator"] = "not_begins_with"
      filter_eval = Pal::Operation::FilterEvaluator.new(filter)

      result = filter_eval.test_property(["not_found"], {"name" => 0})
      expect(result).to eq(true)
    end

    it "should return false result for [not_begins_with] if not_begins_with" do
      filter = JSON.parse(valid_str_filter)
      filter["rules"].first["operator"] = "not_begins_with"
      filter["rules"].first["value"] = "ban"
      filter_eval = Pal::Operation::FilterEvaluator.new(filter)

      result = filter_eval.test_property(["banana"], {"name" => 0})
      expect(result).to eq(false)
    end
  end

  describe "#ends_with" do
    it "should return false result for [ends_with] if not ends_with" do
      filter = JSON.parse(valid_str_filter)
      filter["rules"].first["operator"] = "ends_with"
      filter_eval = Pal::Operation::FilterEvaluator.new(filter)

      result = filter_eval.test_property(["not_found"], {"name" => 0})
      expect(result).to eq(false)
    end

    it "should return true result for [ends_with] if ends_with" do
      filter = JSON.parse(valid_str_filter)
      filter["rules"].first["operator"] = "ends_with"
      filter["rules"].first["value"] = "ana"
      filter_eval = Pal::Operation::FilterEvaluator.new(filter)

      result = filter_eval.test_property(["banana"], {"name" => 0})
      expect(result).to eq(true)
    end
  end

  describe "#not_ends_with" do
    it "should return true result for [not_ends_with] if not not_ends_with" do
      filter = JSON.parse(valid_str_filter)
      filter["rules"].first["operator"] = "not_ends_with"
      filter_eval = Pal::Operation::FilterEvaluator.new(filter)

      result = filter_eval.test_property(["not_found"], {"name" => 0})
      expect(result).to eq(true)
    end

    it "should return false result for [not_ends_with] if not_ends_with" do
      filter = JSON.parse(valid_str_filter)
      filter["rules"].first["operator"] = "not_ends_with"
      filter["rules"].first["value"] = "ana"
      filter_eval = Pal::Operation::FilterEvaluator.new(filter)

      result = filter_eval.test_property(["banana"], {"name" => 0})
      expect(result).to eq(false)
    end
  end

  describe "#contains" do
    it "should return false result for [contains] if not contains" do
      filter = JSON.parse(valid_str_filter)
      filter["rules"].first["operator"] = "contains"
      filter_eval = Pal::Operation::FilterEvaluator.new(filter)

      result = filter_eval.test_property(["not_found"], {"name" => 0})
      expect(result).to eq(false)
    end

    it "should return true result for [contains] if contains" do
      filter = JSON.parse(valid_str_filter)
      filter["rules"].first["operator"] = "contains"
      filter["rules"].first["value"] = "nan"
      filter_eval = Pal::Operation::FilterEvaluator.new(filter)

      result = filter_eval.test_property(["banana"], {"name" => 0})
      expect(result).to eq(true)
    end
  end

  describe "#not_contains" do
    it "should return true result for [not_contains] if not not_contains" do
      filter = JSON.parse(valid_str_filter)
      filter["rules"].first["operator"] = "not_contains"
      filter_eval = Pal::Operation::FilterEvaluator.new(filter)

      result = filter_eval.test_property(["not_found"], {"name" => 0})
      expect(result).to eq(true)
    end

    it "should return false result for [not_contains] if not_contains" do
      filter = JSON.parse(valid_str_filter)
      filter["rules"].first["operator"] = "not_contains"
      filter["rules"].first["value"] = "ana"
      filter_eval = Pal::Operation::FilterEvaluator.new(filter)

      result = filter_eval.test_property(["banana"], {"name" => 0})
      expect(result).to eq(false)
    end
  end

  describe "#is_empty" do
    it "should return false result for [is_empty] if not is_empty" do
      filter = JSON.parse(valid_str_filter)
      filter["rules"].first["operator"] = "is_empty"
      filter_eval = Pal::Operation::FilterEvaluator.new(filter)

      result = filter_eval.test_property(["not_found"], {"name" => 0})
      expect(result).to eq(false)
    end

    it "should return true result for [is_empty] if is_empty" do
      filter = JSON.parse(valid_str_filter)
      filter["rules"].first["operator"] = "is_empty"
      filter["rules"].first["value"] = ""
      filter_eval = Pal::Operation::FilterEvaluator.new(filter)

      result = filter_eval.test_property([""], {"name" => 0})
      expect(result).to eq(true)
    end
  end

  describe "#is_not_empty" do
    it "should return true result for [is_not_empty] if not is_not_empty" do
      filter = JSON.parse(valid_str_filter)
      filter["rules"].first["operator"] = "is_not_empty"
      filter_eval = Pal::Operation::FilterEvaluator.new(filter)

      result = filter_eval.test_property(["not_found"], {"name" => 0})
      expect(result).to eq(true)
    end

    it "should return false result for [is_not_empty] if is_not_empty" do
      filter = JSON.parse(valid_str_filter)
      filter["rules"].first["operator"] = "is_not_empty"
      filter["rules"].first["value"] = ""
      filter_eval = Pal::Operation::FilterEvaluator.new(filter)

      result = filter_eval.test_property([""], {"name" => 0})
      expect(result).to eq(false)
    end
  end

  # number

  valid_num_filter = '{
    "condition": "OR",
    "rules": [
      {
        "field": "name",
        "type": "number",
        "operator": "equal",
        "value": 12
      }
    ]
  }'

  describe "#equal" do
    it "should return true result for [equal] if equal" do
      filter_eval = Pal::Operation::FilterEvaluator.new(JSON.parse(valid_num_filter))
      result = filter_eval.test_property([12], {"name" => 0})
      expect(result).to eq(true)
    end

    it "should return false result for [equal] if not equal" do
      filter_eval = Pal::Operation::FilterEvaluator.new(JSON.parse(valid_num_filter))
      result = filter_eval.test_property([11], {"name" => 0})
      expect(result).to eq(false)
    end
  end

  describe "#not_equal" do
    it "should return true result for [not_equal] if not equal" do
      filter = JSON.parse(valid_num_filter)
      filter["rules"].first["operator"] = "not_equal"
      filter_eval = Pal::Operation::FilterEvaluator.new(filter)

      result = filter_eval.test_property([10], {"name" => 0})
      expect(result).to eq(true)
    end

    it "should return false result for [not_equal] if equal" do
      filter = JSON.parse(valid_num_filter)
      filter["rules"].first["operator"] = "not_equal"
      filter_eval = Pal::Operation::FilterEvaluator.new(filter)

      result = filter_eval.test_property([12], {"name" => 0})
      expect(result).to eq(false)
    end
  end

  describe "#less" do
    it "should return true result for [less] if less" do
      filter = JSON.parse(valid_num_filter)
      filter["rules"].first["operator"] = "less"
      filter_eval = Pal::Operation::FilterEvaluator.new(filter)

      result = filter_eval.test_property([10], {"name" => 0})
      expect(result).to eq(true)
    end

    it "should return false result for [less] if not less" do
      filter = JSON.parse(valid_num_filter)
      filter["rules"].first["operator"] = "less"
      filter_eval = Pal::Operation::FilterEvaluator.new(filter)

      result = filter_eval.test_property([14], {"name" => 0})
      expect(result).to eq(false)
    end
  end

  describe "#less_or_equal" do
    it "should return true result for [less_or_equal] if less_or_equal" do
      filter = JSON.parse(valid_num_filter)
      filter["rules"].first["operator"] = "less_or_equal"
      filter_eval = Pal::Operation::FilterEvaluator.new(filter)

      result = filter_eval.test_property([12], {"name" => 0})
      result1 = filter_eval.test_property([11], {"name" => 0})
      expect(result).to eq(true)
      expect(result1).to eq(true)
    end

    it "should return false result for [less_or_equal] if more" do
      filter = JSON.parse(valid_num_filter)
      filter["rules"].first["operator"] = "less_or_equal"
      filter_eval = Pal::Operation::FilterEvaluator.new(filter)

      result = filter_eval.test_property([14], {"name" => 0})
      expect(result).to eq(false)
    end
  end

  # tag
  valid_tag_filter = '{
    "condition": "OR",
    "rules": [
      {
        "field": "name",
        "type": "json",
        "operator": "key_equal",
        "value": "dog_breed"
      }
    ]
  }'

  describe "#less" do
    it "should return true result if json has key" do
      filter = JSON.parse(valid_tag_filter)
      filter_eval = Pal::Operation::FilterEvaluator.new(filter)

      result = filter_eval.test_property(['{"dog_breed": "poodle"}'], {"name" => 0})
      expect(result).to eq(true)
    end

    it "should return true result if json has value" do
      valid_tag_filter = '{
        "condition": "OR",
        "rules": [
          {
            "field": "name",
            "type": "json",
            "operator": "value_equal",
            "value": "poodle"
          }
        ]
      }'

      filter = JSON.parse(valid_tag_filter)
      filter_eval = Pal::Operation::FilterEvaluator.new(filter)

      result = filter_eval.test_property(['{"dog_breed": "poodle"}'], {"name" => 0})
      expect(result).to eq(true)
    end

    it "should return true result if json has jpath" do
      valid_tag_filter = '{
        "condition": "OR",
        "rules": [
          {
            "field": "name",
            "type": "json",
            "operator": "jpath",
            "value": "dog_breed=poodle"
          }
        ]
      }'

      filter = JSON.parse(valid_tag_filter)
      filter_eval = Pal::Operation::FilterEvaluator.new(filter)

      result = filter_eval.test_property(['{"dog_breed": "poodle"}'], {"name" => 0})
      expect(result).to eq(true)
    end

  end

end


