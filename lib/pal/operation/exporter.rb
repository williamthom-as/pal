# frozen_string_literal: true

require "pal"
require "pal/configuration"
require "pal/common/local_file_utils"
require "pal/common/safe_hash_parser"

module Pal
  module Operation
    class Exporter
      include Log

      # @return [Array<Pal::Operation::BaseExportHandlerImpl>]
      attr_reader :export_types

      # @return [Array<String>]
      attr_accessor :properties

      def initialize(types_conf, export_props)
        @export_types = create_types(types_conf)
        @properties = export_props
      end

      # @param [Array] rows
      # @param [Hash] column_headers
      def perform_export(rows, column_headers)
        log_info("Performing export of #{rows.size}")
        @export_types.each { |t| t.run_export(rows, column_headers, @properties) }
      end

      private

      # @return [Array<Pal::Operation::BaseExportHandlerImpl>]
      def create_types(types_conf)
        types_conf.map do |type_conf|
          name = type_conf["name"]
          settings = type_conf["settings"]

          clazz_name = "Pal::Operation::#{name.to_s.capitalize}ExporterImpl"
          Kernel.const_get(clazz_name).new(settings)
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
      # @param [Hash] column_headers
      # @param [Array<String>] properties
      # Extract values, call export.
      def run_export(rows, column_headers, properties)
        rows, columns = extract(rows, column_headers, properties)

        if rows.empty?
          Pal.logger.warn("No results were found, will not export to file.")
          return
        end

        _export(rows, columns)
      end

      protected

      # @param [Array] rows
      # @param [Hash] column_headers
      # @param [Array<String>] properties
      # @return [Array]
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

        [extracted_rows, extractable_properties]
      end

      def _export(_rows, _columns)
        raise "Not implemented here"
      end

      private

      # @param [Struct, Hash] lookup
      # @return [Proc<Boolean>]
      # Return a proc that returns boolean if val exists or not
      def get_lookup_proc(lookup)
        lookup_hash = lookup.is_a?(Hash) ? lookup : lookup.to_h
        proc { |search_prop| SafeParse.extract_from_hash(lookup_hash, search_prop, true, "<Missing>") }
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

