# frozen_string_literal: true

require "pal"
require "pal/configuration"
require "pal/common/local_file_utils"
require "pal/common/safe_hash_parser"

module Pal
  module Operation
    class Exporter
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
        results = _extract(rows, column_headers, properties)

        if results.empty?
          Pal.logger.warn("No results were found, will not export to file.")
          return
        end

        _export(results)
      end

      protected

      # @param [Array] rows
      # @param [Hash] column_headers
      # @param [Array<String>] properties
      # @return [Array<Hash<String,String>]
      # rubocop:disable Metrics/CyclomaticComplexity
      def _extract(rows, column_headers, properties)
        rows.map do |struct|
          hash_val = {}
          property_exists = get_lookup_proc(struct)
          properties&.each do |prop|
            hash_val[prop.to_sym] = property_exists.call(prop)
          end

          hash_val
        end
      end
      # rubocop:enable Metrics/CyclomaticComplexity

      def _export(_results)
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

    require "json"

    # do json exporter
  end
end

