# frozen_string_literal: true

require "json"
require "pal/common/object_helpers"
require "pal/common/safe_hash_parse"

module Pal
  module Operation
    # Filter evaluator runs the filter processes to identify candidates
    class FilterEvaluator

      # @return [Rule]
      attr_reader :rule

      def initialize(filters)
        @rule = RuleFactory.from_hash(filters)
      end

      # @param [Array] row
      # @param [Hash] column_headers
      # @return [Boolean]
      def test_property(row, column_headers)
        return true if @rule.nil?

        eval_ctx = EvaluationContext.new(row, column_headers)
        @rule.evaluate(eval_ctx)
      end
    end

    # Class to manage the rules provided
    class RuleFactory

      # @param [Hash] rule_hash
      # @return [Rule]
      # rubocop:disable Metrics/AbcSize
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
      # rubocop:enable Metrics/AbcSize

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

      # @abstract
      def _evaluate(_eval_ctx)
        raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
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

        property = eval_ctx.get_value(@field)
        return false unless property

        proc = operator_candidates.fetch(@operator, proc do |_x, _y|
          raise "Invalid operator given - [#{@operator}]. Valid candidates are [#{operator_candidates.keys.join(", ")}]"
        end)

        converted_comparison = convert_property(@type, @comparison_value)
        converted_property = convert_property(@type, property)

        proc.call(converted_property, converted_comparison)
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
          date_operators
        when :json
          json_operators
        else
          raise "Missing filter operator for [#{type}], valid candidates: [string, number, tag, date]"
        end
      end

      # @param [Symbol] type
      # @return [Object]
      def convert_property(type, prop)
        case type
        when :string
          prop.to_s
        when :number
          prop.is_a?(Array) ? prop : prop.to_f
        when :json
          prop
        when :date
          Date.parse(prop)
        else
          raise "Missing property operator for [#{type}], valid candidates: [string, number, json, date]"
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
          is_empty: proc { |x, _y| x.empty? },
          is_not_empty: proc { |x, _y| !x.empty? }
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
          between: proc { |x, y| y.is_a?(Array) ? x.between?(y.first, y.last) : false },
          not_between: proc { |x, y| y.is_a?(Array) ? !x.between?(y.first, y.last) : false }
        }
      end
      alias date_operators number_operators

      # @return [Hash{Symbol->Proc}]
      def json_operators
        {
          key_equal: proc do |x, y|
            !SafeHashParse.extract_from_json(x, y).empty?
          end,
          key_not_equal: proc do |x, y|
            SafeHashParse.extract_from_json(x, y).empty?
          end,
          value_equal: proc do |x, y|
            SafeHashParse.all_values_from_json(x).include?(y)
          end,
          value_not_equal: proc do |x, y|
            !SafeHashParse.all_values_from_json(x).include?(y)
          end,
          jpath: proc do |x, y|
            path, value = y.split("=")
            SafeHashParse.extract_from_json(x, path).include?(value)
          end
        }
      end
      # rubocop:enable Metrics/AbcSize
    end

    class EvaluationContext
      attr_accessor :row, :column_headers

      def initialize(row, column_headers)
        @row = row
        @column_headers = column_headers
      end

      def get_value(key)
        idx = @column_headers.fetch(key, -1)
        idx.zero? || idx.positive? ? @row[idx] : nil
      end
    end
  end
end


