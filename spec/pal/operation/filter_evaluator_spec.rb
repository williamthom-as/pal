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

  describe "#greater_or_equal" do
    it "should return true result for [greater_or_equal] if greater_or_equal" do
      filter = JSON.parse(valid_num_filter)
      filter["rules"].first["operator"] = "greater_or_equal"
      filter_eval = Pal::Operation::FilterEvaluator.new(filter)

      result = filter_eval.test_property([12], {"name" => 0})
      result1 = filter_eval.test_property([13], {"name" => 0})
      expect(result).to eq(true)
      expect(result1).to eq(true)
    end
  end

  describe "#between" do
    it "should return true result for [between] if between" do
      between_filter = '{
        "condition": "OR",
        "rules": [
          {
            "field": "name",
            "type": "number",
            "operator": "between",
            "value": [1, 10]
          }
        ]
      }'
      filter = JSON.parse(between_filter)
      filter_eval = Pal::Operation::FilterEvaluator.new(filter)

      result = filter_eval.test_property([5], {"name" => 0})
      result1 = filter_eval.test_property([11], {"name" => 0})
      expect(result).to eq(true)
      expect(result1).to eq(false)
    end
  end

  describe "#not_between" do
    it "should return true result for [not_between] if not between" do
      between_filter = '{
        "condition": "OR",
        "rules": [
          {
            "field": "name",
            "type": "number",
            "operator": "not_between",
            "value": [1, 10]
          }
        ]
      }'
      filter = JSON.parse(between_filter)
      filter_eval = Pal::Operation::FilterEvaluator.new(filter)

      result = filter_eval.test_property([11], {"name" => 0})
      result1 = filter_eval.test_property([5], {"name" => 0})
      expect(result).to eq(true)
      expect(result1).to eq(false)
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

    it "should return true result if json has value" do
      valid_tag_filter = '{
        "condition": "OR",
        "rules": [
          {
            "field": "name",
            "type": "json",
            "operator": "value_not_equal",
            "value": "lab"
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

    it "should return true result if no key" do
      valid_tag_filter = '{
        "condition": "OR",
        "rules": [
          {
            "field": "name",
            "type": "json",
            "operator": "key_not_equal",
            "value": "no_key"
          }
        ]
      }'

      filter = JSON.parse(valid_tag_filter)
      filter_eval = Pal::Operation::FilterEvaluator.new(filter)

      result = filter_eval.test_property(['{"dog_breed": "poodle"}'], {"name" => 0})
      expect(result).to eq(true)
    end

    it "should return true result if has key" do
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

      filter = JSON.parse(valid_tag_filter)
      filter_eval = Pal::Operation::FilterEvaluator.new(filter)

      result = filter_eval.test_property(['{"dog_breed": "poodle"}'], {"name" => 0})
      expect(result).to eq(true)
    end
  end

end

RSpec.describe Pal::Operation::RuleFactory do
  describe "#from_hash" do
    it "should not match and raise on invalid type" do
      hash = {
        "condition" => "INVALID",
        "rules" => [{
                      "field" => "lineItem/BlendedCost",
                      "type" => "number",
                      "operator" => "greater",
                      "value" => 0
                    }]
      }
      expect { Pal::Operation::RuleFactory.from_hash(hash) }.to raise_error(RuntimeError)
    end

    it "should not match and raise on invalid operator" do
      hash = {
        "condition" => "AND",
        "rules" => [{
          "field" => "lineItem/BlendedCost",
          "type" => "number",
          "operator_invalid" => "greater",
          "value" => 0
        }]
      }
      expect { Pal::Operation::RuleFactory.from_hash(hash) }.to raise_error(RuntimeError)
    end
  end
end

RSpec.describe Pal::Operation::Rule do
  describe "#_evaluate" do
    it "should return not implemented if called on base class" do
      rule = Pal::Operation::Rule.new
      expect { rule.send(:_evaluate, nil) }.to raise_error(NotImplementedError)
    end
  end
end

RSpec.describe Pal::Operation::OperatorRule do
  describe "#_evaluate" do
    it "should raise with invalid operator" do
      hash = {
        "field" => "lineItem/UsageAccountId",
        "type" => "string",
        "operator" => "equal_less",
        "value" => "a"
      }

      eval_ctx = Pal::Operation::EvaluationContext.new(
        [%w[a b], %w[a b], %w[d e]],
        {
          "lineItem/UsageAccountId" => 0,
          "lineItem/ResourceId" => 1
        }
      )

      rule = Pal::Operation::OperatorRule.new(hash)
      expect { rule.send(:_evaluate, eval_ctx) }.to raise_error(RuntimeError)
    end

    it "should raise with valid operator" do
      hash = {
        "field" => "lineItem/UsageAccountId",
        "type" => "string",
        "operator" => "equal",
        "value" => "a"
      }

      eval_ctx = Pal::Operation::EvaluationContext.new(
        %w[a b],
        {
          "lineItem/UsageAccountId" => 0,
          "lineItem/ResourceId" => 1
        }
      )

      rule = Pal::Operation::OperatorRule.new(hash)
      expect(rule.send(:_evaluate, eval_ctx)).to be_truthy
    end
  end

  describe "#get_operators_for_type" do
    it "should raise with an invalid operator type" do
      hash = {
        "field" => "lineItem/UsageAccountId",
        "type" => "string",
        "operator" => "equal",
        "value" => "a"
      }

      rule = Pal::Operation::OperatorRule.new(hash)
      expect { rule.get_operators_for_type(:invalid) }.to raise_error(RuntimeError)
    end

    it "should return a list of candidates if a valid operator type provided" do
      hash = {
        "field" => "lineItem/UsageAccountId",
        "type" => "string",
        "operator" => "equal",
        "value" => "a"
      }

      rule = Pal::Operation::OperatorRule.new(hash)
      expect(rule.get_operators_for_type(:date).class).to eq(Hash)
    end
  end

  describe "#convert_property" do
    it "should raise with an invalid operator type" do
      hash = {
        "field" => "lineItem/UsageAccountId",
        "type" => "string",
        "operator" => "equal",
        "value" => "a"
      }

      rule = Pal::Operation::OperatorRule.new(hash)
      expect { rule.convert_property(:invalid, "1") }.to raise_error(RuntimeError)
    end

    it "should return a date" do
      hash = {
        "field" => "lineItem/UsageAccountId",
        "type" => "string",
        "operator" => "equal",
        "value" => "a"
      }

      rule = Pal::Operation::OperatorRule.new(hash)
      expect(rule.convert_property(:date, "2010-01-01").class).to eq(Date)
    end
  end
end
