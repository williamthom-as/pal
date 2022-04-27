# frozen_string_literal: true

require "pal"
require "pal/configuration"
require "pal/common/local_file_utils"
require "pal/common/safe_hash_parser"
require "pal/common/object_helpers"

module Pal
  module Operation
    class Exporter
      include Log
      include ObjectHelpers

      # @return [Array<Pal::Operation::BaseExportHandlerImpl>]
      attr_reader :export_types

      # @return [Array<String>]
      attr_accessor :properties

      # @return [Actions]
      attr_reader :actions

      # def initialize
      #   @export_types = create_types(opts["types"])
      #   @action = create_action(opts["actions"] || {})
      #   @properties = opts["properties"]
      # end

      # @param [Array] rows
      # @param [Hash] column_headers
      def perform_export(rows, column_headers)
        log_info("About to extract required data defined in #{rows.size} rows")
        extracted_rows, extracted_columns = extract(rows, column_headers, @properties)

        if @actions&.processable?
          log_info("Actions have been defined, going off to extract.")
          extracted_rows, extracted_columns = @actions.process(extracted_rows, extracted_columns)
        end

        @export_types.each do |t|
          log_info("Exporting for #{t.class}")
          t.run_export(extracted_rows, extracted_columns)
        end
      end

      private

      # @param [Array] rows
      # @param [Hash] column_headers
      # @param [Array<String>] properties
      # @return [Array]
      # rubocop:disable Metrics/AbcSize
      def extract(rows, column_headers, properties)
        all_columns = column_headers.keys

        extractable_properties = {}
        properties.each do |property|
          unless all_columns.include? property
            log_warn("[#{property}] not found in column headers.")
            next
          end

          extractable_properties[property] = column_headers[property]
        end

        extracted_rows = rows.map do |row|
          extractable_properties.map do |_key, value|
            row[value] || "<Missing>"
          end
        end

        new_extractable_properties = {}
        extractable_properties.keys.each_with_index do |key, idx|
          new_extractable_properties[key] = idx
        end

        [extracted_rows, new_extractable_properties]
      end
      # rubocop:enable Metrics/AbcSize

      # @param [Struct, Hash] lookup
      # @return [Proc<Boolean>]
      # Return a proc that returns boolean if val exists or not
      def lookup_proc(lookup)
        lookup_hash = lookup.is_a?(Hash) ? lookup : lookup.to_h
        proc { |search_prop| SafeParse.extract_from_hash(lookup_hash, search_prop, true, "<Missing>") }
      end

      def actions=(opts)
        @actions = Pal::Operation::Actions.new.from_hash(opts)
      end

      # @return [Array<Pal::Operation::BaseExportHandlerImpl>]
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
      def write_to_file(file_path, file_extension, contents)
        file_location = "#{file_path}/pal-#{Time.now.utc.strftime("%Y-%m-%dT%H:%M:%S%-z")}"
        Pal::Common::LocalFileUtils.with_file(file_location, file_extension) do |file|
          file.write(contents)
        end
      end

    end

    class BaseExportHandlerImpl
      include Pal::Configuration
      include Pal::Log

      # @return [Array<Hash>] settings
      attr_accessor :settings

      # @param [Array<Hash>] settings
      def initialize(settings)
        @settings = settings
      end

      # @param [Array] rows
      # @param [Hash] columns
      # Extract values, call export.
      def run_export(rows, columns)
        if rows.empty?
          Pal.logger.warn("No results were found, will not export to file.")
          return
        end

        _export(rows, columns)
      end

      protected

      def _export(_rows, _columns)
        raise "Not implemented here"
      end
    end

    class CsvExporterImpl < BaseExportHandlerImpl
      include FileExportable

      # @param [Array<Hash<String,String>] results
      def _export(results)
        file_contents = []
        file_contents << column_headers(results)

        results.each do |row|
          file_contents << row.values.join(",")
        end

        write_to_file(config.output_dir, "csv", file_contents.join("\n"))
      end

      private

      # @param [Array<Hash<String,String>] results
      # @return [String]
      def column_headers(results)
        results.first&.keys&.join(",") || ""
      end
    end

    require "terminal-table"

    class TableExporterImpl < BaseExportHandlerImpl

      def _export(rows, column_headers)
        table = Terminal::Table.new(title: "AWS CUR", headings: column_headers.keys, rows: rows, style: @settings)
        puts table
      end
    end

    # do json exporter
  end
end

