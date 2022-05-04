# frozen_string_literal: true

require "pal"
require "pal/log"

module Pal
  module Plugin
    include Log

    def register_plugins(plugin_dir="plugins")
      log_info "Registering any plugins for directory [#{plugin_dir}]"
      PluginManager.instance.register(plugin_dir)
    end

    class PluginManager
      include Singleton
      include Log

      def register(plugin_dir)
        candidates = Dir.glob("#{plugin_dir}/**/*.rb").select { |e| File.file? e }

        log_info "Found a total of [#{candidates.size}] candidates"
        candidates.each do |file_path|
          full_clazz_name = get_clazz_name(file_path)

          next unless defined?(full_clazz_name)
          next unless full_clazz_name.start_with?("Pal::")

          log_info "[#{full_clazz_name}] has passed validation and will be loaded"

          load file_path

          validate_plugin(full_clazz_name)
        end
      end

      private

      def get_clazz_name(file_path)
        mod, clazz = file_path.split("/")[-2..]
        full_clazz = clazz.split("_").map(&:capitalize).join("").gsub(".rb", "")
        "Pal::#{mod.capitalize}::#{full_clazz}"
      end

      # @param [String] full_clazz_name
      # @raise [RuntimeError]
      def validate_plugin(full_clazz_name)
        clazz_ins = Kernel.const_get(full_clazz_name)
        ancestors = clazz_ins.ancestors

        valid_candidates = [Pal::Operation::BaseExportHandlerImpl]
        unless valid_candidates.find { |a| ancestors.include?(a) }
          log_error("Invalid plugin has been given. Valid plugin candidates are: #{valid_candidates.inspect}")
          raise "Invalid plugin given!"
        end

        true
      end
    end
  end
end
