# frozen_string_literal: true

require "json"
require "pal/common/object_helpers"

module Pal
  module Operation
    # Filter evaluator runs the filter processes to identify candidates
    class FilterEvaluator

      # @return [Rule]
      attr_reader :rule

      def initialize(filters)
        @rule = RuleFactory.from_hash(filters)
      end

      # @param [Hash{Symbol->String}] object
      # @return [Boolean]
      def test_property(object)
        return true if @rule.nil?

        eval_ctx = EvaluationContext.new(object)
        @rule.evaluate(eval_ctx)
      end
    end

    # Class to manage the rules provided
    class RuleFactory

      # @param [Hash] rule_hash
      # @return [Rule]
      def self.from_hash(rule_hash)
        return nil if rule_hash.nil? || rule_hash.keys.empty?

        if rule_hash.key?("condition")
          condition = rule_hash.fetch("condition")
          rules = RuleFactory.from_group_rules(rule_hash)

          return AndGroupRule.new(rules) if condition.casecmp("and").zero?
          return OrGroupRule.new(rules) if condition.casecmp("or").zero?

          raise "Invalid condition [#{condition}] passed."
        end

        return OperatorRule.new(rule_hash) if rule_hash.key?("operator")

        raise "Hash is malformed."
      end

      # @return [Array<Rule>]
      def self.from_group_rules(group_rule)
        rules = group_rule.fetch("rules", [])

        rules.map do |rule_hash|
          from_hash(rule_hash)
        end
      end
    end

    class Rule

      def evaluate(eval_ctx)
        _evaluate(eval_ctx)
      end

      private

      def _evaluate(_eval_ctx)
        raise "Not Implemented Here"
      end

    end

    class GroupRule < Rule

      # @return [Array<Rule>]
      attr_reader :rule_group

      # @param [Array<Rule>] rule_group
      def initialize(rule_group)
        @rule_group = rule_group
        super()
      end
    end

    class AndGroupRule < GroupRule

      private

      def _evaluate(eval_ctx)
        @rule_group.all? do |rule|
          rule.evaluate(eval_ctx)
        end
      end

    end

    class OrGroupRule < GroupRule

      private

      def _evaluate(eval_ctx)
        @rule_group.any? do |rule|
          rule.evaluate(eval_ctx)
        end
      end

    end

    class OperatorRule < Rule

      # @return [String]
      attr_reader :operator, :field

      # @return [Object]
      attr_reader :comparison_value

      # @return [Symbol]
      attr_reader :type

      def initialize(rule_hash)
        super()
        @field = rule_hash.fetch("field")
        @type = rule_hash.fetch("type").to_sym
        @operator = rule_hash.fetch("operator").to_sym
        @comparison_value = rule_hash.fetch("value")
      end

      # @param [EvaluationContext] eval_ctx
      # @return [Boolean]
      def _evaluate(eval_ctx)
        operator_candidates = get_operators_for_type(@type)
        return true if operator_candidates.keys.empty?

        tokens = @field.split(".").map(&:to_sym)
        property = eval_ctx.object.dig(*tokens)
        proc = operator_candidates.fetch(@operator, proc {|_x, _y| raise "Invalid operator given - #{@operator}" })

        converted_property = convert_property(@type, property)
        proc.call(converted_property, @comparison_value)
      end

      # @param [Symbol] type
      # @return [Hash{Symbol->Proc}]
      def get_operators_for_type(type)
        case type
        when :string
          string_operators
        when :number
          number_operators
        when :date
          number_operators
        when :tag
          tag_operators
        else
          {}
        end
      end

      # @param [Symbol] type
      # @return [Object]
      def convert_property(type, prop)
        case type
        when :string
          prop.to_s
        when :number
          prop.to_f
        when :tag
          prop
        when :date
          Date.parse(prop)
        else
          {}
        end
      end

      private

      # rubocop:disable Metrics/AbcSize
      # @return [Hash{Symbol->Proc}]
      def string_operators
        {
          equal: proc { |x, y| x == y },
          not_equal: proc { |x, y| x != y },
          begins_with: proc { |x, y| x.start_with?(y) },
          not_begins_with: proc { |x, y| !x.start_with?(y) },
          ends_with: proc { |x, y| x.end_with?(y) },
          not_ends_with: proc { |x, y| !x.end_with?(y) },
          contains: proc { |x, y| x.include?(y) },
          not_contains: proc { |x, y| !x.include?(y) },
          is_empty: proc { |x, y| x.empty?(y) },
          is_not_empty: proc { |x, y| !x.empty?(y) }
        }
      end

      # @return [Hash{Symbol->Proc}]
      def number_operators
        {
          equal: proc { |x, y| x == y },
          not_equal: proc { |x, y| x != y },
          less: proc { |x, y| x < y },
          less_or_equal: proc { |x, y| x <= y },
          greater: proc { |x, y| x > y },
          greater_or_equal: proc { |x, y| x >= y },
          between: proc { |x, y| x.is_a? Array ? x.between?(y.first, z.last) : false },
          not_between: proc { |x, y| x.is_a? Array ? !x.between?(y.first, z.last) : false },
        }
      end

      # @return [Hash{Symbol->Proc}]
      def tag_operators
        {
          equal: proc do |x, y|
            tokens = y.split(".")
            key_match = tokens.first == "" ? "*" : tokens.first
            val_match = tokens.size == 2 ? tokens.last : "*"
            x.any? do |kvp|
              (key_match == "*" ? true : key_match == kvp[:key]) &&
                (val_match == "*" ? true : val_match == kvp[:value])
            end
          end
        }
      end
      # rubocop:enable Metrics/AbcSize
    end

    class EvaluationContext
      attr_accessor :object

      def initialize(obj)
        @object = obj
      end

      def get_value(key)
        @object.fetch(key, nil)
      end
    end
  end
end


