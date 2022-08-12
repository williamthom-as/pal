# frozen_string_literal: true

require "pal"
require "pal/configuration"
require "pal/common/local_file_utils"
require "pal/common/safe_hash_parse"
require "pal/common/object_helpers"

module Pal
  module Operation
    # Probably a bad name, its really a processor that calls an export impl - w
    class Exporter
      include Log
      include ObjectHelpers

      # @return [Array<Pal::Operation::BaseExportHandler>]
      attr_reader :export_types

      # @return [Array<String>]
      attr_accessor :properties

      # @return [Actions]
      attr_reader :actions

      # @param [Pal::Operation::ProcessorContext] ctx
      # @return [Array, Hash]
      def perform_export(ctx)
        log_info("About to extract required data defined in #{ctx.candidates.size} rows")
        extracted_rows, extracted_columns = extract(ctx, @properties)

        if @actions&.processable?
          log_info("Actions have been defined, going off to extract.")
          extracted_rows, extracted_columns = @actions.process(extracted_rows, extracted_columns)
        end

        @export_types.each do |t|
          log_info("Exporting for [#{t.class}] triggered ...")
          t.run_export(extracted_rows, extracted_columns)
          log_info("... export for [#{t.class}] completed")
        end

        [extracted_rows, extracted_columns]
      end

      private

      # @param [Array<String>] properties
      # @return [Array]
      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/MethodLength
      # rubocop:disable Metrics/PerceivedComplexity
      # rubocop:disable Metrics/CyclomaticComplexity
      def extract(ctx, properties)
        all_columns = ctx.column_headers.keys

        properties = all_columns if properties.nil? || properties.empty?

        extractable_properties = {}
        properties.each do |property|
          unless all_columns.include? property
            log_warn("[#{property}] not found in column headers.")
            next
          end

          extractable_properties[property] = ctx.column_headers[property]
        end

        extracted_rows = ctx.candidates.map do |row|
          extractable_properties.map do |key, value_idx|
            value = row[value_idx]
            value ? ctx.cast(key, value) : "<Missing>"
          end
        end

        new_extractable_properties = {}
        extractable_properties.keys.each_with_index do |key, idx|
          new_extractable_properties[key] = idx
        end

        [extracted_rows, new_extractable_properties]
      end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/MethodLength
      # rubocop:enable Metrics/PerceivedComplexity
      # rubocop:enable Metrics/CyclomaticComplexity

      def actions=(opts)
        @actions = Pal::Operation::Actions.new.from_hash(opts)
      end

      # @return [Array<Pal::Operation::BaseExportHandler>]
      def types=(types_conf)
        @export_types = types_conf.map do |type_conf|
          name = type_conf["name"]
          settings = type_conf["settings"]

          clazz_name = "Pal::Operation::#{name.to_s.capitalize}ExporterImpl"
          Kernel.const_get(clazz_name).new(settings)
        end
      end
    end

    module FileExportable
      # @param [String] file_path
      # @param [String] contents
      # @param [String] file_extension
      def write_to_file(file_path, file_name, file_extension, contents)
        file_location = "#{file_path}/#{file_name || Time.now.utc.strftime("%Y-%m-%dT%H:%M:%S%-z")}"
        Pal::Common::LocalFileUtils.with_file(file_location, file_extension) do |file|
          file.write(contents)
        end
      end
    end

    class BaseExportHandler
      include Pal::Configuration
      include Pal::Log

      # @return [Hash] settings
      attr_accessor :settings

      # @param [Hash] settings
      def initialize(settings)
        @settings = settings
      end

      # @param [Array] rows
      # @param [Hash] columns
      # Extract values, call export.
      def run_export(rows, columns)
        if rows.empty?
          Pal.logger.warn("No results were found, will not export.")
          return
        end

        _export(rows, columns)
      end

      protected

      # @abstract
      # @param [Array] _rows
      # @param [Hash] _columns
      def _export(_rows, _columns)
        raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
      end
    end

    class CsvExporterImpl < BaseExportHandler
      include FileExportable

      # @param [Array] rows
      # @param [Hash] column_headers
      def _export(rows, column_headers)
        file_contents = []
        file_contents << column_headers.keys.join(",")

        rows.each do |row|
          file_contents << row.join(",")
        end

        write_to_file(
          @settings["output_dir"], @settings["file_name"] || "pal", "csv", file_contents.join("\n")
        )
      end
    end

    require "terminal-table"

    class TableExporterImpl < BaseExportHandler
      # @param [Array] rows
      # @param [Hash] column_headers
      def _export(rows, column_headers)
        title = @settings["title"] || "<No Title Set>"
        style = @settings["style"] || {}

        table = Terminal::Table.new(title: title, headings: column_headers.keys, rows: rows, style: style)
        puts table
      end
    end
    # do json exporter
  end
end
